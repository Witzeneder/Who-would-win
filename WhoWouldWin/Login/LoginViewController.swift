//
//  LoginViewController.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 04.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eMailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var ref: DatabaseReference?
    var refHandle: DatabaseHandle?
    
    
    @IBAction func signInButton(_ sender: CustomButton) {
        var errorMessage = ""

        if eMailTextField.text == "" || passwordTextField.text == ""{
            if eMailTextField.text == "" {
                errorMessage.append("E-Mail ")
            }
            if passwordTextField.text == ""{
                errorMessage.append("Password ")
            }
            passwordTextField.text = ""
            eMailTextField.text = ""
            var alertMessage = "Following fields have to be filled in properly: "
            alertMessage.append(errorMessage)
            let alert = UIAlertController(title: "Error", message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }

        else {
            Auth.auth().signIn(withEmail: eMailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if user != nil {
                    //sign in successfull
                    self.performSegue(withIdentifier: "fromLoginToStart", sender: self)
                }
                else {
                    //there is an error
                    guard let myError = error?.localizedDescription else {
                        self.passwordTextField.text = ""
                        self.eMailTextField.text = ""
                        let alert = UIAlertController(title: "Error", message: "Try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    self.passwordTextField.text = ""
                    self.eMailTextField.text = ""
                    let alert = UIAlertController(title: "Error", message: myError, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })

        }
    }
    
    
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
        // Do any additional setup after loading the view.
    }
}
