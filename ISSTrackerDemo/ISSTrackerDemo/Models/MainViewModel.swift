//
//  MainViewModel.swift
//  ISSTrackerDemoSwiftUI
//
//  Created by Donald Angelillo on 5/2/23.
//

import Foundation
import CoreLocation

class MainViewModel: ObservableObject {
    private let locationManager: LocationManager
    private var userLocation: CLLocation?
    private var userLocationName: String?

    @Published public var currentISSPosition: CLLocation?
    @Published public var currentISSPositionName: String?

    private var predictedISSPassTime: Double = 0

    init() {
        self.locationManager = LocationManager()
        self.locationManager.delegate = self

        if self.locationManager.shouldAskForLocationPermissions {
            self.locationManager.requestLocationPermissions()
        }

        self.refresh()
    }

    public func refresh() {
        Task { [weak self] in
            await self?.getCurrentISSPosition()
        }
    }

    private func getCurrentISSPosition() async {
        let issPosition = await ISSPositionManager.sharedISSLocationManager.getCurrentPosition()
        let name = await self.locationManager.getCityForCoordinates(location: CLLocation(latitude: issPosition.latitude, longitude: issPosition.longitude))

        DispatchQueue.main.async { [weak self] in
            self?.currentISSPosition = CLLocation(latitude: issPosition.latitude, longitude: issPosition.longitude)
            self?.currentISSPositionName = name
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.refresh()
        }
    }

}

extension MainViewModel: LocationManagerDelegate {
    func didUpdateLocation(location: Location) {

    }

    func userDidAllowLocationPermissions() {

    }
}
