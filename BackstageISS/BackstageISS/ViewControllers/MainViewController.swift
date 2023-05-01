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
    @IBOutlet weak var statusLabel: UILabel!
    
    private let locationManager: LocationManager
    private var userLocation: CLLocation?
    private var userLocationName: String? {
        didSet {
            self.updateStatusLabel()
        }
    }
    
    private var currentISSPosition: CLLocation?
    private var currentISSPositionName: String? {
        didSet {
            self.updateStatusLabel()
        }
    }
    
    private var predictedISSPassTime: Double = 0 {
        didSet {
            self.updateStatusLabel()
        }
    }

    private var currentAnnotation: MKPointAnnotation?
    
    var acitivityIndicatorView: UIActivityIndicatorView?
    let dateFormatter = DateFormatter()
    
    init() {
        self.locationManager = LocationManager()
        super.init(nibName: "MainViewController", bundle: nil)
        
        self.locationManager.delegate = self
        self.dateFormatter.dateStyle = .short
        self.dateFormatter.timeStyle = .short
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.title = "ISS Tracker"
        self.statusLabel.textColor = Colors.nasaBlue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

        if (self.locationManager.shouldAskForLocationPermissions) {
            self.locationManager.requestLocationPermissions()
        }
        
        self.getCurrentISSPosition()
        self.getNextISSPassTime()
    }
    
    private func getCurrentISSPosition() {
        guard let mapView else {
            return
        }

        self.showActivityIndicator()
        
        ISSPositionManager.sharedISSLocationManager.getCurrentPosition { issPosition in
            self.currentISSPosition = CLLocation(latitude: issPosition.latitude, longitude: issPosition.longitude)
            self.locationManager.getCityForCoordinates(location: self.currentISSPosition) { locationName in
                self.currentISSPositionName = locationName
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.hideActivityIndicator()

                if let currentAnnotation = self?.currentAnnotation {
                    mapView.removeAnnotation(currentAnnotation)
                }
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: issPosition.latitude, longitude: issPosition.longitude)
                annotation.title = "Current Location of ISS"
                mapView.addAnnotation(annotation)
                mapView.selectAnnotation(annotation, animated: self?.currentAnnotation == nil)
                self?.currentAnnotation = annotation

                // If we've panned away or we move the annotation out of view while just watching the track,
                // re-center the map on the offscreen coordinate.
                if (!mapView.visibleMapRect.contains(MKMapPoint(annotation.coordinate))) {
                    mapView.setCenter(annotation.coordinate, animated: true)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.getCurrentISSPosition()
                }
            }
        }
    }
    
    private func getNextISSPassTime() {
        let location = self.userLocation ?? CLLocation(latitude: 40.712776, longitude: -74.005974)

        ISSPositionManager.sharedISSLocationManager.getPredictedPosition(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { issPosition in
            self.predictedISSPassTime = issPosition.timestamp
            
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if (settings.authorizationStatus == .notDetermined) {
                    NotificationManager.sharedNotificationManager.requestNotificationAuthorization { success in
                        if (success) {
                            NotificationManager.sharedNotificationManager.scheduleISSPassNotification(timestamp: issPosition.timestamp)
                        }
                    }
                } else {
                    NotificationManager.sharedNotificationManager.scheduleISSPassNotification(timestamp: issPosition.timestamp)
                }
            }
        }
    }
    
    private func updateStatusLabel() {
        var text = ""
        
        if let userLocationName = self.userLocationName {
            text = "\(text)User Location: \(userLocationName)\n"
        }
        
        if let currentISSPositionName = self.currentISSPositionName {
            text = "\(text)Current ISS Location: \(currentISSPositionName)\n"
        }
        
        if (self.predictedISSPassTime != 0) {
            text = "\(text)ISS Will Be Over You at \(self.formatDate(timestamp: self.predictedISSPassTime))\n"
        }
        
        DispatchQueue.main.async {
            self.statusLabel.text = text
        }
    }
    
    private func showActivityIndicator() {
        guard self.acitivityIndicatorView == nil else {
            return
        }
        
        self.acitivityIndicatorView = UIActivityIndicatorView(style: .large)
        self.acitivityIndicatorView?.center = self.view.center
        self.view.addSubview(self.acitivityIndicatorView!)
        self.acitivityIndicatorView?.startAnimating()
    }
    
    private func hideActivityIndicator() {
        self.acitivityIndicatorView?.removeFromSuperview()
        self.acitivityIndicatorView = nil
    }
    
    private func formatDate(timestamp: Double) -> String {
        self.dateFormatter.dateStyle = .short
        self.dateFormatter.timeStyle = .short
        let date = Date(timeIntervalSince1970: timestamp)
        return self.dateFormatter.string(from: date)
    }
}

extension MainViewController: LocationManagerDelegate {
    func didUpdateLocation(location: Location) {
        self.userLocation = location
        self.mapView.showsUserLocation = true
        
        self.locationManager.getCityForCoordinates(location: location) { locationName in
            self.userLocationName = locationName
        }
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
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }

}
