//
//  ViewController.swift
//  game2048
//
//  Created by Justin Chen on 3/20/19.
//  Copyright © 2019 Justin Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

protocol boardDelegate {
    func getBoardSize() -> Int
    
    func getTileState() -> [Tile]
}

protocol settingsDelegate {
    func changeBoardSize(withBoardSize: Int)
    func getBoardSize() -> Int
}

class GameVC: UIViewController {
    
    var game2048: Game = Game()
    var currBoardSize = 4
    var bestScore = 0
    
    lazy var db = {
        return Firestore.firestore()
    }()
    
    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var bestView: UIView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var scoresButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        boardView.delegate = self
        boardView.layer.cornerRadius = 10
        boardView.layer.masksToBounds = true
        scoreView.layer.cornerRadius = 5
        scoreView.layer.masksToBounds = true
        bestView.layer.cornerRadius = 5
        bestView.layer.masksToBounds = true
        undoButton.layer.cornerRadius = 5
        undoButton.layer.masksToBounds = true
        newGameButton.layer.cornerRadius = 5
        newGameButton.layer.masksToBounds = true
        settingsButton.layer.cornerRadius = 5
        settingsButton.layer.masksToBounds = true
        scoresButton.layer.cornerRadius = 5
        scoresButton.layer.masksToBounds = true
        
        self.definesPresentationContext = true
        
        //Set Gesture Recognizers
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(doSwipe))
        swipeRight.direction = .right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(doSwipe))
        swipeLeft.direction = .left
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(doSwipe))
        swipeUp.direction = .up
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(doSwipe))
        swipeDown.direction = .down
        
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeDown)
        
        updateScore()
    }
    
    func updateScore() {
        let score = game2048.getScore()
        scoreLabel.text = "\(score)"
        if score > bestScore {
            bestScore = score
            bestLabel.text = "\(bestScore)"
        }
    }
    
    func checkGameEnd() {
        if game2048.isGameOver() {
            updateScore()
            saveScore()
            self.performSegue(withIdentifier: "presentGameOver", sender: nil)
        }
    }
    
    func saveScore() {
        let currScore = game2048.getScore()
        let boardType = "\(currBoardSize)x\(currBoardSize)"
        if let user = Auth.auth().currentUser {
            print("Saving score")
            let docRef = db.collection("users").document(user.uid)
            
            //Get current score
            docRef.getDocument { (document, error) in
                //If the document exists, we have to compare the current score with the previous score
                if let document = document, document.exists {
                    let prevScore = document.data()!["score"] as! Int
                    if prevScore < currScore {
                        docRef.updateData([
                            boardType: currScore
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                    }
                } else {
                    //Document doesn't exist so we can just use the current score
                    docRef.updateData([
                        boardType: currScore
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
            }
        } else {
            print("User was not logged in; score was not saved")
        }
        
    }

    @IBAction func undo(_ sender: Any) {
        if(game2048.undo()) {
            updateScore()
            //boardView.resetBoard()
            boardView.setNeedsDisplay()
        }
    }
    @IBAction func newGame(_ sender: Any) {
        game2048 = Game(withSize: self.currBoardSize)
        updateScore()
        boardView.setNeedsDisplay()
    }
    
    @IBAction func goToScores(_ sender: Any) {
        self.performSegue(withIdentifier: "presentScores", sender: nil)
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        self.performSegue(withIdentifier: "presentSettings", sender: nil)
    }
    
    @objc func doSwipe(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            game2048.left()
            boardView.setNeedsDisplay()
            updateScore()
            checkGameEnd()
        case.right:
            game2048.right()
            boardView.setNeedsDisplay()
            updateScore()
            checkGameEnd()
        case .up:
            game2048.up()
            boardView.setNeedsDisplay()
            updateScore()
            checkGameEnd()
        case .down:
            game2048.down()
            boardView.setNeedsDisplay()
            updateScore()
            checkGameEnd()
        default:
            print("Default")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "presentSettings") {
            let destVC: SettingsVC = segue.destination as! SettingsVC
            destVC.delegate = self
        }
    }
    
}

extension GameVC: boardDelegate {
    func getTileState() -> [Tile] {
        return game2048.getTileState()
    }
    
    func getBoardSize() -> Int {
        return game2048.getBoardSize()
    }
}

extension GameVC: settingsDelegate {
    func changeBoardSize(withBoardSize boardSize: Int) {
        self.game2048 = Game(withSize: boardSize)
        self.currBoardSize = boardSize
        self.updateScore()
        boardView.setNeedsDisplay()
    }
}

