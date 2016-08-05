//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Sukh Kalsi on 27/12/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class Pin : NSManagedObject, MKAnnotation {

    @NSManaged var latitude : CLLocationDegrees
    @NSManaged var longitude : CLLocationDegrees
    @NSManaged var pictures: [Picture]
    
    //MARK: - MapKit
    var coordinate : CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Override Core Data initialisation
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // MARK: - Pin initialisation
    init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        // Core Data
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Location
        self.latitude = latitude
        self.longitude = longitude
    }
}
