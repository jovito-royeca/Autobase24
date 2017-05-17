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
    var sortByFirstRegistration = true
    var origY = CGFloat(0)

    // MARK: Actions
    @IBAction func sortAction(_ sender: UIBarButtonItem) {
        sortByFirstRegistration = !sortByFirstRegistration
        
        sortButton.image = sortByFirstRegistration ? UIImage(named: "sort ascending") : UIImage(named: "sort descending")
        dataSource = getDataSource(nil)
        updateTableBackground()
    }

    @IBAction func calculateAction(_ sender: UIButton) {
        amountTextField.resignFirstResponder()
        
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
                    } else {
                        calculatorView.backgroundColor = UIColor.red
                    }
                    sender.setTitleColor(UIColor.white, for: .normal)
                    
                } else { // reset colors
                    calculatorView.backgroundColor = UIColor.white
                    sender.setTitleColor(UIColor.orange, for: .normal)
                }
            }
        }
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
    
    func keyboardDidShow(_ notification: Notification) {
        var newY = origY
        
        // raise the amount field above the keyboard
        if amountTextField.isFirstResponder {
            newY -= getKeyboardHeight(notification: notification)
            newY -= amountTextField.frame.origin.y
        }
        view.frame.origin.y = newY
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if amountTextField.isFirstResponder {
            view.frame.origin.y = origY
        }
    }
    
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
        return 118
    }
}

// MARK: DATASourceDelegate
extension FavoritesViewController: DATASourceDelegate {
    func dataSource(_ dataSource: DATASource, tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
    
    func dataSource(_ dataSource: DATASource, tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        
        let favorites = dataSource.all() as [Vehicle]
        favorites[indexPath.row].favorite = false
        try! APIManager.sharedInstance.dataStack.mainContext.save()
        updateTableBackground()
        calculateAction(calculateButton)
    }
}

