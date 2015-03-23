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
    @NSManaged var progressText: String
    @NSManaged var quoteGroups: NSSet

    func addGroup(group: QuoteGroup) {
        let newQuotesSet = group.quotes.setByAddingObject(self)
        let newGroupsSet = self.quoteGroups.setByAddingObject(group)
        group.quotes = newQuotesSet
        self.quoteGroups = newGroupsSet
    }
    
    func strID() -> String {
        return "\(self.objectID)"
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        text = ""
        title = ""
        progressText = ""

    }

}
