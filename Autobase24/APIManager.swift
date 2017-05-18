//
//  APIManager.swift
//  Autobase24
//
//  Created by Jovito Royeca on 16/05/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import DATAStack
import Networking
import Sync

let BaseURL          = "http://sumamo.de/iOS-TechChallange/api/index"

enum BaseURLPath: String {
    case all  = "/make=all.json",
    bmw       = "/make=bmw.json",
    audi      = "/make=audi.json",
    mercedes  = "/make=mercedes-benz.json"
}

/*
 * This class handles fetching of data from the server.
 *
 */
class APIManager: NSObject {
    // MARK: Variables
    let dataStack = DATAStack(modelName: "Autobase24Model")
    
    // MARK: Shared instance
    static let sharedInstance = APIManager()
    
    /*
     * Fetches data from the server. Note that the String property firstRegistration is saved as a Date property
     * in firstRegistrationDate to enable correct sorting. SyncDB (https://github.com/SyncDB/Sync) easily handles
     * parsing and saving JSON data from the server to Core Data
     *
     * @param path Filter for the make property
     * @param completion Block that is called after the data is fetched from the server
     */
    func fetchCars(path: BaseURLPath, completion: @escaping (NSError?) -> Void) {
        let method:HTTPMethod = .get
        let headers:[String: String]? = nil
        let paramType:Networking.ParameterType = .json
        let params:AnyObject? = nil
        
        let completionHandler = { (result: [[String : Any]], error: NSError?) -> Void in
            if let error = error {
                completion(error)
                
            } else {
                let notifName = NSNotification.Name.NSManagedObjectContextObjectsDidChange
                let operations:Sync.OperationOptions = [.insert, .update] //.all
                var data = [[String : Any]]()
                
                if let first = result.first {
                    if let vehicles = first["vehicles"] as? [[String : Any]] {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MM/yyyy"
                        
                        for vehicle in vehicles {
                            var dict = [String : Any]()
                            
                            for (k,v) in vehicle {
                                dict[k] = v
                                
                                if k == "FirstRegistration" {
                                    dict["firstRegistrationDate"] = formatter.date(from: v as! String)
                                }
                            }
                            data.append(dict)
                        }
                    }
                }
                
                self.dataStack.performInNewBackgroundContext { backgroundContext in
                    NotificationCenter.default.addObserver(self, selector: #selector(APIManager.changeNotification(_:)), name: notifName, object: backgroundContext)
                    Sync.changes(data,
                                 inEntityNamed: "Vehicle",
                                 predicate: nil,
                                 parent: nil,
                                 parentRelationship: nil,
                                 inContext: backgroundContext,
                                 operations: operations,
                                 completion:  { error in
                                    NotificationCenter.default.removeObserver(self, name:notifName, object: nil)
                                    completion(error)
                                })
                }
            }
        }
        
        NetworkingManager.sharedInstance.doOperation(BaseURL,
                                                     path: path.rawValue,
                                                     method: method,
                                                     headers: headers,
                                                     paramType: paramType,
                                                     params: params,
                                                     completionHandler: completionHandler)

    }
    
    // MARK: Custom methods

    /*
     * Prints Core Data operations.
     *
     */
    func changeNotification(_ notification: Notification) {
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] {
            if let set = updatedObjects as? NSSet {
                print("updatedObjects: \(set.count)")
            }
        }
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] {
            if let set = deletedObjects as? NSSet {
                print("deletedObjects: \(set.count)")
            }
        }
        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] {
            if let set = insertedObjects as? NSSet {
                print("insertedObjects: \(set.count)")
            }
        }
    }
}
