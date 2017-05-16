//
//  CarSummaryTableViewCell.swift
//  Autobase24
//
//  Created by Jovito Royeca on 16/05/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit

protocol CarSummaryTableViewCellDelegate {
    func toggle(vehicle: Vehicle, favorite: Bool)
}

class CarSummaryTableViewCell: UITableViewCell {
    // MARK: Variables
    var vehicle:Vehicle?
    var delegate:CarSummaryTableViewCellDelegate?
    
    // MARK: Outlets
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var starIcon: UIImageView!
    @IBOutlet weak var favoriteSwitch: UISwitch!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var powerKWLabel: UILabel!
    @IBOutlet weak var accidentLabel: UILabel!
    
    // MARK: Actions
    @IBAction func favoriteAction(_ sender: UISwitch) {
        starIcon.image = sender.isOn ? UIImage(named: "star-filled") : UIImage(named: "star")
        
        if let vehicle = vehicle,
            let delegate = delegate {
            delegate.toggle(vehicle: vehicle, favorite: sender.isOn)
        }
    }
    
    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        makeLabel.adjustsFontSizeToFitWidth = true
        priceLabel.adjustsFontSizeToFitWidth = true
        yearLabel.adjustsFontSizeToFitWidth = true
        addressLabel.adjustsFontSizeToFitWidth = true
        mileageLabel.adjustsFontSizeToFitWidth = true
        powerKWLabel.adjustsFontSizeToFitWidth = true
        accidentLabel.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Custom methods
    func updateDisplay(vehicle: Vehicle) {
        self.vehicle = vehicle

        if let images = vehicle.images {
            if let imagesArray = NSKeyedUnarchiver.unarchiveObject(with: images as Data) as? [String] {
                if let url = URL(string: imagesArray.first!) {
                    NetworkingManager.sharedInstance.downloadImage(url, completionHandler: {(_ origURL: URL?, _ image: UIImage?, _ error: NSError?) -> Void in
                        
                        if let _ = error {
                            print("image not found")
                        } else {
                            if url == origURL {
                                self.vehicleImage.image = image
                            }
                        }
                    })
                }
            } else {
                vehicleImage.image = nil
            }
            
        } else {
            vehicleImage.image = nil
        }
        
        makeLabel?.text = vehicle.make
        priceLabel?.text = "\u{20AC} \(vehicle.price)"
        if let firstRegistration = vehicle.firstRegistration {
            yearLabel.text = "year \(firstRegistration)"
        } else {
            yearLabel.text = "year -"
        }
        addressLabel.text = vehicle.address
        mileageLabel.text = "\(vehicle.mileage) km"
        powerKWLabel.text = "\(vehicle.powerKW) kW"
        accidentLabel.text = "\(vehicle.accidentFree ? "w/o accident" : "w/ accident")"
        detailTextLabel?.text = vehicle.make
        
        favoriteSwitch.isOn = vehicle.favorite
        starIcon.image = vehicle.favorite ? UIImage(named: "star-filled") : UIImage(named: "star")
    }
}
