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

/*
 * This class handles network operations, which in turn is implemented by the Networking library (https://github.com/3lvis/Networking).
 *
 */
class NetworkingManager: NSObject {

    // MARK: Shared instance
    static let sharedInstance = NetworkingManager()
    
    /*
     * Checks Internet connectivity
     *
     */
    let reachability = Reachability()!
    
    // MARK: Custom methods
    /*
     * Handles network calls.
     *
     * @param baseUrl The server base path
     * @param path The server subpath
     * @param method type of HTTP operation
     * @param headers HTTP headers
     * @param paramType
     * @param params HTTP parameters
     * @param completionHandler Block which is called after the network call
     */
    func doOperation(_ baseUrl: String,
                     path: String,
                     method: HTTPMethod,
                     headers: [String: String]?,
                     paramType: Networking.ParameterType,
                     params: AnyObject?,
                     completionHandler: @escaping NetworkingResult) -> Void {
        
        if !reachability.isReachable { // error, we have no Internet connection
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
    
    /*
     * Convenience method for downloading images.
     *
     * @param url The url of the image to be downloaded
     * @param completionHandler Block which is called after image is downloaded.
     */
    func downloadImage(_ url: URL, completionHandler: @escaping (_ origURL: URL?, _ image: UIImage?, _ error: NSError?) -> Void) {
        let networker = networking(forUrl: url)
        var path = url.path
        
        if let query = url.query {
            path += "?\(query)"
        }
        
        networker.downloadImage(path, completion: {(result) in
            switch result {
            case .success(let response):
                // skip from iCloud backups!
                do {
                    var destinationURL = try networker.destinationURL(for: path)
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = true
                    try destinationURL.setResourceValues(resourceValues)
                }
                catch {}
                completionHandler(url, response.image, nil)
            case .failure(let response):
                let error = response.error
                print("Networking error: \(error)")
                completionHandler(nil, nil, error)
            }
        })
    }

    // MARK: Private methods
    /*
     * Convenience method for creating a Networking object.
     *
     */
    fileprivate func networking(forBaseUrl url: String) -> Networking {
        return Networking(baseURL: url, configurationType: .ephemeral)
    }
    
    /*
     * Convenience method for creating a Networking object.
     *
     */
    fileprivate func networking(forUrl url: URL) -> Networking {
        var baseUrl = ""
        
        if let scheme = url.scheme {
            baseUrl = "\(scheme)://"
        }
        if let host = url.host {
            baseUrl.append(host)
        }
        
        return Networking(baseURL: baseUrl, configurationType: .ephemeral)
    }
}
