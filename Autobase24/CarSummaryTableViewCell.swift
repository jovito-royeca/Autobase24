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
    @IBOutlet weak var addressIcon: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var powerKWLabel: UILabel!
    @IBOutlet weak var fuelTypeIcon: UIImageView!
    @IBOutlet weak var fuelTypeLabel: UILabel!
    
    // MARK: Actions
    @IBAction func favoriteAction(_ sender: UISwitch) {
        starIcon.image = sender.isOn ? UIImage(named: "star-filled") : UIImage(named: "star")
    
        if let image = starIcon.image {
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            starIcon.image = tintedImage
            starIcon.tintColor = UIColor.orange
        }
        
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
        fuelTypeLabel.adjustsFontSizeToFitWidth = true
        
        if let image = addressIcon.image {
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            addressIcon.image = tintedImage
            addressIcon.tintColor = UIColor.orange
        }
        if let image = fuelTypeIcon.image {
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            fuelTypeIcon.image = tintedImage
            fuelTypeIcon.tintColor = UIColor.orange
        }
    }

    override func prepareForReuse() {
        vehicleImage.image = nil
        
        makeLabel.text = ""
        priceLabel.text = ""
        yearLabel.text = ""
        addressLabel.text = ""
        mileageLabel.text = ""
        powerKWLabel.text = ""
        fuelTypeLabel.text = ""
        
        makeLabel.textColor = UIColor.black
        priceLabel.textColor = UIColor.black
        yearLabel.textColor = UIColor.black
        addressLabel.textColor = UIColor.black
        mileageLabel.textColor = UIColor.black
        powerKWLabel.textColor = UIColor.black
        fuelTypeLabel.textColor = UIColor.black
        
        if let image = addressIcon.image {
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            addressIcon.image = tintedImage
            addressIcon.tintColor = UIColor.orange
        }
        if let image = fuelTypeIcon.image {
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            fuelTypeIcon.image = tintedImage
            fuelTypeIcon.tintColor = UIColor.orange
        }
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
                    // Download the image in an asynchronous way.
                    NetworkingManager.sharedInstance.downloadImage(url, completionHandler: {(_ origURL: URL?, _ image: UIImage?, _ error: NSError?) -> Void in
                        
                        if error == nil{
                            if url == origURL {
                                self.vehicleImage.image = image
                            }
                        }
                    })
                }
            }
        }
        
        makeLabel?.text = vehicle.make
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "de_DE")
        priceLabel.text = currencyFormatter.string(from: NSNumber(value: vehicle.price)) //"\u{20AC} \(vehicle.price)"
        
        if let firstRegistration = vehicle.firstRegistration {
            yearLabel.text = "year \(firstRegistration)"
        } else {
            yearLabel.text = "year -"
        }
        
        // Show address after 2 seconds, to simulate heavy computing
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            // sleep ib bacjground thread
            sleep(2)
            
            // update the address label in main thread
            DispatchQueue.main.async {
                self.addressLabel.text = vehicle.address
            }
        }
        
        mileageLabel.text = String.localizedStringWithFormat("%i km", vehicle.mileage)
        
        let kWTohp = 1.3596216173039
        let hp = Int(Double(vehicle.powerKW) * kWTohp)
        powerKWLabel.text = "\(vehicle.powerKW) kW (\(hp) hp)"
        fuelTypeLabel.text = vehicle.fuelType
        
        if vehicle.accidentFree {
            favoriteSwitch.isHidden = false
            favoriteSwitch.isOn = vehicle.favorite
            starIcon.image = vehicle.favorite ? UIImage(named: "star-filled") : UIImage(named: "star")
            
            if let image = starIcon.image {
                let tintedImage = image.withRenderingMode(.alwaysTemplate)
                starIcon.image = tintedImage
                starIcon.tintColor = UIColor.orange
            }
        
        } else {
            // gray out everything
            makeLabel.textColor = UIColor.gray
            priceLabel.textColor = UIColor.gray
            yearLabel.textColor = UIColor.gray
            addressLabel.textColor = UIColor.gray
            mileageLabel.textColor = UIColor.gray
            powerKWLabel.textColor = UIColor.gray
            fuelTypeLabel.textColor = UIColor.gray
            
            favoriteSwitch.isHidden = true
            starIcon.image = UIImage(named: "crashed car")

            if let image = addressIcon.image {
                let tintedImage = image.withRenderingMode(.alwaysTemplate)
                addressIcon.image = tintedImage
                addressIcon.tintColor = UIColor.gray
            }
            if let image = fuelTypeIcon.image {
                let tintedImage = image.withRenderingMode(.alwaysTemplate)
                fuelTypeIcon.image = tintedImage
                fuelTypeIcon.tintColor = UIColor.gray
            }
            if let image = starIcon.image {
                let tintedImage = image.withRenderingMode(.alwaysTemplate)
                starIcon.image = tintedImage
                starIcon.tintColor = UIColor.gray
            }
        }
    }
}
