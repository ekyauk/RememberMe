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
        self.navigationItem.rightBarButtonItem = self.editButtonItem()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var quoteTitle: UILabel!
    @IBOutlet weak var quoteText: UITextView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        quoteTitle.text = quote?.title
        quoteText.text = quote?.text

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
