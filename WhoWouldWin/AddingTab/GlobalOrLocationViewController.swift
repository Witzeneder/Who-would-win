//
//  GlobalOrLocationViewController.swift
//  WhoWouldWin
//
//  Created by HP on 25.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit

class GlobalOrLocationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var categories = ["Beauty Contest", "Dance Battle", "Fight", "Rap Battle"]
    var categoryClicked: String = "Beauty Contest"   // default: First picker entry
    var isGlobalBattle: Bool = true
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var globalButton: UIButton!
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var helpOverlay: UIView!
    @IBOutlet weak var helpButton: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        infoLabel.text = "First, select a category."
        UIView.animate(withDuration: 0.5) {
            self.infoLabel.transform = CGAffineTransform(translationX: 0, y: -150)
            self.categoryPicker.transform = CGAffineTransform(translationX: 0, y: 0)
            self.continueButton.transform = CGAffineTransform(translationX: 0, y: 150)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationButton.isHidden = true
        globalButton.isHidden = true
        categoryPicker.isHidden = false
        continueButton.isHidden = false
        helpOverlay.isHidden = true
        helpButton.isHidden = true
        
        self.infoLabel.transform = CGAffineTransform(translationX: 0, y: 0)
        self.categoryPicker.transform = CGAffineTransform(translationX: 0, y: 0)
        self.continueButton.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    @IBAction func continueButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            self.continueButton.transform = CGAffineTransform(translationX: 0, y: 800)
            self.categoryPicker.transform = CGAffineTransform(translationX: 600, y: 0)
        }) { (finished) in
            self.continueButton.isHidden = true
            self.categoryPicker.isHidden = true
            self.buttonFlyIn()
        }
    }
    
    func buttonFlyIn() {
        infoLabel.text = "Now, select the location type."
        globalButton.isHidden = false
        locationButton.isHidden = false
        self.helpButton.isHidden = false
        UIView.animate(withDuration: 0.25, animations: {
            self.globalButton.transform = CGAffineTransform(translationX: 0, y: -50)
            self.locationButton.transform = CGAffineTransform(translationX: 0, y: 50)
        }) { (finished) in
            
        }
    }
    
    @IBAction func helpDownButton(_ sender: CustomButton) {
        helpOverlay.isHidden = false
        UIView.animate(withDuration: 0.35, animations: {
            self.helpOverlay.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (finished) in

        }
    }

    @IBAction func helpUpButton(_ sender: CustomButton) {
        UIView.animate(withDuration: 0.35, animations: {
            self.helpOverlay.transform = CGAffineTransform(scaleX: 0, y: 0)
        }) { (finished) in
            self.helpOverlay.isHidden = true
        }
    }
    
    @IBAction func globalButton(_ sender: UIButton) {
        isGlobalBattle = true
        performSegue(withIdentifier: "createCont1Segue", sender: self)
    }
    @IBAction func locationButton(_ sender: UIButton) {
        isGlobalBattle = false
        performSegue(withIdentifier: "createCont1Segue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createCont1Segue" {
            if let destVC = segue.destination as? CreateContender1ViewController {
                
                destVC.categoryClicked = self.categoryClicked
                destVC.isGlobalBattle = self.isGlobalBattle
                
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let rowTitle = categories[row]
        let attributedTitle = NSAttributedString(string: rowTitle, attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        return attributedTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryClicked = categories[row]
    }
    
    func animatePicker() {
        
    }
    
}
