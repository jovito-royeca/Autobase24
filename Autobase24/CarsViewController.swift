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
    @IBOutlet weak var makeSegmentedControl: UISegmentedControl!
    
    // MARK: Variables
    var dataSource: DATASource?
    var refreshControl:UIRefreshControl?
    var sortByFirstRegistration = true
    var makeIndex = 0

    // MARK: Actions
    @IBAction func sortAction(_ sender: UIBarButtonItem) {
        sortByFirstRegistration = !sortByFirstRegistration
        sortButton.image = sortByFirstRegistration ? UIImage(named: "sort ascending") : UIImage(named: "sort descending")
        
        var make:String? = nil
        switch makeIndex {
        case 1:
            make = "BMW"
        case 2:
            make = "Audi"
        case 3:
            make = "Mercedes-Benz"
        default:
            ()
        }
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Vehicle")
        request.sortDescriptors = [NSSortDescriptor(key: "firstRegistrationDate", ascending: self.sortByFirstRegistration)]
        
        if let make = make {
            request.predicate = NSPredicate(format: "make = %@", make)
        }
        dataSource = getDataSource(request)
        updateTableBackground()
    }
    
    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        makeIndex = sender.selectedSegmentIndex
        downloadData(showProgress: true)
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
        refreshControl!.addTarget(self, action: #selector(refreshAction(sender:)), for: .valueChanged)
        tableView.refreshControl = refreshControl

        // start download
        updateTableBackground()
        downloadData(showProgress:true)
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
    
    func refreshAction(sender: UIRefreshControl) {
        // cycle through the index for every refresh
        makeIndex = makeSegmentedControl.selectedSegmentIndex + 1
        if makeIndex > makeSegmentedControl.numberOfSegments - 1 {
            makeIndex = 0
        }
        makeSegmentedControl.selectedSegmentIndex = makeIndex
        
        downloadData(showProgress: false)
    }
    
    func downloadData(showProgress: Bool) {
        var path:BaseURLPath = .all
        var make:String? = nil
        
        switch makeIndex {
        case 0:
            path = .all
        case 1:
            path = .bmw
            make = "BMW"
        case 2:
            path = .audi
            make = "Audi"
        case 3:
            path = .mercedes
            make = "Mercedes-Benz"
        default:
            path = .all
        }
        
        if showProgress {
            MBProgressHUD.showAdded(to: tableView, animated: true)
        }
        APIManager.sharedInstance.fetchCars(path: path, completion: { error in
            let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Vehicle")
            request.sortDescriptors = [NSSortDescriptor(key: "firstRegistrationDate", ascending: self.sortByFirstRegistration)]
            
            if let make = make {
                request.predicate = NSPredicate(format: "make = %@", make)
            }

            self.dataSource = self.getDataSource(request)
            self.updateTableBackground()
            
            if showProgress {
                MBProgressHUD.hide(for: self.tableView, animated: true)
            } else {
                self.refreshControl!.endRefreshing()
            }
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
