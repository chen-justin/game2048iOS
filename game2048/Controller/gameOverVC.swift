//
//  gameOverVC.swift
//  game2048
//
//  Created by Justin Chen on 3/29/19.
//  Copyright © 2019 Justin Chen. All rights reserved.
//

import UIKit

class GameOverVC: UIViewController {
    
    @IBOutlet weak var tryAgainButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tryAgainButton.layer.cornerRadius = 5
        
    }

    @IBAction func tryAgain(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
