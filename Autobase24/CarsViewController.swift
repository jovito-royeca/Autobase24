//
//  CarsViewController.swift
//  Autobase24
//
//  Created by Jovito Royeca on 16/05/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import DATAStack
import DATASource
import MBProgressHUD

class CarsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundLabel: UILabel!

    // MARK: Variables
    var dataSource: DATASource?
    var refreshControl:UIRefreshControl?
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
        dataSource = self.getDataSource(nil)
        
        tableView.register(UINib(nibName: "CarSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "CarSummaryCell")
        tableView.backgroundView = backgroundLabel

        // init the refresh control
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor.orange
        refreshControl!.tintColor = UIColor.white
        refreshControl!.addTarget(self, action: #selector(CarsViewController.downloadData), for: .valueChanged)
        tableView.refreshControl = refreshControl

        // start download
        updateTableBackground()
        refreshControl!.beginRefreshing()
        downloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTableBackground()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Custom methods
    func getDataSource(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>?) -> DATASource? {
        var request:NSFetchRequest<NSFetchRequestResult>?
        if let fetchRequest = fetchRequest {
            request = fetchRequest
        } else {
            request = NSFetchRequest(entityName: "Vehicle")
            request!.sortDescriptors = [NSSortDescriptor(key: "firstRegistrationDate", ascending: sortByFirstRegistration)]
        }
        
        let dataSource = DATASource(tableView: tableView, cellIdentifier: "CarSummaryCell", fetchRequest: request!, mainContext: APIManager.sharedInstance.dataStack.mainContext, sectionName: nil, configuration: { cell, item, indexPath in
            if let vehicle = item as? Vehicle,
                let cell = cell as? CarSummaryTableViewCell{
                cell.delegate = self
                cell.updateDisplay(vehicle: vehicle)
            }
        })
        
        return dataSource
    }
    
    func downloadData() {
        APIManager.sharedInstance.fetchCars(completion: { error in
            self.updateTableBackground()
            self.refreshControl!.endRefreshing()
        })
    }
    
    func updateTableBackground() {
        if let dataSource = dataSource {
            
            if dataSource.all().count == 0 {
                tableView.separatorStyle = .none
                backgroundLabel.text = "No data is currently available. You may pull down to refresh."
            } else {
                tableView.separatorStyle = .singleLine
                backgroundLabel.text = nil
            }
            
            tableView.reloadData()
        }
    }
}

// MARK: UITableViewDelegate
extension CarsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118
    }
}

// MARK: CarSummaryTableViewCellDelegate
extension CarsViewController : CarSummaryTableViewCellDelegate {
    func toggle(vehicle: Vehicle, favorite: Bool) {
        vehicle.favorite = favorite
        try! APIManager.sharedInstance.dataStack.mainContext.save()
    }
}
