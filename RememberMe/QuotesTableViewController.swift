//
//  QuotesTableViewController.swift
//  MemoRise
//
//  Created by Edric Kyauk on 3/3/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import UIKit
import CoreData
class QuotesTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {

    
    @IBOutlet weak var searchBar: UISearchBar!

    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!

    var quotes = [[Quote]]()
    var group: QuoteGroup?
    var filteredQuotes = [Quote]()
    
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
        return true
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredQuotes.removeAll(keepCapacity: false)
        for quoteArr in quotes {
            filteredQuotes += quoteArr.filter {
                $0.title.lowercaseString.rangeOfString(searchText.lowercaseString) != nil ||
                $0.text.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
            }
        }
    }
    
        
    override func viewWillDisappear(animated: Bool) {
        var error: NSError? = NSError()
        if !managedObjectContext.save(&error) {
            NSLog("Unresolved error: \(error), \(error!.userInfo)")
            abort()
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableView == self.searchDisplayController!.searchResultsTableView && filteredQuotes.isEmpty ? 0 : quotes.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == self.searchDisplayController!.searchResultsTableView ? filteredQuotes.count : quotes[section].count
    }

    private struct Storyboard {
        static let CellReuseIdentifier = "quote"
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: QuoteTableViewCell?
        if tableView == self.searchDisplayController!.searchResultsTableView  {
            tableView.registerClass(QuoteTableViewCell.classForCoder(), forCellReuseIdentifier: Storyboard.CellReuseIdentifier)
            cell = QuoteTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: Storyboard.CellReuseIdentifier)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as? QuoteTableViewCell
        }
        cell!.quote = tableView == self.searchDisplayController!.searchResultsTableView ? filteredQuotes[indexPath.row] : quotes[indexPath.section][indexPath.row]
        return cell!
    }

    // Allows selecting a cell on the search view to execute a segue
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            performSegueWithIdentifier("quoteDetail", sender: self.tableView(tableView, cellForRowAtIndexPath: indexPath))
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "quoteDetail" {
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
    
    @IBAction func saveQuote(segue: UIStoryboardSegue) {
        var source = segue.sourceViewController as? UIViewController
        if let navCon = source as? UINavigationController {
            source = navCon.visibleViewController
        }
        if let saveView = source as? QuoteSaveViewController {
            saveView.quote!.addGroup(group!)
            quotes[0].append(saveView.quote!)
            quotes[0].sort {
                $0.title < $1.title
            }
        }

    }
    
    @IBAction func cancelSave(segue: UIStoryboardSegue) {
        println("cancel")
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */


    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            managedObjectContext.deleteObject(quotes[indexPath.section][indexPath.row])
            quotes[indexPath.section].removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
