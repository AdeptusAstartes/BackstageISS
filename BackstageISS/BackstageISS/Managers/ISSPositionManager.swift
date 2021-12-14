//
//  ISSPositionManager.swift
//  BackstageISS
//
//  Created by Donald Angelillo on 12/13/21.
//

import Foundation

/*
 I like to break down the handling of discrete pieces of functionality into "manager" classes that
 encapsulate as much of the business logic as possible of said functionality.  These managers are often
 singletons that can be called from anywhere in the app (even concurrently) in a completely threadsafe manner.
 No need for view controllers, etc. to manage instances of the managers for no reason.
 */
class ISSPositionManager {
    static let sharedISSLocationManager = ISSPositionManager()
    
    func getCurrentPosition() {
        RequestManager.getJSON(url: Config.issCurrentLocationAPIURL, parameters: nil) { response in
            let issPosition = ISSPosition(currentPositionJSON: response.jsonDict)
            print(issPosition)
        }
    }
    
    func getPredictedPosition(latitude: Float, longitude: Float) {
        RequestManager.getJSON(url: Config.issPredictedPositionAPIURL, parameters: ["lat": latitude, "lon": longitude]) { response in
            let issPosition = ISSPosition(predictedPositionJSON: response.jsonDict)
            print(issPosition)
        }
    }
    
}
