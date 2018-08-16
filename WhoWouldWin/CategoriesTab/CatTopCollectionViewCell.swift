//
//  CatTopCollectionViewCell.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 03.02.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit

class CatTopCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = 10
    }
}
