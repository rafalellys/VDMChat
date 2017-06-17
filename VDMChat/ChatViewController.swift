//
//  ChatViewController.swift
//  VDMChat
//
//  Created by Rafael on 2017-06-16.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit
import FirebaseDatabase


class ChatViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var textViewFixedHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var messages = [FirebaseMessage]()
    var firebaseRef: DatabaseReference?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Tap to dimiss keyboard
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        //nav bar color config
        self.navigationItem.title = "Vidao Chat Board"
        self.navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 0.18, green: 0.64, blue: 0.99, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        //observer for keyboard activity
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        
        //Firebase
        self.firebaseRef = Database.database().reference().child("messages")
        
        self.firebaseRef?.observe(DataEventType.value, with: { (snapshot) in
            
            let dict = snapshot.value as? NSDictionary
            
            if dict != nil {
                
                self.messages.removeAll()
                
                let firebaseMessages = dict!.allValues as NSArray
                
                for value in firebaseMessages {
                    let dictValue = value as! NSDictionary
                    
                    let firebaseMessage = FirebaseMessage()
                    firebaseMessage.username = dictValue["username"] as? String
                    firebaseMessage.message = dictValue["message"] as? String
                    firebaseMessage.date = dictValue["date"] as! TimeInterval
                    
                    self.messages.append(firebaseMessage)
                }
                
                self.messages.sort(by: { (first, second) -> Bool in
                    return second.date > first.date
                })
                
                
                self.tableView.reloadData()
                
                self.enableFixedTextViewHeightConstraint(enable: false)
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    
                    if self.messages.count > 0 {
                        let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                        self.tableView.scrollToRow(at:indexPath , at: UITableViewScrollPosition.bottom, animated: true)
                    }
                })
            }
            
            
        })
        
    }
    
    //keyboard activity
    func keyboardWillShow(notification:Notification) {
        let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let height = value.cgRectValue.size.height
        bottomConstraint.constant = height
    }
    
    func keyboardWillHide() {
        bottomConstraint.constant = 0
    }
    
    func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
        if let message = self.textView.text {
            if message.characters.count > 0 {
                
                var username = MemoryStorage.instance.username
                
                if username == nil {
                    username = "Anonymous"
                }
                
                let now = NSDate()
                
                let firebaseMessage = ["username": username!,
                                       "message":message,
                                       "date":now.timeIntervalSince1970] as [String : Any]
                
                
                self.firebaseRef?.childByAutoId().setValue(firebaseMessage)
                
                
                self.textView.text = ""
                
                self.tableView.reloadData()
                
                self.enableFixedTextViewHeightConstraint(enable: false)
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    
                    if self.messages.count > 0 {
                        let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                        self.tableView.scrollToRow(at:indexPath , at: UITableViewScrollPosition.bottom, animated: true)
                    }
                })
            }
        }
        
    }
    
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        print(self.textView.contentSize.height)
        enableFixedTextViewHeightConstraint(enable: self.textView.contentSize.height >= 137)
    }
    
    
    func enableFixedTextViewHeightConstraint(enable:Bool) {
        
        print ("enable " + String(enable))
        
        if enable {
            
            if !self.textView.constraints.contains(self.textViewFixedHeightConstraint) {
                
                self.textView.isScrollEnabled = true
                
                self.textView.addConstraint(self.textViewFixedHeightConstraint)
                
                self.textView.invalidateIntrinsicContentSize()
                
                print ("ENABLED")
                
            }
            
            
            
        } else {
            
            if self.textView.constraints.contains(self.textViewFixedHeightConstraint) {
                
                self.textView.isScrollEnabled = false
                
                self.textView.removeConstraint(self.textViewFixedHeightConstraint)
                
                self.textView.invalidateIntrinsicContentSize()
                
                print("DISABLED")
                
            }
            
        }
        
    }
    
    
    // MARK : - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewCell", for: indexPath) as! TableViewCell
        
        
        let firebaseMessage = self.messages[indexPath.row]
        let fullMessage = firebaseMessage.username! + ": " + firebaseMessage.message!
        
        cell.content.text = fullMessage
        
        return cell
        
        
        
    }
    
    //Go to username screen
    @IBAction func goToUsernameScreen(_ sender: Any) {
        
        performSegue(withIdentifier: "SegueToUsernameViewController", sender: self)
        
        
    }
    
}
