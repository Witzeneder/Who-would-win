//
//  CreateContender2ViewController.swift
//  WhoWouldWin
//
//  Created by HP on 26.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit
import SwiftyGiphy

class CreateContender2ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, SwiftyGiphyViewControllerDelegate {

    var name2: String = ""
    var image2: UIImage?
    var gifURL2: String?
    
    // data from previous vcs:
    var categoryClicked: String?
    var isGlobalBattle: Bool?
    var name1: String?
    var image1: UIImage?
    var gifURL1: String?
   
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var camRollButton: UIButton!
    @IBOutlet weak var gifButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            //self.topLabel.transform = CGAffineTransform(translationX: 0, y: -150)
            self.instructionLabel.transform = CGAffineTransform(translationX: 0, y: -60)
            self.continueButton.transform = CGAffineTransform(translationX: 0, y: 60)
            
            // animations when returning from image picker:
            self.imageView.transform = CGAffineTransform(translationX: 0, y: 70)
            self.saveButton.transform = CGAffineTransform(translationX: 0, y: 200)
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        self.imageView.clipsToBounds = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // first view
        topLabel.isHidden = false
        instructionLabel.isHidden = false
        nameTextField.isHidden = false
        continueButton.isHidden = false
        
        // second view
        camRollButton.isHidden = true
        gifButton.isHidden = true
        saveButton.isHidden = true
        imageView.isHidden = true
        
        // reset location of ui elements
        //self.topLabel.transform = CGAffineTransform(translationX: 0, y: 0)
        self.instructionLabel.transform = CGAffineTransform(translationX: 0, y: 0)
        self.nameTextField.transform = CGAffineTransform(translationX: 0, y: 0)
        self.continueButton.transform = CGAffineTransform(translationX: 0, y: 0)
        self.camRollButton.transform = CGAffineTransform(translationX: 0, y: 0)
        self.gifButton.transform = CGAffineTransform(translationX: 0, y: 0)
        self.saveButton.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func continueButton(_ sender: UIButton) {
        
        
        if let name = nameTextField.text {
            
            if name != "" && name.count < 20 {
                name2 = name
                
                UIView.animate(withDuration: 0.25, animations: {
                    // remove name input items from screen
                    self.nameTextField.transform = CGAffineTransform(translationX: 500, y: 0)
                    self.continueButton.transform = CGAffineTransform(translationX: 0, y: 800)
                }) { (finished) in
                    self.nameTextField.isHidden = true
                    self.continueButton.isHidden = true
                    self.buttonFlyIn()
                }
                
            } else if name == "" {
                // error msg if no input
                let alert = UIAlertController(title: "ERROR", message: "Enter a name first.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            } else if name.count >= 20 {
                let alert = UIAlertController(title: "ERROR", message: "Name is too long.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        view.endEditing(true)   //makes sure that the keyboard is closed
        
    }
    
    func buttonFlyIn() {
        instructionLabel.text = "Now, select an image."
        camRollButton.isHidden = false
        gifButton.isHidden = false
        UIView.animate(withDuration: 0.25, animations: {
            self.camRollButton.transform = CGAffineTransform(translationX: 0, y: 30)
            self.gifButton.transform = CGAffineTransform(translationX: 0, y: 120)
        }) { (finished) in
            
        }
    }
    
    @IBAction func camRollButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true) {
            // this code gets executed once the picker gets closed
            self.nameTextField.isHidden = true
            self.continueButton.isHidden = true
            self.camRollButton.isHidden = true
            self.gifButton.isHidden = true
            self.imageView.isHidden = false
            self.saveButton.isHidden = false
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = editedImage
            self.image2 = editedImage
        } else if let origImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = origImage
            self.image2 = origImage
        } else {
            print("error when selecting image")
        }
        
        self.dismiss(animated: true, completion: nil)   // close picker
    }
    
    // ------------------- GIF stuff: START -------------------------------------
    @IBAction func gifButton(_ sender: UIButton) {
        performSegue(withIdentifier: "gifSelector2Segue", sender: self)
    }
    
    func giphyControllerDidSelectGif(controller: SwiftyGiphyViewController, item: GiphyItem) {
        if let gifDownSized = item.downsizedImage {
            imageView.sd_setImage(with: gifDownSized.url)
        }
        
//        if let gifOrig = item.originalImage { // full quality
//            self.gifURL2 = gifOrig.url?.absoluteString
//        }
        if let gifOrig = item.downsizedImage {   // low quality
            self.gifURL2 = gifOrig.url?.absoluteString
        }
        
        // close gif selection controller via delegate
        controller.dismiss(animated: true) {
            print("closed")
            self.nameTextField.isHidden = true
            self.continueButton.isHidden = true
            self.camRollButton.isHidden = true
            self.gifButton.isHidden = true
            self.imageView.isHidden = false
            self.saveButton.isHidden = false
        }
    }
    
    func giphyControllerDidCancel(controller: SwiftyGiphyViewController) {
        print("canceled")
        
    }
    // ------------------- GIF stuff: END -------------------------------------
    
    @IBAction func saveButton(_ sender: UIButton) {
        performSegue(withIdentifier: "createNewBattleSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createNewBattleSegue" {
            if let destVC = segue.destination as? StoreNewBattleViewController {
                
                destVC.categoryClicked = self.categoryClicked
                destVC.isGlobalBattle = self.isGlobalBattle
                destVC.name1 = self.name1
                destVC.image1 = self.image1
                destVC.gifURL1 = self.gifURL1
                destVC.name2 = self.name2
                destVC.image2 = self.image2
                destVC.gifURL2 = self.gifURL2
            }
        }
        
        // bind with the delegate of the gif selector:
        if segue.identifier == "gifSelector2Segue" {
            if let sender = segue.destination as? SwiftyGiphyViewController {
                sender.delegate = self
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
