//
//  ViewController.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 27.12.17.
//  Copyright © 2017 jahava. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BattleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    struct battleStruct {
        var ID: String
        var Contender1: String
        var Image1: String?
        var Votes1: Int
        var Contender2: String
        var Image2: String?
        var Votes2: Int
    }
    
    var ref: DatabaseReference?
    var refHandle: DatabaseHandle?
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var centerCircleView: UIView!
    @IBOutlet weak var centerCircleImageView: UIImageView!
    @IBOutlet weak var battleCollectionView: UICollectionView!
    @IBOutlet weak var noBattlesLeftView: UIView!
    @IBOutlet weak var noBattlesLeftImageView: UIImageView!
    
    var randomIndexCat = 0
    var randomIndexBattle = 0
    
    var catName: String = ""
    var myBattlesCat = [String: [battleStruct]]()
    
    var hasVotedFor1: Bool = false
    var hasVotedFor2: Bool = false
    
    var battle:battleStruct = battleStruct(ID: "", Contender1: "", Image1: nil, Votes1: -1, Contender2: "", Image2: nil, Votes2: -1)
    
    override func viewDidLayoutSubviews() {
        topView.layer.cornerRadius = topView.frame.width / 2
        topView.layer.borderWidth = 4
        topView.layer.borderColor = UIColor.white.cgColor
        topView.backgroundColor = UIColor.init(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
        
        centerCircleView.layer.cornerRadius = centerCircleView.frame.width / 2
        centerCircleView.layer.borderWidth = 4
        centerCircleView.layer.borderColor = UIColor.white.cgColor
        
        let size = centerCircleView.sizeThatFits(self.view.bounds.size)
        centerCircleView.frame = CGRect.init(x: (self.view.bounds.size.width - size.width) / 2.0, y: (self.view.bounds.size.height - size.height) / 1.9 , width: size.width, height: size.height)
        
        let sizeTop = topView.sizeThatFits(self.view.bounds.size)
        topView.frame = CGRect.init(x: (self.view.bounds.size.width - sizeTop.width) / 2.0, y:(-sizeTop.height/1.5) , width: sizeTop.width, height: sizeTop.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayBattle()
        noBattlesLeftView.isHidden = true
    
        reloadCollectionView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let randNothingLeftIndex = Int(arc4random_uniform(UInt32(10))) + 1
        noBattlesLeftImageView.loadGif(name: "nothingLeft\(randNothingLeftIndex)")
        
        //----- collection view stuff:----------------
        let screenHeight = UIScreen.main.bounds.height
        let tabBarHeight: CGFloat = 49
        let statusBarHeight: CGFloat = 20
        let cvHeight = screenHeight - tabBarHeight - statusBarHeight
        let fullSpacing: CGFloat = 6
        let halfSpacing: CGFloat = fullSpacing / 2
        
        let itemHeight = cvHeight / 2 - halfSpacing
        let itemWidth = UIScreen.main.bounds.width
        
        let customLayout = UICollectionViewFlowLayout()
        customLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        customLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        customLayout.minimumLineSpacing = fullSpacing
        
        battleCollectionView.collectionViewLayout = customLayout

        myBattlesCat = [:]
        
        //get the battles from the categories
        getCategories { (categories) in
            self.getBattlesFromCategories(categories: categories, completion: { (successCat) in
                if successCat{
                    self.displayBattle()
                }
            })
        }
        reloadCollectionView()
    }
    
    
    /// Get the categories
    ///
    /// - Parameter completion: the categories in database
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
    
    
    
    /// Get the battles to the categories
    ///
    /// - Parameters:
    ///   - categories: the categories retrieved from the database
    ///   - completion: the battles linked to the categories
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
                        let myBattle = battleStruct(ID: rest.key, Contender1: name1, Image1: image1, Votes1: vote1, Contender2: name2, Image2: image2, Votes2: vote2)
                        if self.myBattlesCat[snapshot.key]?.append(myBattle) == nil{
                            self.myBattlesCat[snapshot.key] = [myBattle]
                        }
                    }
                }
                print(index)
                if index == categories.count-1{
                    completion(true)
                }
            })
        }
    }

    func displayBattle() {
        let arr = myBattlesCat
        
        let len = arr.count // check if battles are empty
        if len != 0 {
            noBattlesLeftView.isHidden = true
            topView.isHidden = false
            
            let catArr = Array(arr.keys)
            randomIndexCat = Int(arc4random_uniform(UInt32(catArr.count)))
            
            let cat = catArr[randomIndexCat]
            categoryLabel.text = cat
            
            switch cat {
            case "Beauty Contest":
                centerCircleImageView.image = UIImage(named: "cellBeauty2 Contest")
            case "Fight":
                centerCircleImageView.image = UIImage(named: "cellFight2")
            case "Rap Battle":
                centerCircleImageView.image = UIImage(named: "cellRap5 Battle")
            case "Dance Battle":
                centerCircleImageView.image = UIImage(named: "cellDance Battle")
            default:
                centerCircleImageView.image = UIImage(named: "cellFight")
            }
            
            randomIndexBattle = Int(arc4random_uniform(UInt32(arr[cat]!.count)))
            let dict = arr[cat]![randomIndexBattle]
            catName = cat
            
            if let name1 = dict.Contender1 as? String {
                battle.Contender1 = name1
            }
            if let votes1 = dict.Votes1 as? Int {
                battle.Votes1 = votes1
            }
            if let imgURL1 = dict.Image1 as? String {
                battle.Image1 = imgURL1
            }
            
            if let name2 = dict.Contender2 as? String {
                battle.Contender2 = name2
            }
            if let votes2 = dict.Votes2 as? Int {
                battle.Votes2 = votes2
            }
            if let imgURL2 = dict.Image2 as? String {
                battle.Image2 = imgURL2
            }
            
            if let id = dict.ID as? String {
                battle.ID = id
            }
            
            reloadCollectionView()
            
        } else {    // case: no battles left
            topView.isHidden = true
            noBattlesLeftView.isHidden = false
        }
    }
    
    func reloadCollectionView() {
        battleCollectionView?.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BattleVCCollectionViewCell
        
        var name = "empty"
        //cell.contenderImageView.image = UIImage(named: "fight.jpg")   // provide a default image
        
        if indexPath.row == 0 {
            name = battle.Contender1
            
            if let imgURLString = battle.Image1 {
                let url = URL(string: imgURLString)
                
                cell.contenderImageView.sd_setShowActivityIndicatorView(true)
                cell.contenderImageView.sd_setIndicatorStyle(.gray)
                cell.contenderImageView.sd_setImage(with: url)
            }
        }
        if indexPath.row == 1 {
            name = battle.Contender2
            
            if let imgURLString = battle.Image2 {
                let url = URL(string: imgURLString)
                
                cell.contenderImageView.sd_setShowActivityIndicatorView(true)
                cell.contenderImageView.sd_setIndicatorStyle(.gray)
                cell.contenderImageView.sd_setImage(with: url)
            }
        }
        
        let textAttributes = [
            NSAttributedStringKey.strokeColor : UIColor.black,
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.strokeWidth : -1,
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 40)
            ] as [NSAttributedStringKey : Any]
        
        cell.nameLabel.attributedText = NSAttributedString(string: name, attributes: textAttributes)
        
        
        if hasVotedFor1 {
            if indexPath.row == 0 {
                cell.blackOverlay.backgroundColor = UIColor.green
            }
            if indexPath.row == 1 {
                cell.blackOverlay.backgroundColor = UIColor.red
            }
        } else if hasVotedFor2 {
            if indexPath.row == 0 {
                cell.blackOverlay.backgroundColor = UIColor.red
            }
            if indexPath.row == 1 {
                cell.blackOverlay.backgroundColor = UIColor.green
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
                cell.percentLabel.attributedText = NSAttributedString(string: text, attributes: textAttributes)
            }
            if indexPath.row == 1 {
                let text = String(100 - percent1) + " %"
                cell.percentLabel.attributedText = NSAttributedString(string: text, attributes: textAttributes)
            }
            cell.percentLabel.isHidden = false
            UIView.animate(withDuration: 0.25, animations: {
                cell.percentLabel.transform = CGAffineTransform(scaleX: 1, y: 1)

                if indexPath.row == 0 {
                    cell.nameLabel.transform = CGAffineTransform(translationX: 0, y: -40)
                    cell.percentLabel.transform = CGAffineTransform(translationX: 0, y: 40)
                } else {
                    cell.nameLabel.transform = CGAffineTransform(translationX: 0, y: 40)
                    cell.percentLabel.transform = CGAffineTransform(translationX: 0, y: -40)
                }
            })
            
        } else {
            // reset cell
            cell.nameLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            cell.percentLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
            cell.percentLabel.isHidden = true
            cell.blackOverlay.backgroundColor = UIColor.black
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
                
                let battleRef = ref?.child("Categories").child(catName).child(battle.ID)
                
                battleRef?.child("Contender 1").child("Votes").setValue(battle.Votes1)
                
                hasVotedFor1 = true
                hasVotedFor2 = false
                
                reloadCollectionView()
                loadNextBattle()
            }
        
            if indexPath.row == 1 {
                battle.Votes2 += 1
                
                let battleRef = ref?.child("Categories").child(catName).child(battle.ID)
                
                battleRef?.child("Contender 2").child("Votes").setValue(battle.Votes2)
                
                hasVotedFor2 = true
                hasVotedFor1 = false
                
                reloadCollectionView()
                loadNextBattle()
        }
    }
    
    func loadNextBattle() {
        UIView.animate(withDuration: 0.3, delay: 3.5, options: .curveEaseIn, animations: {
            self.battleCollectionView.transform = CGAffineTransform(translationX: -800, y: 0)
            self.centerCircleView.transform = CGAffineTransform(translationX: -800, y:0)
        }, completion: { (finished) in
            self.hasVotedFor1 = false
            self.hasVotedFor2 = false
            
            self.myBattlesCat[self.catName]?.remove(at: self.randomIndexBattle)
            if(self.myBattlesCat[self.catName]?.count == 0){
                self.myBattlesCat.removeValue(forKey: self.catName)
            }
            self.displayBattle()
            
            self.battleCollectionView.transform = CGAffineTransform(translationX: 800, y: 0)
            self.centerCircleView.transform = CGAffineTransform(translationX: 800, y:0)
            UIView.animate(withDuration: 0.25, animations: {
                self.battleCollectionView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.centerCircleView.transform = CGAffineTransform(translationX: 0, y:0)
            })
        })
    }
}
