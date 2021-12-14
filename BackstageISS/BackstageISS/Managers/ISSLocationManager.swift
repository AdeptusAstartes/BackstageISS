//
//  ISSLocationManager.swift
//  BackstageISS
//
//  Created by Donald Angelillo on 12/13/21.
//

import Foundation

class ISSLocationManager {
    static let sharedISSLocationManager = ISSLocationManager()
    
    func getCurrentLocation() {
        RequestManager.getJSON(url: Config.issCurrentLocationAPIURL, parameters: nil) { response in
            let currentISSPosition = CurrentISSPosition(json: response.jsonDict)
            print(currentISSPosition)
        }
    }
    
}
