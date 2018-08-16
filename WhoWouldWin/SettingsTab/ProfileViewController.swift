//
//  ProfileViewController.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 28.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var usermail: UILabel!
    @IBOutlet weak var usercount: UILabel!
    var ref: DatabaseReference?
    var refHandle: DatabaseHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        getNumberOfBattles(uid: userUID) { (numberOfBattles) in
            self.usercount.text = String(numberOfBattles)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageName = UIImage(named: "Profile")
        profileImageView?.image = imageName
        profileImageView.layer.cornerRadius = 20
        usermail.text = Auth.auth().currentUser?.email
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        getUsernameFromUID(uid: userUID) { (userName) in
            self.username.text = userName
        }
    }
    
    
    /// Provides the number of Battles of the current User
    ///
    /// - Parameters:
    ///   - uid: The User ID from the current User
    ///   - completion: the number of Battles the current User created
    func getNumberOfBattles(uid: String, completion: @escaping (Int) -> Void){
        ref = Database.database().reference()
        ref?.child("Users").observeSingleEvent(of: .value) { (snapshot) in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot{
                if let dic = rest.value as? [String:AnyObject]{
                    if dic["uid"] as? String == uid{
                        if (dic["battles"] != nil) {
                            if let battles = dic["battles"] as? [String:String]{
                                completion(battles.count)
                            }else {
                            completion(0)
                            }
                        }
                    }
                }
            }
        }
    }

    /// Provides the Username
    ///
    /// - Parameters:
    ///   - uid: The User ID from the current User
    ///   - completion: The username
    func getUsernameFromUID(uid: String, completion: @escaping (String) -> Void) {
        ref = Database.database().reference()
        ref?.child("Users").observeSingleEvent(of: .value) { (snapshot) in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot{
                if let dic = rest.value as? [String:AnyObject]{
                    if dic["uid"] as? String == uid{
                        completion(dic["name"] as! String)
                    }
                }
            }
        }
    }

}
