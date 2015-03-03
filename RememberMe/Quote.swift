//
//  Quote.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/3/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import Foundation
import CoreData

class Quote: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var text: String
    @NSManaged var bestTime: NSDate
    @NSManaged var inProgress: NSNumber
    @NSManaged var currentTime: NSDate

}
