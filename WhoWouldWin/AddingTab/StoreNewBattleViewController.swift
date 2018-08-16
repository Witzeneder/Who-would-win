//
//  StoreNewBattleViewController.swift
//  WhoWouldWin
//
//  Created by HP on 26.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import FirebaseStorage

class StoreNewBattleViewController: UIViewController, CLLocationManagerDelegate {

    @IBAction func backToBattle(_ sender: UIButton) {
        self.present(self.storyboard!.instantiateViewController(withIdentifier: "CustomTabBar") as UIViewController, animated: true, completion: nil)
    }
    
    // data passed from previous VCs:
    var categoryClicked: String?
    var isGlobalBattle: Bool?
    var name1: String?
    var name2: String?
    var image1: UIImage?
    var image2: UIImage?
    var gifURL1: String?
    var gifURL2: String?
    
    // urls (either for gif or png)
    var isAGif1: Bool = false
    var isAGif2: Bool = false
    var dbImageURL1: URL?
    var dbImageURL2: URL?
    
    // data for database storage:
    var ref: DatabaseReference?
    var refHandle: DatabaseHandle?
    let manager = CLLocationManager()
    var battleCount: UInt = 0
    var globalOrLocation: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        storeInDatabase()
        
        image1 = UIImage(named: "placeholder.png")
        image2 = UIImage(named: "placeholder.png")
    }
    
    func storeBattlesInUser(uid: String, keyString: String) {
        ref = Database.database().reference()
        ref?.child("Users").observeSingleEvent(of: .value) { (snapshot) in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot{
                if let dic = rest.value as? [String:AnyObject]{
                    if dic["uid"] as? String == uid{
                        let myRef = rest.ref
                        myRef.child("battles").childByAutoId().setValue(keyString)
                    }
                }
            }
        }
    }

    
    
    func storeInDatabase() {
        guard let isGlobal = isGlobalBattle else {
            print("isglobal nil")
            return
        }
        guard let category = categoryClicked else {
            print("cat nil")
            return
        }
        guard let nameC1 = name1 else {
            print("n1 nil")
            return
        }
        guard let nameC2 = name2 else {
            print("n2 nil")
            return
        }
        
        if image1 != nil {
            isAGif1 = false
        } else {
            isAGif1 = true
        }
        if image2 != nil {
            isAGif2 = false
        } else {
            isAGif2 = true
        }
        

        
        if isGlobal {

            let battleRef = ref?.child("Categories").child(category).childByAutoId()
            
            if isAGif1 {
                battleRef?.child("Contender 1").setValue(["Name": nameC1, "Votes" : 0, "Image": gifURL1!])
            } else {   // PNG:
                
                if let imgData = UIImageJPEGRepresentation(image1!, 0) { // 0 means lowest compression
                    let randomID = NSUUID().uuidString
                    let storageRef = Storage.storage().reference().child(randomID + ".jpg")
                    let uploadTask = storageRef.putData(imgData, metadata: nil, completion: { (metadata, error) in
                        
                        guard let metadata = metadata else {
                            print("----An error occurred!")
                            return
                        }
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        guard let imgURL = metadata.downloadURL()?.absoluteString else {
                            print("error when fetching download url")
                            return
                        }
                        
                        battleRef?.child("Contender 1").setValue(["Name": nameC1, "Votes" : 0, "Image": imgURL])
                    })
                }
            }
                
            if isAGif2 {
                battleRef?.child("Contender 2").setValue(["Name": nameC2, "Votes" : 0, "Image": gifURL2!])
            } else {   // PNG:
                if let imgData = UIImageJPEGRepresentation(image2!, 0) { // 0 means lowest compression
                    
                    let randomID = NSUUID().uuidString
                    let storageRef = Storage.storage().reference().child(randomID + ".png")
                    let uploadTask = storageRef.putData(imgData, metadata: nil, completion: { (metadata, error) in
                        
                        guard let metadata = metadata else {
                            print("----An error occurred!")
                            return
                        }
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        guard let imgURL = metadata.downloadURL()?.absoluteString else {
                            print("error when fetching download url")
                            return
                        }
                        
                        battleRef?.child("Contender 2").setValue(["Name": nameC2, "Votes" : 0, "Image": imgURL])
                    })
                }
            }
       
            guard let myUID = Auth.auth().currentUser?.uid else {return}
            guard let myKeyString = battleRef?.key else {return}
            storeBattlesInUser(uid: myUID, keyString: myKeyString)
            
            battleRef?.child("user").setValue(myUID)
            

        } else {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            guard let latitude:Double = manager.location?.coordinate.latitude else {return}
            guard let longitude:Double = manager.location?.coordinate.longitude else {return}
            print("getting in ------------------")
            //write in the actual data
            let battleRef = ref?.child("Locations").childByAutoId()
            battleRef?.setValue(["Latitude": latitude, "Longitude": longitude, "Category": category])
//            battleRef?.child("Contender 1").setValue(["Name": nameC1, "Votes": 0])
//            battleRef?.child("Contender 2").setValue(["Name": nameC2, "Votes": 0])
            
            guard let myUID = Auth.auth().currentUser?.uid else {return}
            guard let myKeyString = battleRef?.key else {return}
            storeBattlesInUser(uid: myUID, keyString: myKeyString)
            
            battleRef?.child("user").setValue(myUID)
            
            // add images ---------
            if isAGif1 {
                battleRef?.child("Contender 1").setValue(["Name": nameC1, "Votes" : 0, "Image": gifURL1!])
            } else {   // PNG:
                if let imgData = UIImageJPEGRepresentation(image1!, 0) { // 0 means lowest compression
                    
                    let randomID = NSUUID().uuidString
                    let storageRef = Storage.storage().reference().child(randomID + ".png")
                    let uploadTask = storageRef.putData(imgData, metadata: nil, completion: { (metadata, error) in
                        
                        guard let metadata = metadata else {
                            print("----An error occurred!")
                            return
                        }
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        guard let imgURL = metadata.downloadURL()?.absoluteString else {
                            print("error when fetching download url")
                            return
                        }
                        
                        battleRef?.child("Contender 1").setValue(["Name": nameC1, "Votes" : 0, "Image": imgURL])
                    })
                }
            }
            
            if isAGif2 {
                battleRef?.child("Contender 2").setValue(["Name": nameC2, "Votes" : 0, "Image": gifURL2!])
            } else {   // PNG:
                if let imgData = UIImageJPEGRepresentation(image2!, 0) { // 0 means lowest compression
                    
                    let randomID = NSUUID().uuidString
                    let storageRef = Storage.storage().reference().child(randomID + ".png")
                    let uploadTask = storageRef.putData(imgData, metadata: nil, completion: { (metadata, error) in
                        
                        guard let metadata = metadata else {
                            print("----An error occurred!")
                            return
                        }
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        guard let imgURL = metadata.downloadURL()?.absoluteString else {
                            print("error when fetching download url")
                            return
                        }
                        
                        battleRef?.child("Contender 2").setValue(["Name": nameC2, "Votes" : 0, "Image": imgURL])
                    })
                }
            }
        }
    }
}
