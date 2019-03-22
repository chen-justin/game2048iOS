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

class ViewController: UIViewController {
    
    var game2048: Game = Game()
    var currBoardSize = 4
    var bestScore = 0
    
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
        case.right:
            game2048.right()
            boardView.setNeedsDisplay()
            updateScore()
        case .up:
            game2048.up()
            boardView.setNeedsDisplay()
            updateScore()
        case .down:
            game2048.down()
            boardView.setNeedsDisplay()
            updateScore()
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

extension ViewController: boardDelegate {
    func getTileState() -> [Tile] {
        return game2048.getTileState()
    }
    
    func getBoardSize() -> Int {
        return game2048.getBoardSize()
    }
}

extension ViewController: settingsDelegate {
    func changeBoardSize(withBoardSize boardSize: Int) {
        self.game2048 = Game(withSize: boardSize)
        self.currBoardSize = boardSize
        self.updateScore()
        boardView.setNeedsDisplay()
    }
}

