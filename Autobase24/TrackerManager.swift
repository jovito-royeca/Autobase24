//
//  TrackerManager.swift
//  Autobase24
//
//  Created by Jovito Royeca on 18/05/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit

class TrackerManager: NSObject {
    // MARK: Shared instance
    static let sharedInstance = TrackerManager()
    
    // MARK: Variables
    var logs = [[String: Any]]()
    
    func track(screenName: String, action: String, details: String) {
        logs.append(["screenName": screenName,
                     "action": action,
                     "details": details,
                     "date": Date()])
    }
    
    func printLogs() {
        for log in logs {
            print("\(log)")
        }
        
        // clear the logs after printing them
        logs.removeAll()
    }
}
