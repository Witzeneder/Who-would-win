//
//  CustomButton.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 27.12.17.
//  Copyright © 2017 jahava. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

}
