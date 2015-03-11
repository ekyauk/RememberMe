//
//  QuoteGroup.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/11/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import Foundation
import CoreData

class QuoteGroup: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var quotes: NSSet

}
