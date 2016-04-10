//
//  Event.swift
//  PlainMasterDetail
//
//  Created by Jason on 3/18/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//


/**
* There are 6 changes to be made. They are listed below, and called out in comments in the
* code. Notice that the only attribute in this class is "timeStamp", and it gets the current
* timeStamp by default.
*
* 1. import Core Data
* 2. Make Event a subclass of NSManagedObject
* 3. Add @NSManaged in front of the timeStamp properties/attributes
* 4. Include the standard Core Data init:
* 
*     init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?)
*
* 5. Write an init method that only needs a context. 
*
*    init(context: NSManagedObjectContext)
*/

import Foundation
import CoreData

class Event : NSManagedObject {

    @NSManaged var timeStamp: NSDate

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        timeStamp = NSDate()
    }
}
