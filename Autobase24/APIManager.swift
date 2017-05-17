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
let AllCarsPath      = "/make=all.json"
let AudiCarsPath     = "/make=audi.json"
let BMWCarsPath      = "/make=bmw.json"
let MercedesCarsPath = "/make=mercedes-benz.json"

class APIManager: NSObject {
    // MARK: Variables
    let dataStack = DATAStack(modelName: "Autobase24Model")
    
    // MARK: Shared instance
    static let sharedInstance = APIManager()
    
    func fetchCars(completion: @escaping (NSError?) -> Void) {
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
                                                     path: AllCarsPath,
                                                     method: method,
                                                     headers: headers,
                                                     paramType: paramType,
                                                     params: params,
                                                     completionHandler: completionHandler)

    }
    
    // MARK: Custom methods
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
    
    func format(_ interval: TimeInterval) -> String {
        
        if interval == 0 {
            return "HH:mm:ss"
        }
        
        let seconds = interval.truncatingRemainder(dividingBy: 60)
        let minutes = (interval / 60).truncatingRemainder(dividingBy: 60)
        let hours = (interval / 3600)
        return String(format: "%.2d:%.2d:%.2d", Int(hours), Int(minutes), Int(seconds))
    }
}
