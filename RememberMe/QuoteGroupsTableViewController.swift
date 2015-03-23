//
//  QuoteGroupsTableViewController.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/10/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import UIKit
import CoreData
class QuoteGroupsTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {


    @IBOutlet weak var searchBar: UISearchBar!
    let managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    let userDefaults = NSUserDefaults.standardUserDefaults()

    lazy var quoteGroups: [[QuoteGroup]] = {
        var groups = [[QuoteGroup]]()
        var allSection = [QuoteGroup]()
        var allGroup = self.getGroup("All Quotes")
        let quotesRequest = NSFetchRequest(entityName: "Quote")
        let quotes = self.managedObjectContext.executeFetchRequest(quotesRequest, error: nil) ?? [Quote]()
        allGroup.quotes = NSSet(array: quotes)
        allSection.insert(allGroup, atIndex: 0)
        groups.insert(allSection, atIndex: 0)
        return groups
        }()

    //MARK: - Search logic
    var filteredQuoteGroups = [QuoteGroup]()
    
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
        return true
    }

    func filterContentForSearchText(searchText: String) {
        filteredQuoteGroups.removeAll(keepCapacity: false)
        for quoteGroupArr in quoteGroups {
            filteredQuoteGroups += quoteGroupArr.filter {
                $0.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
            }
        }
    }
    
    
    //MARK: - Data Logic
    
    
    @IBAction func addGroup(sender: UIBarButtonItem) {
        var alert = UIAlertController(title: "New Group", message: "Create a new group", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Group Name"
        }
        let cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: .Default )
            { (action: UIAlertAction!) -> Void in
             return
            }
        let save: UIAlertAction = UIAlertAction(title: "Save", style: .Default)
            { (action: UIAlertAction!) -> Void in
                if let tf = alert.textFields?.first as? UITextField {
                    self.createGroup(tf.text)
                    self.refresh()
            }
        }
        alert.addAction(cancel)
        alert.addAction(save)
        presentViewController(alert, animated: true, completion: nil)

    }

    
    private func refresh() {
        var fetchReq = NSFetchRequest(entityName: "QuoteGroup")
        var error: NSError? = NSError()
        var quoteGroup: QuoteGroup?
        var fetchResults = managedObjectContext.executeFetchRequest(fetchReq, error: nil) as? [QuoteGroup]
        if fetchResults != nil {
            if fetchResults!.isEmpty {
                loadData()
                fetchResults = managedObjectContext.executeFetchRequest(fetchReq, error: nil) as [QuoteGroup]?
            }
            fetchResults!.filter { $0.name != "All Quotes" }
            fetchResults!.sort {
                $0.name < $1.name
            }
            quoteGroups.insert(fetchResults!, atIndex: 1)
        }
        tableView.reloadData()
    }
    private func createQuote(title: String, text: String) -> Quote {
        let quote = NSEntityDescription.insertNewObjectForEntityForName("Quote", inManagedObjectContext: managedObjectContext) as Quote
        quote.title = title
        quote.text = text
        quote.currentTime = NSDate(timeIntervalSinceReferenceDate: 0)
        return quote
    }
    
    func clearAllData() {
        let oldRequest = NSFetchRequest(entityName: "Quote")
        if let oldRequest = managedObjectContext.executeFetchRequest(oldRequest, error: nil) as? [Quote] {
            for quote in oldRequest {
                managedObjectContext.deleteObject(quote)
            }
        }
        let oldGroupRequest = NSFetchRequest(entityName: "QuoteGroup")
        if let oldGroupRequest = managedObjectContext.executeFetchRequest(oldGroupRequest, error: nil) as? [QuoteGroup] {
            for quote in oldGroupRequest {
                managedObjectContext.deleteObject(quote)
            }
        }
        
    }
    
    private func createGroup(name: String) -> QuoteGroup? {
        let quoteGroup = NSEntityDescription.insertNewObjectForEntityForName("QuoteGroup", inManagedObjectContext: managedObjectContext) as? QuoteGroup
        quoteGroup?.name = name
        return quoteGroup
    }
    private func getGroup(name: String) -> QuoteGroup {
        var fetchReq = NSFetchRequest(entityName: "QuoteGroup")
        var error: NSError? = NSError()
        fetchReq.predicate = NSPredicate(format: "name = %@", argumentArray: [name])
        var quoteGroup: QuoteGroup?
        if let fetchResults = managedObjectContext.executeFetchRequest(fetchReq, error: &error) {
            if fetchResults.isEmpty {
                quoteGroup = createGroup(name)
            } else {
                quoteGroup = fetchResults[0] as? QuoteGroup
            }
        }
        return quoteGroup!
    }

    private func loadData() {
        let path = NSBundle.mainBundle().pathForResource("top1000bible", ofType: "txt")
        var error: NSError? = NSError()
        if let fileStr = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: &error) {
            var quotesArray = split(fileStr) { $0 == "\n"}
            for line in quotesArray {
                if !line.isEmpty {
                    var bibleQuote = split(line) { $0 == "|" }
                    let verse = bibleQuote[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    let text = bibleQuote[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) + " \(verse)"
                    let quote: Quote = createQuote(verse, text: text)
                    let group = getGroup("Bible Verses")
                    quote.addGroup(group)
                }
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        let appDelegate = UIApplication.sharedApplication().delegate
        
        center.addObserverForName(TXTURL.Notification, object: appDelegate, queue: queue) { notification in
            if let url = notification?.userInfo?[TXTURL.Key] as? NSURL {
                var error: NSError? = NSError()
                if let fileStr = String(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: &error) {
                    var quoteArr = split(fileStr) { $0 == "|"}
                    if quoteArr.count >= 2 {
                        let title = quoteArr[0]
                        let text = quoteArr[1]
                        self.performSegueWithIdentifier("textFileSave", sender: self.createQuote(title, text: text))
                    }
                }
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }

    override func viewWillDisappear(animated: Bool) {
        var error: NSError? = NSError()
        if !managedObjectContext.save(&error) {
            NSLog("Unresolved error: \(error), \(error!.userInfo)")
            abort()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return tableView == self.searchDisplayController!.searchResultsTableView && filteredQuoteGroups.isEmpty ? 0 : quoteGroups.count
    }
    private struct Storyboard {
        static let CellReuseIdentifier = "quoteGroup"
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return filteredQuoteGroups.count
        } else {
            return quoteGroups[section].count
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: QuoteGroupTableViewCell?
        if tableView == self.searchDisplayController!.searchResultsTableView  {
            tableView.registerClass(QuoteGroupTableViewCell.classForCoder(), forCellReuseIdentifier: Storyboard.CellReuseIdentifier)
            cell = QuoteGroupTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: Storyboard.CellReuseIdentifier)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as? QuoteGroupTableViewCell
        }
        cell!.group = tableView == self.searchDisplayController!.searchResultsTableView ? filteredQuoteGroups[indexPath.row] : quoteGroups[indexPath.section][indexPath.row]
        return cell!
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
            // Delete the row from the data source
            managedObjectContext.deleteObject(quoteGroups[indexPath.section][indexPath.row])
            quoteGroups[indexPath.section].removeAtIndex(indexPath.row)
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
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            performSegueWithIdentifier("quoteGroup", sender: self.tableView(tableView, cellForRowAtIndexPath: indexPath))
        }
    }

    // MARK: - Navigation
    
    @IBAction func saveQuote(segue: UIStoryboardSegue) {
        var source = segue.sourceViewController as? UIViewController
        if let navCon = source as? UINavigationController {
            source = navCon.visibleViewController
        }
        if let saveView = source as? QuoteSaveViewController {
            if let q = saveView.quote {
                if q.quoteGroups.count == 0 {
                    var recent = userDefaults.valueForKey("recent") as [String]
                    recent.insert(q.strID(), atIndex: 0)
                    userDefaults.setValue(recent, forKey: "recent")
                    userDefaults.synchronize()
                }
            }
        }
        
    }
    
    @IBAction func cancelSave(segue: UIStoryboardSegue) {
        println("cancel")
    }

    
    func quoteIsBefore(q1: Quote, q2: Quote) -> Bool {
        return q1.title < q2.title
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let identifier = segue.identifier {
            if identifier == "quoteGroup" {
                if let quoteTableViewController = destination as? QuotesTableViewController {
                    if let quoteGroup = sender as? QuoteGroupTableViewCell {
                        if var quotes = quoteGroup.group?.quotes.allObjects as? [Quote] {
                            quotes.sort(quoteIsBefore)
                            quoteTableViewController.quotes = [[Quote]]()
                            quoteTableViewController.quotes.insert(quotes, atIndex: 0)
                            quoteTableViewController.group = quoteGroup.group
                        }
                    }
                }
            } else if identifier == "textFileSave" {
                if let quote = sender as? Quote {
                    if let quoteSaveController = destination as? QuoteSaveViewController {
                        quoteSaveController.quote = quote
                    }
                }
            }
        }
    }

}
