//
//  Vehicle+CoreDataProperties.swift
//  Autobase24
//
//  Created by Jovito Royeca on 16/05/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


extension Vehicle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vehicle> {
        return NSFetchRequest<Vehicle>(entityName: "Vehicle")
    }

    @NSManaged public var id: Int32
    @NSManaged public var firstRegistration: String?
    @NSManaged public var accidentFree: Bool
    @NSManaged public var images: NSData?
    @NSManaged public var powerKW: Int32
    @NSManaged public var mileage: Int32
    @NSManaged public var make: String?
    @NSManaged public var fuelType: String?
    @NSManaged public var address: String?
    @NSManaged public var price: Double
    @NSManaged public var favorite: Bool
}
