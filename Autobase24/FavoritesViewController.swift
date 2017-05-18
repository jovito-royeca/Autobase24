//
//  FavoritesViewController.swift
//  Autobase24
//
//  Created by Jovito Royeca on 16/05/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import DATAStack
import DATASource

class FavoritesViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundLabel: UILabel!
    @IBOutlet weak var calculatorView: UIView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var calculateButton: UIButton!
    
    // MARK: Variables
    var dataSource: DATASource?
    
    /*
     * Tracks the sort order. Ascending = true, Descending = false
     *
     */
    var sortByFirstRegistration = true
    
    /*
     * Tracks the original frame.origin.y of self.view
     *
     */
    var origY = CGFloat(0)

    // MARK: Actions
    
    /*
     * Sorts the favorite vehicles via firstRegistrationDate property
     *
     */
    @IBAction func sortAction(_ sender: UIBarButtonItem) {
        sortByFirstRegistration = !sortByFirstRegistration
        
        sortButton.image = sortByFirstRegistration ? UIImage(named: "sort ascending") : UIImage(named: "sort descending")
        dataSource = getDataSource(nil)
        updateTableBackground()
        
        // track action
        let screenName = String(describing: type(of: self))
        let action = "sort"
        let details = sortByFirstRegistration ? "ascending" : "descending"
        TrackerManager.sharedInstance.track(screenName: screenName, action: action, details: details)
    }

    /*
     * Calculates the prices of all favorite vehicles. The bar becomes green if the entered amount is equal or bigger than
     * the sum of prices of the cars on the list. Otherwise it becomes red.
     *
     */
    @IBAction func calculateAction(_ sender: UIButton) {
        amountTextField.resignFirstResponder()
        var result = "reset"

        if let dataSource = dataSource,
            let text = amountTextField.text {
            let favorites = dataSource.all() as [Vehicle]
            var amount = 0.0
            var totalAmount = 0.0
            
            if dataSource.all().count == 0 { // reset colors
                calculatorView.backgroundColor = UIColor.white
                sender.setTitleColor(UIColor.orange, for: .normal)
                
            } else {
                if text.characters.count > 0 { // procede with calculation
                    amount = Double(text)!
                    
                    for favorite in favorites {
                        totalAmount += favorite.price
                    }
                    
                    if amount >= totalAmount {
                        calculatorView.backgroundColor = UIColor.green
                        result = "green"
                    } else {
                        calculatorView.backgroundColor = UIColor.red
                        result = "red"
                    }
                    sender.setTitleColor(UIColor.white, for: .normal)
                    
                } else { // reset colors
                    calculatorView.backgroundColor = UIColor.white
                    sender.setTitleColor(UIColor.orange, for: .normal)
                }
            }
        }
        
        // track action
        let screenName = String(describing: type(of: self))
        let action = "calculate"
        let details = result
        TrackerManager.sharedInstance.track(screenName: screenName, action: action, details: details)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "CarSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "CarSummaryCell")
        tableView.backgroundView = backgroundLabel
        dataSource = getDataSource(nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        updateTableBackground()
        calculateAction(calculateButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        origY = view.frame.origin.y
        
        // remove the badge, also remove the contents of CarsViewController.newCars
        navigationController?.tabBarItem.badgeValue = nil
        if let tabBar = navigationController?.parent as? UITabBarController {
            if let carsNVC = tabBar.viewControllers?.first {
                if let carsVC = carsNVC.childViewControllers.first as? CarsViewController {
                    carsVC.newCars.removeAll()
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: CUstom methods
    
    /*
     * Setup the DATASource for Favorite Vehicles
     *
     */
    func getDataSource(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>?) -> DATASource? {
        var request:NSFetchRequest<NSFetchRequestResult>?
        if let fetchRequest = fetchRequest {
            request = fetchRequest
        } else {
            request = NSFetchRequest(entityName: "Vehicle")
            request?.predicate = NSPredicate(format: "favorite = true")
            request!.sortDescriptors = [NSSortDescriptor(key: "firstRegistrationDate", ascending: sortByFirstRegistration)]
        }
        
        let dataSource = DATASource(tableView: tableView, cellIdentifier: "CarSummaryCell", fetchRequest: request!, mainContext: APIManager.sharedInstance.dataStack.mainContext, sectionName: nil, configuration: { cell, item, indexPath in
            if let vehicle = item as? Vehicle,
                let cell = cell as? CarSummaryTableViewCell{
                cell.updateDisplay(vehicle: vehicle)
                cell.favoriteSwitch.isHidden = true
                cell.starIcon.image = UIImage(named: "star-filled")
                if let image = cell.starIcon.image {
                    let tintedImage = image.withRenderingMode(.alwaysTemplate)
                    cell.starIcon.image = tintedImage
                    cell.starIcon.tintColor = UIColor.orange
                }
            }
        })
        
        dataSource.delegate = self

        return dataSource
    }
    
    /*
     * Show a message in tableView background if there is no data, otherwise show the data cells.
     * Also, recalculate the entered amount. @see calculateAction(_:)
     *
     */
    func updateTableBackground() {
        if let dataSource = dataSource {
            if dataSource.all().count == 0 {
                tableView.separatorStyle = .none
                backgroundLabel.text = "No Favorites currently available. Try adding some at the Cars tab."
                amountTextField.isEnabled = false
                calculateButton.isEnabled = false
            } else {
                tableView.separatorStyle = .singleLine
                backgroundLabel.text = nil
                amountTextField.isEnabled = true
                calculateButton.isEnabled = true
            }
            tableView.reloadData()
        }
    }
    
    //MARK: un/subscription to notifications
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: Keyboard
    func keyboardWillShow(_ notification: Notification) {
        keyboardDidShow(notification)
    }

    /*
     * Raises the amountTextField above the keyboard
     *
     */
    func keyboardDidShow(_ notification: Notification) {
        var newY = origY
        
        if amountTextField.isFirstResponder {
            newY -= getKeyboardHeight(notification: notification)
            newY -= amountTextField.frame.origin.y
        }
        view.frame.origin.y = newY
    }
    
    /*
     * Restores the amountTextField in its original location.
     *
     */
    func keyboardWillHide(_ notification: Notification) {
        if amountTextField.isFirstResponder {
            view.frame.origin.y = origY
        }
    }
    
    /*
     * Calculates the keyboard height.
     *
     */
    func getKeyboardHeight(notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        var height = keyboardSize.cgRectValue.height
        
        if let nav = navigationController {
            height -= nav.toolbar.frame.size.height
        }
        
        return height
    }
}

// MARK: UITableViewDelegate
extension FavoritesViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCarSummaryTableViewCellHeight
    }
}

// MARK: DATASourceDelegate
extension FavoritesViewController: DATASourceDelegate {
    /*
     * Enable row deletions in the table. If the user swipes left, the Delete button becoms visible
     *
     */
    func dataSource(_ dataSource: DATASource, tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
    
    /*
     * Removes the favorite and recalculates the amount entered. @see calculateAction(_:)
     *
     */
    func dataSource(_ dataSource: DATASource, tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        
        let favorites = dataSource.all() as [Vehicle]
        favorites[indexPath.row].favorite = false
        try! APIManager.sharedInstance.dataStack.mainContext.save()
        updateTableBackground()
        calculateAction(calculateButton)
        
        // track action
        let screenName = String(describing: type(of: self))
        let action = "delete"
        let details = "\(favorites[indexPath.row].id)"
        TrackerManager.sharedInstance.track(screenName: screenName, action: action, details: details)
    }
}

