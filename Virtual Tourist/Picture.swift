//
//  Picture.swift
//  Virtual Tourist
//
//  Created by Sukh Kalsi on 27/12/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import UIKit
import CoreData

class Picture : NSManagedObject {
    
    @NSManaged var photoID : NSNumber?
    @NSManaged var imagePath : String?
    @NSManaged var imageURL : NSURL?
    @NSManaged var location: Pin?
    
    // MARK: - Override Core Data initialisation
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // MARK: - Picture initialisation
    init(imageURL: NSURL, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Picture", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Image
        self.imageURL = imageURL
        self.imagePath = imageURL.lastPathComponent
    }
    
    var locationImage: UIImage? {
        
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath!)
        }
    }
}
