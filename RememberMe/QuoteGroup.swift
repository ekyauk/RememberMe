//
//  QuoteGroup.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/11/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class QuoteGroup: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var quotes: NSSet

    func addQuote(quote: Quote) {
        let newGroupsSet = quote.quoteGroups.setByAddingObject(self)
        let newQuotesSet = self.quotes.setByAddingObject(quote)
        self.quotes = newQuotesSet
        quote.quoteGroups = newGroupsSet
    }

    
    class func createGroup(name: String, managedObjectContext: NSManagedObjectContext) -> QuoteGroup? {
        let quoteGroup = NSEntityDescription.insertNewObjectForEntityForName("QuoteGroup", inManagedObjectContext: managedObjectContext) as? QuoteGroup
        quoteGroup?.name = name
        var error: NSError? = NSError()
        if !managedObjectContext.save(&error) {
            NSLog("Unresolved error: \(error), \(error!.userInfo)")
            abort()
        }
        return quoteGroup
    }
    
    class func clearAll(managedObjectContext: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest(entityName: "QuoteGroup")
        if let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [QuoteGroup] {
            for group in fetchResults {
                managedObjectContext.deleteObject(group)
            }
        }
    }
    
    class func all() -> [QuoteGroup]? {
        let managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
        var fetchReq = NSFetchRequest(entityName: "QuoteGroup")
        return managedObjectContext.executeFetchRequest(fetchReq, error: nil) as? [QuoteGroup]
    }

    class func getGroup(name: String, managedObjectContext: NSManagedObjectContext) -> QuoteGroup {
        var fetchReq = NSFetchRequest(entityName: "QuoteGroup")
        var error: NSError? = NSError()
        fetchReq.predicate = NSPredicate(format: "name = %@", argumentArray: [name])
        var quoteGroup: QuoteGroup?
        if let fetchResults = managedObjectContext.executeFetchRequest(fetchReq, error: &error) {
            if fetchResults.isEmpty {
                quoteGroup = createGroup(name, managedObjectContext: managedObjectContext)
            } else {
                quoteGroup = fetchResults[0] as? QuoteGroup
            }
        }
        return quoteGroup!
    }

}
