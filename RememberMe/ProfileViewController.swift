//
//  ProfileTableViewController.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/13/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import UIKit
import CoreData

func fetchQuotesFromKey(key: String) -> [Quote] {
    let managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let hashArr = userDefaults.valueForKey(key) as [String]
    var fetchReq = NSFetchRequest(entityName: "Quote")
    var error: NSError? = NSError()
    let fetchResult = managedObjectContext.executeFetchRequest(fetchReq, error: &error) as [Quote]
    return fetchResult.filter { contains(hashArr, $0.strID()) }
}

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var wpmLabel: UILabel!
    @IBOutlet weak var tableControlChoice: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    var quotesCache = [String: [Quote]]()
    let keyArr = ["memorized", "inProgress", "recent"]

    private func setQuotes(key: String) {
        if let quoteArr = quotesCache[key] {
            quotes = quoteArr
        } else {
            let quoteArr = fetchQuotesFromKey(key)
            quotesCache[key] = quoteArr
            quotes = quoteArr
        }
    }

    @IBAction func tabChanged(sender: UISegmentedControl) {
        setQuotes(keyArr[sender.selectedSegmentIndex])
    }
    
    var quotes: [Quote] = [Quote]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabChanged(tableControlChoice)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let qos = Int(QOS_CLASS_USER_INITIATED.value)
        dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
            for key in self.keyArr {
                self.quotesCache[key] = fetchQuotesFromKey(key)
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return quotes.count
    }

    private struct Storyboard {
        static let CellReuseIdentifier = "profileCell"
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as QuoteTableViewCell
        cell.quote = quotes[indexPath.row]

        return cell
    }


 

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "profileToQuoteDetail" {
            var destination = segue.destinationViewController as? UIViewController
            if let navCon = destination as? UINavigationController {
                destination = navCon.visibleViewController
            }
            if let quoteDetail = destination as? QuoteDetailViewController {
                if let quoteCell = sender as? QuoteTableViewCell {
                    if let quote = quoteCell.quote {
                        quoteDetail.quote = quoteCell.quote!
                    }
                }
            }
        }
    }

}
