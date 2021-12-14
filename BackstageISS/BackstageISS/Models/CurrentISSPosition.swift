//
//  CurrentISSPosition.swift
//  BackstageISS
//
//  Created by Donald Angelillo on 12/13/21.
//

import Foundation

struct CurrentISSPosition: Codable {
    var timestamp: Int = 0
    var latitude: Float = 0
    var longitude: Float = 0
    
    init(json: [String: Any?]) {
        if let timestamp = json["timestamp"] as? Int {
            self.timestamp = timestamp
        }
        
        // For some reason both latitude and longitude are strings in this API response
        if let position = json["iss_position"] as? [String: String] {
            if let latitude = Float(position["latitude"] ?? "0") {
                self.latitude = latitude
            }
            
            if let longitude = Float(position["longitude"] ?? "0") {
                self.longitude = longitude
            }
        }
    }
}
