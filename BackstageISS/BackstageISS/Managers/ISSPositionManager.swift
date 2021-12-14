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
    
    func getCurrentPosition(completion: @escaping (_ issPosition: ISSPosition) -> ()) {
        RequestManager.getJSON(url: Config.issCurrentLocationAPIURL) { response in
            let issPosition = ISSPosition(currentPositionJSON: response.jsonDict)
            completion(issPosition)
        }
    }
    
    func getPredictedPosition(latitude: Float, longitude: Float, completion: @escaping (_ issPosition: ISSPosition) -> ()) {
        RequestManager.getJSON(url: Config.issPredictedPositionAPIURL, parameters: ["lat": latitude, "lon": longitude]) { response in
            let issPosition = ISSPosition(predictedPositionJSON: response.jsonDict)
            completion(issPosition)
        }
    }
    
}
