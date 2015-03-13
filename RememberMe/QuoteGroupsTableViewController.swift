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

    let bibleTitles = [
        "Gen":"Genesis",
        "Exo":"Exodus",
        "Lev":"Leviticus",
        "Num":"Numbers",
        "Deu":"Deuteronomy",
        "Jos":"Joshua",
        "Jdg":"Judges",
        "Rut":"Ruth",
        "Sa1":"1 Samuel",
        "Sa2":"2 Samuel",
        "Kg1":"1 Kings",
        "Kg2":"2 Kings",
        "Ch1":"1 Chronicles",
        "Ch2":"2 Chronicles",
        "Ezr":"Ezra",
        "Neh":"Nehemiah",
        "Est":"Esther",
        "Job":"Job",
        "Psa":"Psalms",
        "Pro":"Proverbs",
        "Ecc":"Ecclesiastes",
        "Sol":"Song of Solomon",
        "Isa":"Isaiah",
        "Jer":"Jeremiah",
        "Lam":"Lamentations",
        "Eze":"Ezekiel",
        "Dan":"Daniel",
        "Hos":"Hosea",
        "Joe":"Joel",
        "Amo":"Amos",
        "Oba":"Obadiah",
        "Jon":"Jonah",
        "Mic":"Micah",
        "Nah":"Nahum",
        "Hab":"Habakkuk",
        "Zep":"Zephaniah",
        "Hag":"Haggai",
        "Zac":"Zechariah",
        "Mal":"Malachi",
        "Es1":"1 Esdras",
        "Es2":"2 Esdras",
        "Tob":"Tobias",
        "Jdt":"Judith",
        "Aes":"Additions to Esther",
        "Wis":"Wisdom",
        "Bar":"Baruch",
        "Epj":"Epistle of Jeremiah",
        "Sus":"Susanna",
        "Bel":"Bel and the Dragon",
        "Man":"Prayer of Manasseh",
        "Ma1":"1 Macabees",
        "Ma2":"2 Macabees",
        "Ma3":"3 Macabees",
        "Ma4":"4 Macabees",
        "Sir":"Sirach",
        "Aza":"Prayer of Azariah",
        "Lao":"Laodiceans",
        "Jsb":"Joshua B",
        "Jsa":"Joshua A",
        "Jdb":"Judges B",
        "Jda":"Judges A",
        "Toa":"Tobit BA",
        "Tos":"Tobit S",
        "Pss":"Psalms of Solomon",
        "Bet":"Bel and the Dragon Th",
        "Dat":"Daniel Th",
        "Sut":"Susanna Th",
        "Ode":"Odes",
        "Mat":"Matthew",
        "Mar":"Mark",
        "Luk":"Luke",
        "Joh":"John",
        "Act":"Acts",
        "Rom":"Romans",
        "Co1":"1 Corinthians",
        "Co2":"2 Corinthians",
        "Gal":"Galatians",
        "Eph":"Ephesians",
        "Phi":"Philippians",
        "Col":"Colossians",
        "Th1":"1 Thessalonians",
        "Th2":"2 Thessalonians",
        "Ti1":"1 Timothy",
        "Ti2":"2 Timothy",
        "Tit":"Titus",
        "Plm":"Philemon",
        "Heb":"Hebrews",
        "Jam":"James",
        "Pe1":"1 Peter",
        "Pe2":"2 Peter",
        "Jo1":"1 John",
        "Jo2":"2 John",
        "Jo3":"3 John",
        "Jde":"Jude",
        "Rev":"Revelation",
    ];

    @IBOutlet weak var searchBar: UISearchBar!
    let managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!

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
        let path = NSBundle.mainBundle().pathForResource("kjvdat", ofType: "txt")
        var error: NSError? = NSError()
        if let fileStr = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: &error) {
            var quotesArray = split(fileStr) { $0 == "\r\n"}
            for line in quotesArray {
                var bibleQuote = split(line) { $0 == "|" }
                let fileName = bibleQuote[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                let book = bibleTitles[fileName] ?? fileName
                let chapterNum = countElements(bibleQuote[1]) > 1 ? bibleQuote[1] : "0\(bibleQuote[1])"
                let verseNum = countElements(bibleQuote[2]) > 1 ? bibleQuote[2] : "0\(bibleQuote[2])"
                let text = bibleQuote[3].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                let quote: Quote = createQuote("\(book) [\(chapterNum):\(verseNum)]", text: text)
                let group = getGroup(book)
                let newQuotesSet = group.quotes.setByAddingObject(quote)
                let newGroupsSet = quote.quoteGroups.setByAddingObject(group)
                group.quotes = newQuotesSet
                quote.quoteGroups = newGroupsSet
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
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
        if let quoteTableViewController = destination as? QuotesTableViewController {
            if let quoteGroup = sender as? QuoteGroupTableViewCell {
                if let identifier = segue.identifier {
                    if var quotes = quoteGroup.group?.quotes.allObjects as? [Quote] {
                        quotes.sort(quoteIsBefore)
                        if identifier == "quoteGroup" {
                            quoteTableViewController.quotes = [[Quote]]()
                            quoteTableViewController.quotes.insert(quotes, atIndex: 0)
                            quoteTableViewController.group = quoteGroup.group
                        }
                    }
                }
            }
        }
    }

}
