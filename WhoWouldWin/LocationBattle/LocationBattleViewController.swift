//
//  LocationBattleViewController.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 10.01.18.
//  Copyright © 2018 HPJSVW. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase

class LocationBattleViewController: UIViewController, CLLocationManagerDelegate {

    var ref:DatabaseReference?
    var refHandle: DatabaseHandle?
    
    let manager = CLLocationManager()
        
        
    override func viewWillAppear(_ animated: Bool) {
        manager.delegate = self
        //100 meters is the accurayc: possible changes -> 10m or bestpossible
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        ref = Database.database().reference()
        //var arr: [Double] = [(manager.location?.coordinate.latitude)!, (manager.location?.coordinate.longitude)!]
        
        let dic: Dictionary = [
            "Longitude" : manager.location?.coordinate.longitude,
            "Latitude" : manager.location?.coordinate.latitude
        ]
        
        
        ref?.child("Locations").childByAutoId().setValue(dic)
        
        
        
    }
    
    //var location = CLLocationCoordinate2D(latitude: 10.30, longitude: 44.34)
        
    //checks in 10km radius
    func locationIsInRange(myLocation: CLLocation, surveyLocation: CLLocation) -> Bool {
        if myLocation.distance(from: surveyLocation) < 10000 {
            return true
        }
        return false
    }
    
    
        
        
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
        
    /*
        // MARK: - Navigation
     
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        }
        */
        
}


