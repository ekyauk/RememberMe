//
//  QuoteDetailViewController.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/3/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import UIKit

class QuoteDetailViewController: UIViewController {

    var quote: Quote?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    let userDefaults = NSUserDefaults.standardUserDefaults()
    @IBOutlet weak var quoteTitle: UILabel!
    @IBOutlet weak var quoteText: UITextView!
    @IBOutlet weak var bestTime: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!

    private func addToFavorites() {
        var favorites = userDefaults.valueForKey("favorites") as [String]
        favorites.insert(quote!.strID(), atIndex: 0)
        userDefaults.setValue(favorites, forKey: "favorites")
        userDefaults.synchronize()
    }
    private func removeFromFavorites(index: Int) {
        var favorites = userDefaults.valueForKey("favorites") as [String]
        favorites.removeAtIndex(index)
        userDefaults.setValue(favorites, forKey: "favorites")
        userDefaults.synchronize()
    }

    @IBAction func toggleFavorite(sender: UIButton) {
        if let label = sender.titleLabel {
            var favorites = userDefaults.valueForKey("favorites") as [String]
            if let index = find(favorites, quote!.strID()) {
                removeFromFavorites(index)
                favoriteButton.titleLabel?.alpha = 0.25
            } else {
                addToFavorites()
                favoriteButton.titleLabel?.alpha = 1
            }
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var favorites = userDefaults.valueForKey("favorites") as [String]
        if let index = find(favorites, quote!.strID()) {
            favoriteButton.titleLabel?.alpha = 1
        } else {
            favoriteButton.titleLabel?.alpha = 0.25
        }
        quoteTitle.text = quote?.title
        quoteText.text = quote?.text
        bestTime.text = quote!.bestTime.timeIntervalSinceReferenceDate.toString()
        currentTime.text = quote!.currentTime.timeIntervalSinceReferenceDate.toString()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "studyQuote" {
                var destination = segue.destinationViewController as? UIViewController
                if let navCon = destination as? UINavigationController {
                    destination = navCon.visibleViewController
                }
                if let studyQuote = destination as? StudyQuoteViewController {
                    studyQuote.quote = quote
                }
            
            } else if identifier == "editQuote" {
                var destination = segue.destinationViewController as? UIViewController
                if let navCon = destination as? UINavigationController {
                    destination = navCon.visibleViewController
                }
                if let saveQuote = destination as? QuoteSaveViewController {
                    saveQuote.quote = quote
                }

            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
