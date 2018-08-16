//
//  SettingsViewController.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 27.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: DatabaseReference?
    var refHandle: DatabaseHandle?
    
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    @IBOutlet weak var nextLevelLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var settingsTableView: UITableView!
    
    let sections = ["Profile","Team"]
    let cellLabels = [["User","My Battles"], ["About", "Contact"]]
    var battlesIDs = [String]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        if self.userImage.image == nil {
            let imageName = UIImage(named: "Wait")
            self.userImage?.image = imageName
        }
        // get current user ID
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        getNumberOfBattles(uid: userUID) { (numberOfBattles) in
            if numberOfBattles < 10 {
                self.nextLevelLabel.text = "Create "
                self.nextLevelLabel.text?.append(String(10-numberOfBattles))
                self.nextLevelLabel.text?.append(" Battles to unlock the next level")
                let imageName = UIImage(named: "Beginner")
                self.numberOfPostsLabel.text = "Beginner"
                UIView.transition(with: self.userImage, duration: 0.5, options: .transitionFlipFromTop,animations:{ self.userImage.image = imageName } , completion: nil)
            }
            else if numberOfBattles >= 10 && numberOfBattles < 25 {
                self.nextLevelLabel.text = "Create "
                self.nextLevelLabel.text?.append(String(25-numberOfBattles))
                self.nextLevelLabel.text?.append(" Battles to unlock the next level")
                let imageName = UIImage(named: "Advanced")
                self.numberOfPostsLabel.text = "Advanced"
                UIView.transition(with: self.userImage, duration: 0.5, options: .transitionFlipFromTop,animations:{ self.userImage.image = imageName } , completion: nil)
            }
            else if numberOfBattles >= 25 && numberOfBattles < 45 {
                self.nextLevelLabel.text = "Create "
                self.nextLevelLabel.text?.append(String(45-numberOfBattles))
                self.nextLevelLabel.text?.append(" Battles to unlock the next level")
                let imageName = UIImage(named: "Profi")
                self.numberOfPostsLabel.text = "Profi"
                UIView.transition(with: self.userImage, duration: 0.5, options: .transitionFlipFromTop,animations:{ self.userImage.image = imageName } , completion: nil)
            }
            else if numberOfBattles >= 45 {
                self.nextLevelLabel.text = "Every level unlocked - more levels comming soon"
                let imageName = UIImage(named: "Expert")
                self.numberOfPostsLabel.text = "Expert"
                UIView.transition(with: self.userImage, duration: 0.5, options: .transitionFlipFromTop,animations:{ self.userImage.image = imageName } , completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("test")

    }
    
    /// Get the current User ID for the User
    ///
    /// - Parameters:
    ///   - uid: The User ID of the current User
    ///   - completion: the number of Battles the user created
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
                        else{
                            completion(0)
                        }
                    }
                }
            }
        }
    }
    
    /// Get the Battles of the User
    ///
    /// - Parameters:
    ///   - uid: The User ID of the current User
    ///   - completion: The Battles of the current User
    func getUserBattles(uid: String, completion: @escaping (String,UInt) -> Void){
        ref = Database.database().reference()
        ref?.child("Users").observeSingleEvent(of: .value) { (snapshot) in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot{
                if let dic = rest.value as? [String:AnyObject]{
                    if dic["uid"] as? String == uid{
                        if (dic["battles"] != nil) {
                            guard let numberOfBattles = dic["battles"]?.childrenCount else {return}
                            completion(rest.key,numberOfBattles)
                        } else {
                            print("No battles")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func signOutButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sign out", message: "Do you really want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            do {
                try Auth.auth().signOut()
                self.present(self.storyboard!.instantiateViewController(withIdentifier: "Login") as UIViewController, animated: true, completion: nil)
            } catch let logOutError {
                print(logOutError)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == 0{          performSegue(withIdentifier: "fromSettingsToProfile", sender: self)}
            else if indexPath.row == 1{     performSegue(withIdentifier: "fromSettingsToBattles", sender: self)}
        }
            
        else if indexPath.section == 1{
            if indexPath.row == 0{          performSegue(withIdentifier: "fromSettingsToAbout", sender: self)}
            else if indexPath.row == 1{     performSegue(withIdentifier: "fromSettingsToContact", sender: self)}
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellLabels[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.textLabel?.text = cellLabels[indexPath.section][indexPath.row]
        
        let imageName = UIImage(named: cellLabels[indexPath.section][indexPath.row])
        cell.imageView?.image = imageName
        
        return cell
    }
}
