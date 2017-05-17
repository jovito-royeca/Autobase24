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

    // MARK: Variables
    var dataSource: DATASource?
    var sortByFirstRegistration = true

    // MARK: Actions
    @IBAction func sortAction(_ sender: UIBarButtonItem) {
        sortByFirstRegistration = !sortByFirstRegistration
        
        sortButton.image = sortByFirstRegistration ? UIImage(named: "sort ascending") : UIImage(named: "sort descending")
        dataSource = getDataSource(nil)
        updateTableBackground()
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
        updateTableBackground()
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
                cell.starIcon.isHidden = true
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
            } else {
                tableView.separatorStyle = .singleLine
                backgroundLabel.text = nil
            }
            tableView.reloadData()
        }
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
    }
}

