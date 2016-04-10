//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Dritani on 2016-03-18.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import Foundation
import CoreData
import MapKit

// Class responsible to represent a PIN in the core data model
class Pin: NSManagedObject, MKAnnotation {
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]
    @NSManaged var totalPages: NSNumber
    @NSManaged var pageNum: NSNumber
    private var _coords: CLLocationCoordinate2D?
    var coordinate: CLLocationCoordinate2D {
        
        set {
            willChangeValueForKey("coordinate")
            _coords = newValue
            
            // set the new values of the lat and long
            if let coord = _coords {
                latitude = coord.latitude
                longitude = coord.longitude
            }
            
            didChangeValueForKey("coordinate")
        }
        
        get {
            if _coords == nil {
                _coords = CLLocationCoordinate2DMake(latitude as CLLocationDegrees, longitude as CLLocationDegrees)
            }
            
            return _coords!
        }
    }
    
    var title: String? = nil
    var subtitle: String? = nil
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(latitude: NSNumber, longitude: NSNumber, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude
        self.longitude = longitude
        
        coordinate = CLLocationCoordinate2DMake(latitude as CLLocationDegrees, longitude as CLLocationDegrees)
        
        totalPages = -1
        pageNum = 1
    }
}
