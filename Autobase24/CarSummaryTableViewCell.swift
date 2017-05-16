//
//  CarSummaryTableViewCell.swift
//  Autobase24
//
//  Created by Jovito Royeca on 16/05/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit

class CarSummaryTableViewCell: UITableViewCell {
    // MARK: Variables
    var imageURLs:[String]?
    
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
    func downloadImages(imageURLs: [String]) {
        self.imageURLs = imageURLs
        
        if let url = URL(string: imageURLs.first!) {
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
    }
}
