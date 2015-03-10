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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    }


}
