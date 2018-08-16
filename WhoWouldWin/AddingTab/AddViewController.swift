//
//  AddViewController.swift
//  WhoWouldWin
//
//  Created by HP on 11.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreLocation

class AddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    var ref: DatabaseReference?
    var refHandle: DatabaseHandle?
    let manager = CLLocationManager()
    var categories = ["Beauty Contest", "Dance Battle", "Fight", "Rap Battle"]
    var categoryClicked: String = "Beauty Contest"   // default: First picker entry
    var battleCount: UInt = 0
    var globalOrLocation: Int = 0
    
    @IBOutlet weak var locationSegControl: UISegmentedControl!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var name1Label: UITextField!
    @IBOutlet weak var name2Label: UITextField!
    
    
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        
        if globalOrLocation == 0 {
            let battleRef = ref?.child("Categories").child(categoryClicked).childByAutoId()
            
            //write in the actual data
            battleRef?.child("Contender 1").setValue(["Name": name1Label.text ?? "Contender 1", "Votes" : 0])
            battleRef?.child("Contender 2").setValue(["Name": name2Label.text ?? "Contender 2", "Votes" : 0])
        }
        else if globalOrLocation == 1{
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            guard let latitude:Double = manager.location?.coordinate.latitude else {return}
            guard let longitude:Double = manager.location?.coordinate.longitude else {return}
            
            //write in the actual data
            let battleRef = ref?.child("Locations").childByAutoId()
            battleRef?.setValue(["Latitude": latitude, "Longitude": longitude, "Category": categoryClicked])
            battleRef?.child("Contender 1").setValue(["Name": name1Label.text ?? "Contender 1", "Votes": 0])
            battleRef?.child("Contender 2").setValue(["Name": name2Label.text ?? "Contender 2", "Votes": 0])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        ref?.child("Categories").child(categoryClicked).observeSingleEvent(of: .value, with: { (snapshot) in
            self.battleCount = snapshot.childrenCount
        })
    }

    @IBAction func GlobalOrLocationBattle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            globalOrLocation = 0
        }
        else{
            globalOrLocation = 1
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
        let attributedTitle = NSAttributedString(string: rowTitle, attributes: [NSAttributedStringKey.foregroundColor : UIColor.black])
        return attributedTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryClicked = categories[row]
    }
}
