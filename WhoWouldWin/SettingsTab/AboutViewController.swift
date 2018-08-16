//
//  AboutViewController.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 28.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var aboutImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageName = UIImage(named: "team")
        aboutImageView?.image = imageName
        aboutImageView.layer.cornerRadius = 20
    }
}
