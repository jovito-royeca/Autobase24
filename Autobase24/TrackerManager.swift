//
//  TrackerManager.swift
//  Autobase24
//
//  Created by Jovito Royeca on 18/05/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit

/*
 * This class stores tracking logs for user interactions (touches) in the app.
 *
 */
class TrackerManager: NSObject {
    // MARK: Shared instance
    static let sharedInstance = TrackerManager()
    
    // MARK: Variables
    
    /*
     * Tracks the logs with meaningful names.
     *
     */
    var logs = [[String: Any]]()
    
    /*
     * Adds an entry to the logs.
     *
     * @param screenName Where the log occured
     * @param action The name of the user action that occured
     * @param details Useful details for the action
     */
    func track(screenName: String, action: String, details: String) {
        logs.append(["screenName": screenName,
                     "action": action,
                     "details": details,
                     "date": Date()])
    }
    
    /*
     * Prints all the logs and clears them. usually called when the app entered the background.
     *
     */
    func printLogs() {
        for log in logs {
            print("\(log)")
        }
        
        // clear the logs after printing them
        logs.removeAll()
    }
}
