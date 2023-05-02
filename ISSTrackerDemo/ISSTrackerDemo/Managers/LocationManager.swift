//
//  LocationManager.swift
//  ISSTrackerDemo
//
//  Created by Donald Angelillo on 12/14/21.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(location: Location)
    func userDidAllowLocationPermissions()
}

// CLLocationManagerDelegate can only be implemented by subclasses of NSObject (yuck).  So
// let's have this manager class handle all that and any of our other classes that need a location can
// just implement the LocationManagerDelegate and not have to worry about all that old Objective-C stuff.
public typealias Location = CLLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?
    
    var shouldAskForLocationPermissions: Bool {
        return self.locationManager.authorizationStatus == .notDetermined
    }
    
    var locationAllowed: Bool {
        let status = self.locationManager.authorizationStatus
        
        switch(status) {
            case .notDetermined:
                return false
            case .restricted:
                return false
            case .denied:
                return false
            case .authorizedAlways:
                return true
            case .authorizedWhenInUse:
                return true
            @unknown default:
                return false
        }
    }
    
    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    
    func requestLocationPermissions() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() {
        locationManager.requestLocation()
    }

    func getCityForCoordinates(location: CLLocation?) async -> String {
        guard let location = location else {
            return ""
        }

        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return self.stringFor(placemarks: placemarks, error: nil)
        } catch {
            return ""
        }
    }
    
    func getCityForCoordinates(location: CLLocation?, completion: @escaping (_ locationName: String?) -> ()) {
        guard let location = location else {
            completion(nil)
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            completion(self?.stringFor(placemarks: placemarks, error: error))
        }
    }

    private func stringFor(placemarks: [CLPlacemark]?, error: Error?) -> String {
        var text = ""

        if let placemarks = placemarks, let placemark = placemarks.last {
            if let locality = placemark.locality {
                text = "\(text)\(locality), "
            }

            if let administrativeArea = placemark.administrativeArea {
                text = "\(text)\(administrativeArea), "
            }

            if let country = placemark.country {
                text = "\(text)\(country)"
            }

            if (text.isEmpty) {
                text = "Uninhabited Area"
            }
        }

        return text
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /*
        This is safe per the docs (and also we only want the last one if there are multiple locations because that is the latest).
        
         "An array of CLLocation objects containing the location data. This array always contains at least one object representing the current location. If updates were deferred or if multiple locations arrived before they could be delivered, the array may contain additional entries. The objects in the array are organized in the order in which they occurred. Therefore, the most recent location update is at the end of the array."
         */

        self.delegate?.didUpdateLocation(location: locations.last!)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if (self.locationAllowed) {
            self.delegate?.userDidAllowLocationPermissions()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
