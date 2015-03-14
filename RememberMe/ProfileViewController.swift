//
//  ProfileTableViewController.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/13/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import UIKit
import CoreData
class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var wpmLabel: UILabel!
    @IBOutlet weak var tableControlChoice: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    let managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!

    var userDefaults = NSUserDefaults.standardUserDefaults()

    private func setQuotes(key: String) {
        let hashArr = userDefaults.valueForKey(key) as [String]
        var fetchReq = NSFetchRequest(entityName: "Quote")
        var error: NSError? = NSError()
        let quoteArr = managedObjectContext.executeFetchRequest(fetchReq, error: &error) as [Quote]
        quotes = quoteArr.filter { contains(hashArr, $0.strID()) }
    }

    @IBAction func tabChanged(sender: UISegmentedControl) {
        let keyArr = ["memorized", "inProgress", "recent"]
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


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */


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
