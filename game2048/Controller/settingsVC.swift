//
//  settingsVC.swift
//  game2048
//
//  Created by Justin Chen on 3/21/19.
//  Copyright © 2019 Justin Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseAuth
import FirebaseFirestore

class SettingsVC: UIViewController {
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var settingsModal: UIView!
    @IBOutlet weak var boardSegControl: UISegmentedControl!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var changeNameButton: UIButton!
    
    var delegate: settingsDelegate?
    
    let authUI = FUIAuth.defaultAuthUI()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI Setup
        settingsModal.layer.cornerRadius = 5
        settingsModal.layer.shadowColor = UIColor.black.cgColor
        settingsModal.layer.shadowOpacity = 1
        settingsModal.layer.shadowOffset = CGSize.zero
        settingsModal.layer.shadowRadius = 10
        
        boardSegControl.selectedSegmentIndex = (delegate?.getBoardSize())! - 3
        dismissButton.layer.cornerRadius = dismissButton.layer.bounds.width/2
        signInButton.layer.cornerRadius = 5
        changeNameButton.layer.cornerRadius = 5

        //Set providers for Firebase Auth
        let providers: [FUIAuthProvider] = [
            FUIEmailAuth()
        ]
        self.authUI?.providers = providers
        
        //Listener for logged-in state
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.userLabel.text = "Signed in as \(user.displayName!)"
                self.changeNameButton.isHidden = false
                self.signInButton.setTitle("Sign Out", for: .normal)
            } else {
                self.userLabel.text = "Not signed in"
                self.changeNameButton.isHidden = true
                self.signInButton.setTitle("Sign In", for: .normal)
            }
        }
        
        
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
            print("Unknown segment index selected")
        }
    }
    
    @IBAction func dismissModal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeName(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            let alert = UIAlertController(title: "Name Change", message: "Enter your desired name", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                let newName = textField!.text!
                self.db.collection("users").document(user.uid).updateData([
                    "name": newName
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func signIn(_ sender: Any) {
        if let _ = Auth.auth().currentUser {
            do {
                //There's probably a more elegant way to handle errors from .signout()
                try Auth.auth().signOut()
            } catch {
                print("Error while signing out")
            }
        } else {
            let authViewController = self.authUI?.authViewController()
            self.present(authViewController!, animated: true, completion: nil)
        }
    }
}
