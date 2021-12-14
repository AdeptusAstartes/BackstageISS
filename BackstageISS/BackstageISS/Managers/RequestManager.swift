//
//  RequestManager.swift
//  Heavy Headlines
//
//  Created by Donald Angelillo on 10/18/20.
//  Copyright © 2020 Donald Angelillo. All rights reserved.
//

import Foundation

/*
 Please note that this is a very heavily modified and truncated version of how I would normally create and make API requests.
 It relies on simple URLSession requests instead of Alamofire (which I would normally use) because I didn't want to get all crazy
 with the dependencies here.  The scope is limited to GET requests since that's all we're doing
 
 Please note that there are no checks for an active network connection before performing a request (they have been removed so as to not
 add the addional complexity of Reachability code to the project) and the response handling has been greatly simplified as well.
 
 There is a bunch of boilerplate code at the end to create query string parameterized GET requests cause I didn't want to just
 construct a "string" with the qs params and make a url out of that.  I wanted to demonstrate a through understanding of working with
 HTTP requests (well at least GETs) and not oversimplify things TOO much.
 */

class RequestManager {
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
