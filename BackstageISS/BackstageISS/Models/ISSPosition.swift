//
//  ISSPosition.swift
//  BackstageISS
//
//  Created by Donald Angelillo on 12/13/21.
//

import Foundation

struct ISSPosition: Codable {
    var timestamp: Double = 0
    var latitude: Double = 0
    var longitude: Double = 0
    
    var isPrediction: Bool {
        return true
    }
    
    init(currentPositionJSON: [String: Any?]) {
        if let timestamp = currentPositionJSON["timestamp"] as? Double {
            self.timestamp = timestamp
        }
        
        // For some reason both latitude and longitude are strings in this API response
        if let position = currentPositionJSON["iss_position"] as? [String: String] {
            if let latitude = Double(position["latitude"] ?? "0") {
                self.latitude = latitude
            }
            
            if let longitude = Double(position["longitude"] ?? "0") {
                self.longitude = longitude
            }
        }
    }
    
    // The JSON shape of the response for the predicted pass API is totally different than the shape
    // from the current position API.  So this model has a separate initializer to parse that JSON.
    init(predictedPositionJSON: [String: Any?]) {
        // Not strings this time!
        if let request = predictedPositionJSON["request"] as? [String: Any] {
            if let latitude = request["latitude"] as? Double {
                self.latitude = latitude
            }
            
            if let longitude = request["longitude"] as? Double {
                self.longitude = longitude
            }
        }
        
        if let request = predictedPositionJSON["response"] as? [[String: Any]] {
            if let timestamp = request.first?["risetime"] as? Double {
                self.timestamp = timestamp
            }
        }
    }
}
