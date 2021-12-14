//
//  MainViewController.swift
//  BackstageISS
//
//  Created by Donald Angelillo on 12/13/21.
//

import UIKit
import MapKit

class MainViewController: UIViewController {
    
    // Using Apple Maps (MapKit) cause it's super easy and Google Maps is a huge objective-c mess.
    @IBOutlet weak var mapView: MKMapView!
    
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
        
        self.mapView.delegate = self
        
        self.navigationController?.navigationBar.barTintColor = .blue
        self.title = "ISS"
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

        if (self.locationManager.shouldAskForLocationPermissions) {
            self.locationManager.requestLocationPermissions()
        } else {
            self.locationManager.getCurrentLocation()
        }
        
        ISSPositionManager.sharedISSLocationManager.getCurrentPosition { issPosition in
            DispatchQueue.main.async {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: issPosition.latitude, longitude: issPosition.longitude)
                annotation.title = "Current Location of ISS"
                self.mapView.addAnnotation(annotation)
                self.mapView.selectAnnotation(annotation, animated: true)
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            }
        }
        //ISSPositionManager.sharedISSLocationManager.getPredictedPosition(latitude: 40.712776, longitude: -74.005974)
    }
}

extension MainViewController: LocationManagerDelegate {
    func didUpdateLocation(location: Location) {
        self.mapView.showsUserLocation = true
    }
    
    func userDidAllowLocationPermissions() {
        self.locationManager.getCurrentLocation()
    }
}

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {
            return nil
        }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.image = UIImage(named: "iss")
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }

}
