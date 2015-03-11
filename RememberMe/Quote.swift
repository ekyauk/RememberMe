//
//  Quote.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/11/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import Foundation
import CoreData

class Quote: NSManagedObject {

    @NSManaged var bestTime: NSDate
    @NSManaged var currentTime: NSDate
    @NSManaged var inProgress: NSNumber
    @NSManaged var text: String
    @NSManaged var title: String
    @NSManaged var quoteGroups: NSSet

}
