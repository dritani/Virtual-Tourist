//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Dritani on 2016-03-18.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// Class responsible to represent a PHOTO in the core data model
class Photo: NSManagedObject {
    
    @NSManaged var photoURL: NSString?
    @NSManaged var photoPath: NSString?
    @NSManaged var pin: Pin?
    

    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(content: [String:AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)

        //photoURL = content[FlickrAPI.FlickrJSON.TagUrlM] as? NSString ?? ""
        photoURL = content["A"] as? NSString ?? ""
        
    }
    
}