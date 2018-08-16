//
//  LocationViewController.swift
//  WhoWouldWin
//
//  Created by Valentin Witzeneder on 10.01.18.
//  Copyright © 2018 jahava. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol LocationTabOverlayDelegate: class {
    func dismissTheOverlay()
    func getRadius(radius: Int)
}
class LocationViewController: UIViewController, CLLocationManagerDelegate {
    
    weak var delegate: LocationBattleViewController?
    var locationBattleVC: LocationBattleViewController?
    let manager = CLLocationManager()
    
    let blackView = UIView()
    
    var selectedDistance:Int = 50
    
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!

    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        delegate?.dismissTheOverlay()
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        delegate?.dismissTheOverlay()
        delegate?.getRadius(radius: self.selectedDistance)
    }
    
    func createOverlay() {
        
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissOverlay)))
        
        locationBattleVC?.view.addSubview(blackView)
        
        // add overlay after(!) black view - can be nil workaroud
        // TODO: Better solution for force unwrap
        guard locationBattleVC != nil else {
            return
        }
        locationBattleVC?.view.addSubview((locationBattleVC?.overlaySubview)!)
        
        blackView.frame = view.frame
        // set alpha to 0 for animation
        blackView.alpha = 0
        
        
        let overlayHeight: CGFloat = 300
        
        UIView.animate(withDuration: 1.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 1
            
            let overlayYLocation = self.view.frame.height - overlayHeight
            self.locationBattleVC?.overlaySubview.frame = CGRect(x: 0, y: overlayYLocation, width: self.view.frame.width, height: overlayHeight)
            
        }, completion: nil)
    }
    
    @objc func dismissOverlay() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackView.alpha = 0
            
            self.locationBattleVC?.overlaySubview.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 300)
            
        }) { (completed: Bool) in
            self.blackView.removeFromSuperview()
        }
    }
    
    
    @IBAction func radiusSlider(_ sender: UISlider) {
        selectedDistance = Int(sender.value)
        
        let text: String = "Radius: " + selectedDistance.description + " km"
        radiusLabel.text = text
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
}
