//
//  UsernameViewController.swift
//  VDMChat
//
//  Created by Rafael on 2017-06-16.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

class UsernameViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        
        
        self.navigationController?.navigationBar.backgroundColor = UIColor(colorLiteralRed: 0.5, green: 0.5, blue: 1, alpha: 1)

        
        
        if let username = MemoryStorage.instance.username {
            self.username.text = username
            self.label.text = "Your username is"
        }
        
        
    }
    
    
    // MARK : - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var username:String? = self.username.text
        
        if username?.characters.count == 0 {
            username = nil
        }
        
        MemoryStorage.instance.username = username
        self.navigationController?.popViewController(animated: true)
        return true
    }
    
    
}

