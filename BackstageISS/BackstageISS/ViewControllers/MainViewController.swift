//
//  MainViewController.swift
//  BackstageISS
//
//  Created by Donald Angelillo on 12/13/21.
//

import UIKit

class MainViewController: UIViewController {
    let locationManager: LocationManager
    
    init() {
        self.locationManager = LocationManager()
        super.init(nibName: "MainViewController", bundle: nil)
        self.locationManager.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

        if (self.locationManager.shouldAskForLocationPermissions) {
            self.locationManager.requestLocationPermissions()
        } else {
            self.locationManager.getCurrentLocation()
        }
        
        ISSPositionManager.sharedISSLocationManager.getCurrentPosition()
        ISSPositionManager.sharedISSLocationManager.getPredictedPosition(latitude: 40.712776, longitude: -74.005974)
    }


}

extension MainViewController: LocationManagerDelegate {
    func didUpdateLocation(location: Location) {
        print(location)
    }
    
    func userDidAllowLocationPermissions() {
        self.locationManager.getCurrentLocation()
    }
}
