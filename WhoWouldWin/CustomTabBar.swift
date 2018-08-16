//
//  CustomTabBar.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 11.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit
import ESTabBarController_swift


/// Configuration of the Custom Tabbar
class CustomTabBar: ESTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tabBar.shadowImage = UIImage(named: "transparent")
        tabBar.backgroundImage = UIImage(named: "background_tb")
        
        let v1 = self.storyboard?.instantiateViewController(withIdentifier: "locTab") as! UINavigationController
        let v2 = self.storyboard?.instantiateViewController(withIdentifier: "catTab") as! UINavigationController
        let v3 = self.storyboard?.instantiateViewController(withIdentifier: "vsTab") as! BattleViewController
        let v4 = self.storyboard?.instantiateViewController(withIdentifier: "addTab") as! UINavigationController
        let v5 = self.storyboard?.instantiateViewController(withIdentifier: "settTab") as! UINavigationController
        
        
        v1.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(),title: nil, image: UIImage(named: "tabbar_loc"), selectedImage: UIImage(named: "tabbar_loc"), tag: 0)
        v2.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(),title: nil, image: UIImage(named: "tabbar_cat"), selectedImage: UIImage(named: "tabbar_cat"), tag: 1)
        
        v3.tabBarItem = ESTabBarItem.init(ExampleIrregularityContentView(), title: nil, image: UIImage(named: "boxing"), selectedImage: UIImage(named: "boxingfull"), tag: 2)
        v4.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(),title: nil, image: UIImage(named: "tabbar_add"), selectedImage: UIImage(named: "tabbar_add"), tag: 3)
        v5.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(),title: nil, image: UIImage(named: "User"), selectedImage: UIImage(named: "User"), tag: 4)
        
        self.viewControllers = [v1, v2, v3, v4, v5]
        
        self.selectedIndex = 2
        self.delegate = self
    }
}

extension CustomTabBar : UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    //other delegate methods as required....
}

