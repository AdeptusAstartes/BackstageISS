//
//  RequestManager.swift
//  Heavy Headlines
//
//  Created by Donald Angelillo on 10/18/20.
//  Copyright © 2020 Donald Angelillo. All rights reserved.
//

import Foundation

class RequestManager {
    static let sharedRequestManager = RequestManager()

    static func getJSON(url: URL, parameters: [String: Any]? = nil, completion: @escaping (_ json: RequestManagerJSONResponse) -> ()) {
        let request = URLUtils.jsonGETRequest(url: url, queryStringParams: parameters)
        
        let sessionTask = URLSession.shared.dataTask(with: request) { data, response, error in
            let jsonResponse = RequestManagerJSONResponse(data: data, response: response as? HTTPURLResponse, error: error)
            completion(jsonResponse)
        }
        
        sessionTask.resume()
    }
}

class RequestManagerResponse {
    internal var response: HTTPURLResponse?
    var error: Error?
    
    var statusCode: Int? {
        return self.response?.statusCode
    }
    
    init(response: HTTPURLResponse?, error: Error?) {
        self.response = response
        self.error = error
    }
    
}


class RequestManagerJSONResponse: RequestManagerResponse {
    var data: Data?
    
    private var json: Any? {
        guard let data = self.data else {
            return nil
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json
        } catch {
            return nil
        }
    }

    var jsonArray: [[String: Any]]? {
        if let array = self.json as? [[String: Any]] {
            return array
        } else {
            return []
        }
    }

    var jsonDict: [String: Any] {
        if let dictionary = self.json as? [String: Any] {
            return dictionary
        } else {
            return [:]
        }
    }
    
    init(data: Data?, response: HTTPURLResponse?, error: Error?) {
        super.init(response: response, error: error)
        self.data = data
    }
}

struct RequestManagerError: Error {
    enum RequestManagerErrorType {
        case noNetworkConnection
        case unkown
    }

    var errorType: RequestManagerErrorType = .unkown

    static func noNetworkConnectionError() -> RequestManagerError {
        var error = RequestManagerError()
        error.errorType = .noNetworkConnection
        return error
    }
}


struct URLUtils {
    static func jsonGETRequest(url: URL, queryStringParams:  [String: Any]? = nil, ignoreCaching: Bool = false) -> URLRequest {
        return URLUtils.jsonGETRequest(url: url, method: "GET", queryStringParams: queryStringParams, ignoreCaching: ignoreCaching)
    }

    private static func jsonGETRequest(url: URL, method: String, queryStringParams:  [String: Any]? = nil, ignoreCaching: Bool = false) -> URLRequest {
        var _url = url
        
        if let queryStringParams = queryStringParams {
            let queryString: String = URLUtils.createQueryStringParams(params: queryStringParams)
            
            if let urlWithQueryString = URL(string: "\(url.scheme!)://\(url.host!)\(url.path)?\(queryString)") {
                _url = urlWithQueryString
            }
        }
        
        var request = URLRequest(url: _url)
        request.httpMethod = method.uppercased()
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if (ignoreCaching) {
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        }
        
        return request
    }
    
    //MARK: - Query String Methods
    private static func createQueryStringParams(params: [String: Any]) -> String {
        var components: [(String, String)] = Array()
        
        for key in Array(params.keys).sorted(by: <) {
            if let value = params[key] {
                components += URLUtils.queryStringComponents(key: key, value: value)
            }
        }
        
        return (components.map{ "\($0)=\($1)" } as [String]).joined(separator: "&")
    }
    
    private static func queryStringComponents(key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += URLUtils.queryStringComponents(key: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += URLUtils.queryStringComponents(key: "\(key)[]", value: value)
            }
        } else {
            components.append((URLUtils.escape(string: key), URLUtils.escape(string: "\(value)")))
        }
        
        return components
    }
    
    private static func escape(string: String) -> String {
        let allowedCharacters = CharacterSet(charactersIn: "/?:@&=+!$, ").inverted
        
        if let escapedString = string.addingPercentEncoding(withAllowedCharacters: allowedCharacters) {
            return escapedString
        } else {
            return string
        }
    }
}
