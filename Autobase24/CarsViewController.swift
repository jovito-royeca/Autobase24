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

class CarsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: Variables
    var dataSource: DATASource?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "CarSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "CarSummaryCell")
        
        APIManager.sharedInstance.fetchCars(completion: { error in
            self.dataSource = self.getDataSource(nil)
            self.tableView.reloadData()
        })
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
            request!.sortDescriptors = [NSSortDescriptor(key: "firstRegistration", ascending: true)]
        }
        
        let dataSource = DATASource(tableView: tableView, cellIdentifier: "CarSummaryCell", fetchRequest: request!, mainContext: APIManager.sharedInstance.dataStack.mainContext, sectionName: nil, configuration: { cell, item, indexPath in
            if let vehicle = item as? Vehicle,
                let cell = cell as? CarSummaryTableViewCell{
                self.configureCell(cell, withVehicle: vehicle)
            }
        })
        
        return dataSource
    }
    
    func configureCell(_ cell: CarSummaryTableViewCell, withVehicle vehicle: Vehicle) {
        if let images = vehicle.images {
            if let imagesArray = NSKeyedUnarchiver.unarchiveObject(with: images as Data) as? [String] {
                cell.downloadImages(imageURLs: imagesArray)
            } else {
                cell.vehicleImage.image = nil
            }
            
        } else {
            cell.vehicleImage.image = nil
        }
        
        cell.makeLabel?.text = vehicle.make
        cell.priceLabel?.text = "\u{20AC} \(vehicle.price)"
        if let firstRegistration = vehicle.firstRegistration {
            cell.yearLabel.text = "year \(firstRegistration)"
        } else {
            cell.yearLabel.text = "year -"
        }
        cell.addressLabel.text = vehicle.address
        cell.mileageLabel.text = "\(vehicle.mileage) km"
        cell.powerKWLabel.text = "\(vehicle.powerKW) kW"
        cell.accidentLabel.text = "\(vehicle.accidentFree ? "w/o accident" : "w/ accident")"
        cell.detailTextLabel?.text = vehicle.make
    }
}

// MARK: UITableViewDelegate
extension CarsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118
    }
}
