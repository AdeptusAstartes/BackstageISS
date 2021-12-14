//
//  Config.swift
//  BackstageISS
//
//  Created by Donald Angelillo on 12/13/21.
//

import Foundation

struct Config {
    static let baseAPIURL = "http://api.open-notify.org"
    
    // Only using force unwrapped optionals here because there is zero chance of failure
    static let issCurrentLocationAPIURL = URL(string: Config.baseAPIURL + "/iss-now/")!
    static let issPredictedPositionAPIURL = URL(string: Config.baseAPIURL + "/iss/v1/")!
}
