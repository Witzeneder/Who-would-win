//
//  ContactViewController.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 28.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {

    @IBOutlet weak var contactImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageName = UIImage(named: "ContactTab")
        contactImageView?.image = imageName
        contactImageView.layer.cornerRadius = 20
    }
}
