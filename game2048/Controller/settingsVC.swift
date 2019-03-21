//
//  settingsVC.swift
//  game2048
//
//  Created by Justin Chen on 3/21/19.
//  Copyright © 2019 Justin Chen. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBOutlet weak var settingsModal: UIView!
    
    @IBOutlet weak var boardSegControl: UISegmentedControl!
    
    var delegate: settingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Drop shadow for modal
        settingsModal.layer.cornerRadius = 5
        settingsModal.layer.shadowColor = UIColor.black.cgColor
        settingsModal.layer.shadowOpacity = 1
        settingsModal.layer.shadowOffset = CGSize.zero
        settingsModal.layer.shadowRadius = 10
        //settingsModal.layer.shadowPath = UIBezierPath(rect: settingsModal.bounds).cgPath

        dismissButton.layer.cornerRadius = dismissButton.layer.bounds.width/2
        
    }
    
    @IBAction func didSegChange(_ sender: Any) {
        switch boardSegControl.selectedSegmentIndex {
        case 0:
            //3x3
            delegate?.changeBoardSize(withBoardSize: 3)
        case 1:
            //4x4
            delegate?.changeBoardSize(withBoardSize: 4)
        case 2:
            //5x5
            delegate?.changeBoardSize(withBoardSize: 5)
        case 3:
            //6x6
            delegate?.changeBoardSize(withBoardSize: 6)
        default:
            print("Error!")
        }
    }
    @IBAction func dismissModal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
