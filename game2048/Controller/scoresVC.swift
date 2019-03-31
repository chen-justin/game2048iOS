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
    
    var topScores: [Score] = []
    
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
        
        //Table setup
        scoreTable.delegate = self
        scoreTable.dataSource = self
        
        //Grab top scores from DB
        db.collection("users").order(by: "score", descending: true).limit(to: 10).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    let score = document.data()["score"] as! Int
                    //If no name, default to "Anon"
                    let name: String = document.data()["name"] as? String ?? "Anon"
                    self.topScores.append(Score(name: name, score: score))
                }
                
                //Refresh table
                self.scoreTable.reloadData()
            }
        }
        
    }
    
    @IBAction func dismissScores(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topScores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newScore = topScores[indexPath.row]
        let scoreCell: ScoreCell = scoreTable.dequeueReusableCell(withIdentifier: "scoreCell") as! ScoreCell
        scoreCell.setScore(withScore: newScore, rank: indexPath.row + 1)
        return scoreCell
    }
    
}

class ScoreCell: UITableViewCell {
    
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    func setScore(withScore score: Score, rank: Int) {
        scoreLabel.text = "\(score.score)"
        userLabel.text = score.name
        rankLabel.text = "\(rank)"
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
