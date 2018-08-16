//
//  SectionHeaderView.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 31.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit

class SectionHeaderView: UICollectionReusableView{
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    
    var LabelText: String!{
        didSet{
            let textAttributes = [
                NSAttributedStringKey.strokeColor : UIColor.black,
                NSAttributedStringKey.foregroundColor : UIColor.white,
                NSAttributedStringKey.strokeWidth : -1,
                NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 40)
                ] as [NSAttributedStringKey : Any]
            categoryName.attributedText = NSAttributedString(string: LabelText, attributes: textAttributes)
        }
    }
    
    var imageName: String!{
        didSet{
            categoryImageView.image = UIImage(named: imageName)
        }
    }
    
}
