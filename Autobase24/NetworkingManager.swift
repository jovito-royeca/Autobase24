//
//  NetworkingManager.swift
//  Autobase24
//
//  Created by Jovito Royeca on 16/05/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit

import Networking
import ReachabilitySwift

enum HTTPMethod: String {
    case post  = "Post",
    get  = "Get",
    head = "Head",
    put = "Put"
}

typealias NetworkingResult = (_ result: [[String : Any]], _ error: NSError?) -> Void

class NetworkingManager: NSObject {

    // MARK: Shared instance
    static let sharedInstance = NetworkingManager()
    
    let reachability = Reachability()!
    
    // MARK: Custom methods
    func doOperation(_ baseUrl: String,
                     path: String,
                     method: HTTPMethod,
                     headers: [String: String]?,
                     paramType: Networking.ParameterType,
                     params: AnyObject?,
                     completionHandler: @escaping NetworkingResult) -> Void {
        if !reachability.isReachable {
            let error = NSError(domain: "network", code: 408, userInfo: [NSLocalizedDescriptionKey: "Network error."])
            completionHandler([[String : Any]](), error)
            
        } else {
            let networker = networking(forBaseUrl: baseUrl)
            
            if let headers = headers {
                networker.headerFields = headers
            }
            
            switch (method) {
            case .post:
                networker.post(path, parameterType: paramType, parameters: params, completion: {(result) in
                    switch result {
                    case .success(let response):
                        if response.json.dictionary.count > 0 {
                            completionHandler([response.json.dictionary], nil)
                        } else if response.json.array.count > 0 {
                            completionHandler(response.json.array, nil)
                        } else {
                            completionHandler([[String : Any]](), nil)
                        }
                    case .failure(let response):
                        let error = response.error
                        print("Networking error: \(error)")
                        completionHandler([[String : Any]](), error)
                    }
                })
            case .get:
                networker.get(path, parameters: params, completion: {(result) in
                    switch result {
                    case .success(let response):
                        if response.json.dictionary.count > 0 {
                            completionHandler([response.json.dictionary], nil)
                        } else if response.json.array.count > 0 {
                            completionHandler(response.json.array, nil)
                        } else {
                            completionHandler([[String : Any]](), nil)
                        }
                    case .failure(let response):
                        let error = response.error
                        print("Networking error: \(error)")
                        completionHandler([[String : Any]](), error)
                    }
                })
            case .head:
                ()
            case .put:
                networker.put(path, parameterType: paramType, parameters: params, completion: {(result) in
                    switch result {
                    case .success(let response):
                        if response.json.dictionary.count > 0 {
                            completionHandler([response.json.dictionary], nil)
                        } else if response.json.array.count > 0 {
                            completionHandler(response.json.array, nil)
                        } else {
                            completionHandler([[String : Any]](), nil)
                        }
                    case .failure(let response):
                        let error = response.error
                        print("Networking error: \(error)")
                        completionHandler([[String : Any]](), error)
                    }
                })
            }
        }
    }
    
    // MARK: Private methods
    fileprivate func networking(forBaseUrl url: String) -> Networking {
        return Networking(baseURL: url, configurationType: .default)
    }
    
    fileprivate func networking(forUrl url: URL) -> Networking {
        var baseUrl = ""
        
        if let scheme = url.scheme {
            baseUrl = "\(scheme)://"
        }
        if let host = url.host {
            baseUrl.append(host)
        }
        
        return Networking(baseURL: baseUrl, configurationType: .default)
    }
}