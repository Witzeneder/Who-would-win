//
//  CategoriesViewController.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 06.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CategoriesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var ref: DatabaseReference?
    var refHandle: DatabaseHandle?
    var categories = ["Beauty Contest", "Dance Battle", "Fight", "Rap Battle"]
    var categoryClicked: String?
    var clickedIndex = -1
    
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        categoriesCollectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // can - 3 because 3 pts spacing is used
        let itemSize = UIScreen.main.bounds.width - 20
        
        let categoriesCVLayout = UICollectionViewFlowLayout()
        categoriesCVLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        categoriesCVLayout.itemSize = CGSize(width: itemSize, height: 120)
        
        categoriesCVLayout.minimumInteritemSpacing = 10
        categoriesCVLayout.minimumLineSpacing = 10
        
        categoriesCollectionView.collectionViewLayout = categoriesCVLayout
        
        let topCVLayout = UICollectionViewFlowLayout()
        topCVLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        topCVLayout.itemSize = CGSize(width: itemSize - 20, height: 160)
        topCVLayout.scrollDirection = .horizontal
        topCVLayout.minimumInteritemSpacing = 10
        
        topCollectionView.collectionViewLayout = topCVLayout
        
        categoriesCollectionView?.reloadData()
        topCollectionView?.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.categoriesCollectionView {
            return 1
        } else {    // else: top collection view
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.categoriesCollectionView {
            return categories.count
        } else {    // else: top collection view
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.categoriesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoriesCollectionViewCell
            
            switch indexPath.row {
            case 0:
                cell.picImageView.image = UIImage(named: "beautyContest.jpg")
            case 1:
                cell.picImageView.image = UIImage(named: "danceBattle3.jpg")
            case 2:
                cell.picImageView.image = UIImage(named: "fight2.jpg")
            case 3:
                cell.picImageView.image = UIImage(named: "rapBattle1.jpg")
            default:
                print("invalid indexpath")
            }
            
            let textAttributes = [
                NSAttributedStringKey.strokeColor : UIColor.black,
                NSAttributedStringKey.foregroundColor : UIColor.white,
                NSAttributedStringKey.strokeWidth : -1,
                NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 40)
                ] as [NSAttributedStringKey : Any]
            
            let name = categories[indexPath.row]
            cell.nameLabel.attributedText = NSAttributedString(string: name, attributes: textAttributes)
            
            return cell
        } else {    // else: top collection view
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCell", for: indexPath) as! CatTopCollectionViewCell
            
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Hottest 🔥"
                cell.subtitleLabel.text = "Look at the most popular battles."
                cell.imageView.image = UIImage(named: "collHottest")
            case 1:
                cell.titleLabel.text = "Most Recent 🕑"
                cell.subtitleLabel.text = "See brand new content."
                cell.imageView.image = UIImage(named: "collRecent")
            default:
                print("invalid indexpath")
            }
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.categoriesCollectionView {
            categoryClicked = categories[indexPath.row]
            
            performSegue(withIdentifier: "categorySegue", sender: self)
        } else {
            clickedIndex = indexPath.row
            performSegue(withIdentifier: "fromCatToSpecial", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categorySegue" {
            if let detailsVC = segue.destination as? CategoryBattleViewController {
                detailsVC.categoryName = self.categoryClicked
            }
        }
        else if segue.identifier == "fromCatToSpecial" {
            if let detailsVC = segue.destination as? SpecialBattlesViewController {
                detailsVC.kindOfBattle = clickedIndex
            }
        }
    }
}
