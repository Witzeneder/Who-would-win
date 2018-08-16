//
//  NewUserViewController.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 04.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit
import Firebase

class NewUserViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var eMailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var ref: DatabaseReference?
    var refHandle: DatabaseHandle?
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: CustomButton) {
        var nickName = ""
        var myEmail = ""
        var password = ""
        
        var isNameValid = false
        var isEMailValid = false
        var isPasswordValid = false
        var isPasswordConfValid = false
        
        
        if nameTextField.text != "" {
            nickName = nameTextField.text!
            isNameValid = true
        }
        
        if eMailTextField.text != "" {
            myEmail = eMailTextField.text!
            
            isEMailValid = true
        }
        
        if passwordTextField.text != "" {
            password = passwordTextField.text!
            if password.count >= 6 {
                isPasswordValid = true
            }
        }
        
        if passwordConfirmTextField.text != "" {
            isPasswordConfValid = true
        }
        
        
        if isNameValid != true || isEMailValid != true || isPasswordValid != true || isPasswordConfValid != true{
            var alertMessage = ""
            if isNameValid != true {
                alertMessage.append("Nickname ")
            }
            if isEMailValid != true {
                alertMessage.append("| E-Mail ")
            }
            if isPasswordValid != true {
                alertMessage.append("| Password ")
            }
            if isPasswordConfValid != true {
                alertMessage.append("| Password Conformation")
            }
            
            nameTextField.text = ""
            eMailTextField.text = ""
            passwordTextField.text = ""
            passwordConfirmTextField.text = ""
            
            var errorMessage = "Following field(s) has/have to be filled in correctly (password size at least 6): "
            errorMessage.append(alertMessage)
            
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else if passwordTextField.text != passwordConfirmTextField.text{
            
            passwordTextField.text = ""
            passwordConfirmTextField.text = ""
            let alert = UIAlertController(title: "Error", message: "Password and Password Conformation have to be exectly the same input!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else{
            // check user data with database
            firebaseCheckDatabase(nickName: nickName, myEmail: myEmail, password: password) { (success, nameExists, mailExists) in
                if success {
                    self.authentificateUser(nickName: nickName, myEmail: myEmail, password: password)
                    self.performSegue(withIdentifier: "fromCreateToLogin", sender: self)
                } else{
                    var errorMessage = ""
                    if nameExists {
                        self.nameTextField.text = ""
                        errorMessage.append("Nickname ")
                    }
                    if mailExists {
                        self.eMailTextField.text = ""
                        errorMessage.append("E-Mail ")
                    }
                    errorMessage.append("is/are already in use!")
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    /// Stores the user into the database
    ///
    /// - Parameters:
    ///   - nickName: -
    ///   - myEmail: -
    ///   - password: -
    func authentificateUser(nickName: String, myEmail: String, password: String){
        // store new user account in firebase:
        
        Auth.auth().createUser(withEmail: myEmail, password: password) { (user, error) in
                if error != nil {
                    print("Error in Authentication: ", error ?? "unknown error")
                    return
                }
                print("user successfully authenticated")
                
                //store USER into DATABASE
                let userDB = self.ref?.child("Users").childByAutoId()
                userDB?.setValue(["name": nickName, "email" : myEmail, "uid": user?.uid])
        }
    }
    
    
    /// Checks if there is already a user with same user data
    ///
    /// - Parameters:
    ///   - nickName: -
    ///   - myEmail: -
    ///   - password: -
    ///   - completion: -
    func firebaseCheckDatabase(nickName: String, myEmail: String, password: String, completion: @escaping (Bool, Bool, Bool) -> Void){
        //check if User already exists
        var checkDB = true
        var nameExists = false
        var mailExists = false
        self.ref = Database.database().reference()
        
        self.ref?.child("Users").observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                if let dic = rest.value as? [String:AnyObject]{
                    if dic["name"] as? String == nickName {
                        checkDB = false
                        nameExists = true
                    }
                    let email = dic["email"] as? String
                    if email?.lowercased() == myEmail.lowercased() {
                        checkDB = false
                        mailExists = true
                    }
                }
            }
            completion(checkDB, nameExists, mailExists)
        })
    }
    
    
    /// If editing change some style
    ///
    /// - Parameter textField: the textfield which is edited
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let totalHeight = view.frame.height
        let textFieldY = textField.frame.origin.y
        let textFieldDistanceFromBottom = totalHeight - textFieldY
        
        let offset = 280 - textFieldDistanceFromBottom
        
        
        if offset > 0 {
            UIView.animateKeyframes(withDuration: 0.9, delay: 0.0, options: [], animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: offset + 10), animated: false)
                })
                
                UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: offset - 3), animated: false)
                })
                
                UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
                })
                
            }, completion: nil)
        } else {
            UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: [], animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
                    textField.transform = CGAffineTransform(translationX: 0, y: 10)
                })
                
                UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
                    textField.transform = CGAffineTransform(translationX: 0, y: -5)
                })
                
                UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                    textField.transform = CGAffineTransform(translationX: 0, y: 0)
                })
                
            }, completion: nil)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
