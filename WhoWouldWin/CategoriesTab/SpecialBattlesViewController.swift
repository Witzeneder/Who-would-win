//
//  SpecialBattlesViewController.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 05.02.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit
import Firebase

class SpecialBattlesViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    
    struct battleStruct {
        var Category: String
        var ID: String
        var Contender1: String
        var Image1: String?
        var Votes1: Int
        var Contender2: String
        var Image2: String?
        var Votes2: Int
        var TotalVotes: Int
    }
    
    var ref: DatabaseReference?
    var refHandle: DatabaseHandle?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noBattlesLeftView: UIView!
    @IBOutlet weak var noBattlesLeftImageView: UIImageView!
    @IBOutlet weak var centerCircleImage: UIImageView!
    @IBOutlet weak var centerCircle: UIView!
    
    var randomIndexBattle = 0
    
    var myBattlesCat = [battleStruct]()
    var kindOfBattle = -1
    var hasVotedFor1: Bool = false
    var hasVotedFor2: Bool = false
    
    var battle:battleStruct = battleStruct(Category: "", ID: "", Contender1: "", Image1: nil, Votes1: -1, Contender2: "", Image2: nil, Votes2: -1, TotalVotes: -1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //----- collection view stuff:----------------
        let screenHeight = UIScreen.main.bounds.height
        let tabBarHeight: CGFloat = 49
        let navBarHeight: CGFloat = 64
        let cvHeight = screenHeight - tabBarHeight - navBarHeight
        let fullSpacing: CGFloat = 6
        let halfSpacing: CGFloat = fullSpacing / 2
        
        let itemHeight = cvHeight / 2 - halfSpacing
        let itemWidth = UIScreen.main.bounds.width
        
        let customLayout = UICollectionViewFlowLayout()
        customLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        customLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        customLayout.minimumLineSpacing = fullSpacing
        
        collectionView.collectionViewLayout = customLayout
        
        switch kindOfBattle{
        case 0:
            getCategories { (categories) in
                self.getBattlesFromCategories(categories: categories, completion: { (successCat) in
                    if successCat{
                        self.getMostPopularBattles(battles: self.myBattlesCat, completion: { (filteredBattles) in
                            self.myBattlesCat = filteredBattles
                            self.displayBattle()
                        })
                        
                    }
                })
            }
            reloadCollectionView()
        case 1:
            getCategories { (categories) in
                self.getBattlesFromCategories(categories: categories, completion: { (successCat) in
                    if successCat{
                        self.getUnpopularBattles(battles: self.myBattlesCat, completion: { (filteredBattles) in
                            self.myBattlesCat = filteredBattles
                            self.displayBattle()
                        })
                    }
                })
            }
            reloadCollectionView()
        default:
            print("Invalid kindOfBattle Index")
        }
        
    }
    
    
    /// Get all categories from the database
    ///
    /// - Parameter completion: insert the categories used in database
    func getCategories(completion: @escaping ([String]) -> Void){
        var myCategories = [String]()
        ref = Database.database().reference()
        ref?.child("Categories").observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot{
                if let categorie = rest.key as? String{
                    myCategories.append(categorie)
                }
            }
            completion(myCategories)
        })
    }
    
    
    /// Get all battles from the database linked to the categories
    ///
    /// - Parameters:
    ///   - categories: the categories used
    ///   - completion: the battels ordered by the categories
    func getBattlesFromCategories(categories: [String], completion: @escaping (Bool) -> Void){
        for index in 0..<categories.count{
            ref = Database.database().reference()
            let childName: String = categories[index]
            ref?.child("Categories").child(childName).observeSingleEvent(of: .value, with: { (snapshot) in
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? DataSnapshot{
                    if let dic = rest.value as? [String:AnyObject]{
                        
                        guard
                            let contender1 = dic["Contender 1"] as? [String:AnyObject],
                            let contender2 = dic["Contender 2"] as? [String:AnyObject],
                            let name1 = contender1["Name"] as? String,
                            let image1 = contender1["Image"] as? String,
                            let vote1 = contender1["Votes"] as? Int,
                            let name2 = contender2["Name"] as? String,
                            let vote2 = contender2["Votes"] as? Int,
                            let image2 = contender2["Image"] as? String else {return}
                        let totalVotes = vote1+vote2
                        let myBattle = battleStruct(Category: snapshot.key, ID: rest.key, Contender1: name1, Image1: image1, Votes1: vote1, Contender2: name2, Image2: image2, Votes2: vote2, TotalVotes: totalVotes)
                            self.myBattlesCat.append(myBattle)
                    }
                }
                if index == categories.count-1{
                    completion(true)
                }
            })
        }
    }
    
    func getMostPopularBattles(battles: [battleStruct], completion: @escaping ([battleStruct]) -> Void ){
        let filteredBattles = battles.sorted {$0.TotalVotes > $1.TotalVotes}
        let mostVotedBattles = filteredBattles[0..<10]
        completion(Array(mostVotedBattles))
    }
    
    func getUnpopularBattles(battles: [battleStruct], completion: @escaping ([battleStruct]) -> Void ){
        let filteredBattles = battles.filter {$0.TotalVotes < 15}
        completion(Array(filteredBattles))
    }


    override func viewDidLayoutSubviews() {
        centerCircle.layer.cornerRadius = centerCircle.frame.width / 2
        centerCircle.layer.borderWidth = 4
        centerCircle.layer.borderColor = UIColor.white.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayBattle()
        noBattlesLeftView.isHidden = true
        reloadCollectionView()
    }
    
    func displayBattle() {
        let arr = myBattlesCat
        let len = arr.count // check if battles are empty
        if len != 0 {
            noBattlesLeftView.isHidden = true
            randomIndexBattle = Int(arc4random_uniform(UInt32(arr.count)))
            battle = arr[randomIndexBattle]
            
            switch battle.Category {
            case "Beauty Contest":
                centerCircleImage.image = UIImage(named: "cellBeauty2 Contest")
            case "Fight":
                centerCircleImage.image = UIImage(named: "cellFight2")
            case "Rap Battle":
                centerCircleImage.image = UIImage(named: "cellRap5 Battle")
            case "Dance Battle":
                centerCircleImage.image = UIImage(named: "cellDance Battle")
            default:
                centerCircleImage.image = UIImage(named: "cellFight")
            }
            
            reloadCollectionView()
        } else {    // case: no battles left
            noBattlesLeftView.isHidden = false
        }
    }
    
    func reloadCollectionView() {
        collectionView?.reloadData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SpecialBattleCollectionViewCell
        
        var name = "empty"
        //cell.contenderImageView.image = UIImage(named: "fight.jpg")   // provide a default image
        
        if indexPath.row == 0 {
            name = battle.Contender1
            
            if let imgURLString = battle.Image1 {
                let url = URL(string: imgURLString)
                
                cell.contenderImage.sd_setShowActivityIndicatorView(true)
                cell.contenderImage.sd_setIndicatorStyle(.gray)
                cell.contenderImage.sd_setImage(with: url)
            }
        }
        if indexPath.row == 1 {
            name = battle.Contender2
            
            if let imgURLString = battle.Image2 {
                let url = URL(string: imgURLString)
                
                cell.contenderImage.sd_setShowActivityIndicatorView(true)
                cell.contenderImage.sd_setIndicatorStyle(.gray)
                cell.contenderImage.sd_setImage(with: url)
            }
        }
        
        let textAttributes = [
            NSAttributedStringKey.strokeColor : UIColor.black,
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.strokeWidth : -1,
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 40)
            ] as [NSAttributedStringKey : Any]
        
        cell.contenderName.attributedText = NSAttributedString(string: name, attributes: textAttributes)
        
        if hasVotedFor1 {
            if indexPath.row == 0 {
                cell.overlayColor.backgroundColor = UIColor.green
            }
            if indexPath.row == 1 {
                cell.overlayColor.backgroundColor = UIColor.red
            }
        } else if hasVotedFor2 {
            if indexPath.row == 0 {
                cell.overlayColor.backgroundColor = UIColor.red
            }
            if indexPath.row == 1 {
                cell.overlayColor.backgroundColor = UIColor.green
            }
        }
        
        if hasVotedFor1 || hasVotedFor2 {
            
            let textAttributes = [
                NSAttributedStringKey.strokeColor : UIColor.black,
                NSAttributedStringKey.foregroundColor : UIColor.green,
                NSAttributedStringKey.strokeWidth : -1,
                NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 50)
                ] as [NSAttributedStringKey : Any]
            
            let percent1 = calcPercent()
            if indexPath.row == 0 {
                let text = String(percent1) + " %"
                cell.contenderPerc.attributedText = NSAttributedString(string: text, attributes: textAttributes)
            }
            if indexPath.row == 1 {
                let text = String(100 - percent1) + " %"
                cell.contenderPerc.attributedText = NSAttributedString(string: text, attributes: textAttributes)
            }
            cell.contenderPerc.isHidden = false
            UIView.animate(withDuration: 0.25, animations: {
                cell.contenderPerc.transform = CGAffineTransform(scaleX: 1, y: 1)
                
                if indexPath.row == 0 {
                    cell.contenderName.transform = CGAffineTransform(translationX: 0, y: -40)
                    cell.contenderPerc.transform = CGAffineTransform(translationX: 0, y: 40)
                } else {
                    cell.contenderName.transform = CGAffineTransform(translationX: 0, y: 40)
                    cell.contenderPerc.transform = CGAffineTransform(translationX: 0, y: -40)
                }
            })
            
        } else {
            // reset cell
            cell.contenderName.transform = CGAffineTransform(translationX: 0, y: 0)
            cell.contenderPerc.transform = CGAffineTransform(scaleX: 0, y: 0)
            cell.contenderPerc.isHidden = true
            cell.overlayColor.backgroundColor = UIColor.black
        }
        return cell
    }
    
    func calcPercent() -> Double {
        // catch corner cases (div 0 errors)
        if battle.Votes1 == battle.Votes2 {
            return 50
        }
        if battle.Votes1 != 0 && battle.Votes2 == 0 {
            return 100
        }
        if battle.Votes1 == 0 && battle.Votes2 != 0 {
            return 0
        }
        
        // regular case: return percent of c1...(votes/totalvotes*100)
        let percent = Double(battle.Votes1) / (Double(battle.Votes1) + Double(battle.Votes2)) * 100
        let rounded = round(10 * percent) / 10
        return rounded
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        if indexPath.row == 0 {
            battle.Votes1 += 1
            
            let battleRef = ref?.child("Categories").child(battle.Category).child(battle.ID)
            
            battleRef?.child("Contender 1").child("Votes").setValue(battle.Votes1)
            
            hasVotedFor1 = true
            hasVotedFor2 = false
            
            reloadCollectionView()
            loadNextBattle()
            
        }
        if indexPath.row == 1 {
            battle.Votes2 += 1
            
            let battleRef = ref?.child("Categories").child(battle.Category).child(battle.ID)
            
            battleRef?.child("Contender 2").child("Votes").setValue(battle.Votes2)
            
            hasVotedFor2 = true
            hasVotedFor1 = false
            
            reloadCollectionView()
            loadNextBattle()
        }
    }
    
    func loadNextBattle() {
        UIView.animate(withDuration: 0.3, delay: 3.5, options: .curveEaseIn, animations: {
            self.collectionView.transform = CGAffineTransform(translationX: -800, y: 0)
            self.centerCircle.transform = CGAffineTransform(translationX: -800, y: 0)
        }, completion: { (finished) in
            self.hasVotedFor1 = false
            self.hasVotedFor2 = false
            
            self.myBattlesCat.remove(at: self.randomIndexBattle)
            self.displayBattle()
            
            self.collectionView.transform = CGAffineTransform(translationX: 800, y: 0)
            self.centerCircle.transform = CGAffineTransform(translationX: 800, y: 0)
            UIView.animate(withDuration: 0.25, animations: {
                self.collectionView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.centerCircle.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        })
    }
}
