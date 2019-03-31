//
//  scoresVC.swift
//  game2048
//
//  Created by Justin Chen on 3/21/19.
//  Copyright © 2019 Justin Chen. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ScoresVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()

    var top3x3: [Score] = []
    var top4x4: [Score] = []
    var top5x5: [Score] = []
    var top6x6: [Score] = []
    
    @IBOutlet weak var scoreSegControl: UISegmentedControl!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var scoreModal: UIView!
    @IBOutlet weak var scoreTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI Setup
        scoreModal.layer.cornerRadius = 5
        scoreModal.layer.shadowColor = UIColor.black.cgColor
        scoreModal.layer.shadowOpacity = 1
        scoreModal.layer.shadowOffset = CGSize.zero
        scoreModal.layer.shadowRadius = 10
        
        scoreTable.layer.cornerRadius = 5
        scoreTable.layer.shadowColor = UIColor.black.cgColor
        scoreTable.layer.shadowOpacity = 1
        scoreTable.layer.shadowOffset = CGSize.zero
        scoreTable.layer.shadowRadius = 10
        
        dismissButton.layer.cornerRadius = dismissButton.layer.bounds.width/2
        
        scoreSegControl.layer.cornerRadius = 5
        
        //Table setup
        scoreTable.delegate = self
        scoreTable.dataSource = self
        
        //Grab top scores from DB
        grabScores()
        
    }
    
    func grabScores() {
        //Will probably want to find a more streamlined way of doing this
        db.collection("users").order(by: "3x3", descending: true).limit(to: 10).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let score = document.data()["3x3"] as! Int
                    //If no name, default to "Anon"
                    let name: String = document.data()["name"] as? String ?? "Anon"
                    self.top3x3.append(Score(name: name, score: score))
                }
                self.scoreTable.reloadData()
            }
        }
        db.collection("users").order(by: "4x4", descending: true).limit(to: 10).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let score = document.data()["4x4"] as! Int
                    //If no name, default to "Anon"
                    let name: String = document.data()["name"] as? String ?? "Anon"
                    self.top4x4.append(Score(name: name, score: score))
                }
                self.scoreTable.reloadData()
            }
        }
        db.collection("users").order(by: "5x5", descending: true).limit(to: 10).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let score = document.data()["5x5"] as! Int
                    //If no name, default to "Anon"
                    let name: String = document.data()["name"] as? String ?? "Anon"
                    self.top5x5.append(Score(name: name, score: score))
                }
                self.scoreTable.reloadData()
            }
        }
        db.collection("users").order(by: "6x6", descending: true).limit(to: 10).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let score = document.data()["6x6"] as! Int
                    //If no name, default to "Anon"
                    let name: String = document.data()["name"] as? String ?? "Anon"
                    self.top6x6.append(Score(name: name, score: score))
                }
                self.scoreTable.reloadData()
            }
        }
    }
    
    @IBAction func dismissScores(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch scoreSegControl.selectedSegmentIndex {
        case 0:
            //3x3
            return top3x3.count
        case 1:
            //4x4
            return top4x4.count
        case 2:
            //5x5
            return top5x5.count
        case 3:
            //6x6
            return top6x6.count
        default:
            print("Unknown segment index selected")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var newScore: Score?
        switch scoreSegControl.selectedSegmentIndex {
        case 0:
            //3x3
            newScore = top3x3[indexPath.row]
        case 1:
            //4x4
            newScore = top4x4[indexPath.row]
        case 2:
            //5x5
            newScore = top5x5[indexPath.row]
        case 3:
            //6x6
            newScore = top6x6[indexPath.row]
        default:
            print("Unknown segmented Index selected")
            newScore = nil
            break
        }
        
        let scoreCell: ScoreCell = scoreTable.dequeueReusableCell(withIdentifier: "scoreCell") as! ScoreCell
        scoreCell.setScore(withScore: newScore!, rank: indexPath.row + 1)
        return scoreCell
    }
    
    @IBAction func tableSegChange(_ sender: Any) {
        self.scoreTable.reloadData()
    }
}

class ScoreCell: UITableViewCell {
    
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    func setScore(withScore score: Score, rank: Int) {
        userLabel.text = "\(score.score)"
        scoreLabel.text = score.name
        rankLabel.text = String(format: "%03d", rank)
    }
}

class Score {
    
    let name: String
    let score: Int
    
    init(name: String, score: Int) {
        self.name = name
        self.score = score
    }
}
