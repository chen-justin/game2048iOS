//
//  scoresVC.swift
//  game2048
//
//  Created by Justin Chen on 3/21/19.
//  Copyright © 2019 Justin Chen. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ScoresVC: UIViewController {
    
    @IBOutlet weak var scoreSegControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return nil
//    }
    
}

class ScoreCell: UITableViewCell {
    
}

class Score {
    
    let name: String
    let score: Int
    
    init(name: String, score: Int) {
        self.name = name
        self.score = score
    }
}
