//
//  QuoteSaveViewController.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/8/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import UIKit
import CoreData

class QuoteSaveViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var quoteField: UITextView!

    let managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!

    var quote: Quote?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        let appDelegate = UIApplication.sharedApplication().delegate

        center.addObserverForName(TXTURL.Notification, object: appDelegate, queue: queue) { notification in
            if let url = notification?.userInfo?[TXTURL.Key] as? NSURL {
                var error: NSError? = NSError()
                if let fileStr = String(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: &error) {
                    var quoteArr = split(fileStr) { $0 == "|"}
                    if quoteArr.count >= 2 {
                        self.titleField.text = quoteArr[0]
                        self.quoteField.text = quoteArr[1]
                    }
                }
            }
        }
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let q = quote {
            titleField.text = q.title
            quoteField.text = q.text
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveQuote" {
            if quote == nil {
                quote = NSEntityDescription.insertNewObjectForEntityForName("Quote", inManagedObjectContext: managedObjectContext) as? Quote
            }
            quote!.text = quoteField.text
            quote!.title = titleField.text
        }
        var error: NSError? = NSError()
        if !managedObjectContext.save(&error) {
            NSLog("Unresolved error: \(error), \(error!.userInfo)")
            abort()
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var recent = userDefaults.valueForKey("recent") as [String]
        recent.insert(quote!.strID(), atIndex: 0)
        userDefaults.setValue(recent, forKey: "recent")
        userDefaults.synchronize()
    }


}
