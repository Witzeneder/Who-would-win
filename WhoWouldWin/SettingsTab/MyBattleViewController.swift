//
//  MyBattleViewController.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 03.02.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit

class MyBattleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    struct battle {
        var categoryname: String
        var Contender1: String
        var Image1: String
        var Votes1: Double
        var Contender2: String
        var Image2: String
        var Votes2: Double
    }
    
    var myBattle:battle?
    
    var categoryname = ""
    var contenderName1 = ""
    var contenderName2 = ""
    var contenderVotes1 = 0.0
    var contenderVotes2 = 0.0
    var contenderImage1 = ""
    var contenderImage2 = ""

    @IBOutlet weak var centerCircleView: UIView!
    @IBOutlet weak var centerCircleImageView: UIImageView!
    
    @IBOutlet weak var battleCollectionView: UICollectionView!
    
    override func viewDidLayoutSubviews() {
        centerCircleView.layer.cornerRadius = centerCircleView.frame.width / 2
        centerCircleView.layer.borderWidth = 4
        //let myColor : UIColor = UIColor.init(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
        //centerCircleView.layer.borderColor = myColor.cgColor
        centerCircleView.layer.borderColor = UIColor.white.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myBattle = battle(categoryname: categoryname, Contender1: contenderName1, Image1: contenderImage1, Votes1: contenderVotes1, Contender2: contenderName2, Image2: contenderImage2, Votes2: contenderVotes2)
        
        self.title = ("Total Votes:")
        let totalVotes = myBattle!.Votes1 + myBattle!.Votes2
        self.title?.append(String(Int(totalVotes)))
        
        switch categoryname {
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
    }
    
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
        
        battleCollectionView.collectionViewLayout = customLayout
        
        battleCollectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellBattle", for: indexPath) as! SingleBattleCollectionViewCell
        
        let textAttributes = [
            NSAttributedStringKey.strokeColor : UIColor.black,
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.strokeWidth : -1,
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 40)
            ] as [NSAttributedStringKey : Any]
        
        let textAttributesPer = [
            NSAttributedStringKey.strokeColor : UIColor.black,
            NSAttributedStringKey.foregroundColor : UIColor.green,
            NSAttributedStringKey.strokeWidth : -1,
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 50)
            ] as [NSAttributedStringKey : Any]
        
        let percent1 = calcPercent(myBattle: myBattle!)
        
        if indexPath.row == 0 {
            
    
            if let imgURLString = myBattle?.Image1 {
                let url = URL(string: imgURLString)
                
                cell.contenderImageView.sd_setImage(with: url)
            }
            cell.nameLabel.attributedText = NSAttributedString(string: (myBattle?.Contender1)!, attributes: textAttributes)
            let text = String(percent1) + " %"
            cell.percentLabel.attributedText = NSAttributedString(string: text, attributes: textAttributesPer)
            
        }
        if indexPath.row == 1 {
            
            if let imgURLString = myBattle?.Image2 {
                let url = URL(string: imgURLString)
                
                cell.contenderImageView.sd_setShowActivityIndicatorView(true)
                cell.contenderImageView.sd_setIndicatorStyle(.gray)
                cell.contenderImageView.sd_setImage(with: url)
            }
            cell.nameLabel.attributedText = NSAttributedString(string: (myBattle?.Contender2)!, attributes: textAttributes)
            let text = String(100 - percent1)  + " %"
            cell.percentLabel.attributedText = NSAttributedString(string: text, attributes: textAttributesPer)
        }

        
            cell.percentLabel.isHidden = false
            
            UIView.animate(withDuration: 0.5, animations: {
                cell.percentLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                
                if indexPath.row == 0 {
                    cell.nameLabel.transform = CGAffineTransform(translationX: 0, y: -40)
                    cell.percentLabel.transform = CGAffineTransform(translationX: 0, y: 40)
                } else {
                    cell.nameLabel.transform = CGAffineTransform(translationX: 0, y: 40)
                    cell.percentLabel.transform = CGAffineTransform(translationX: 0, y: -40)
                }
            })
        return cell
    }
    
    func calcPercent(myBattle: battle) -> Double {
        // catch corner cases (div 0 errors)
        if myBattle.Votes1 == myBattle.Votes2 {
            return 50
        }
        if myBattle.Votes1 != 0 && myBattle.Votes2 == 0 {
            return 100
        }
        if myBattle.Votes1 == 0 && myBattle.Votes2 != 0 {
            return 0
        }
        // regular case: return percent of c1...(votes/totalvotes*100)
        let percent = myBattle.Votes1 / (myBattle.Votes1 + myBattle.Votes2) * 100
        let rounded = round(10 * percent) / 10
        return rounded
    }

    
}
