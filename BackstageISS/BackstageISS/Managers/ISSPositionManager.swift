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

    // Closure-based version
    func getCurrentPosition(completion: @escaping (_ issPosition: ISSPosition) -> ()) {
        RequestManager.getJSON(url: Config.issCurrentLocationAPIURL) { response in
            let issPosition = ISSPosition(currentPositionJSON: response.jsonDict)
            completion(issPosition)
        }
    }

    // Swift concurrency version
    func getCurrentPosition() async -> ISSPosition {
        let response = await RequestManager.getJSON(url: Config.issCurrentLocationAPIURL)
        let issPosition = ISSPosition(currentPositionJSON: response.jsonDict)
        return issPosition
    }
    
    func getPredictedPosition(latitude: Double, longitude: Double, completion: @escaping (_ issPosition: ISSPosition) -> ()) {
        // We have to set n to 2 so that we get up to two predictions from the API because it has a weird bug
        // where if the earliest prediction is too close to the current time it doesn't return any times at all.
        // So ask for two and if we get more than one always take the first because that is the closest to now.
        RequestManager.getJSON(url: Config.issPredictedPositionAPIURL, parameters: ["lat": latitude, "lon": longitude, "n": 2]) { response in
            let issPosition = ISSPosition(predictedPositionJSON: response.jsonDict)
            completion(issPosition)
        }
    }
    
}
