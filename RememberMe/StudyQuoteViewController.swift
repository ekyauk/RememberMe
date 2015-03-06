//
//  StudyQuoteViewController.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/5/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import UIKit

class StudyQuoteViewController: UIViewController {

    @IBOutlet weak var quoteText: UITextView!

    private var guessedIndex = 0
    private struct QuoteWord {
        var text: String = ""
        var hidden: Bool = false
    }

    private var words = [QuoteWord]()

    var quote: Quote? {
        didSet {
            if let text = quote?.text {
                words = split(text) { $0 == " " }.map {
                    QuoteWord(text: $0, hidden: false)
                }
            }
        }
    }

    private func reloadQuote() {
        var blackText = ""
        var greyText = ""
        var fullText: NSString = ""
        for var i: Int = 0; i < guessedIndex; ++i {
            blackText += words[i].text + " " //guessed words should not be hidden
        }
        for var i: Int = guessedIndex; i < words.count; ++i {
            let word = words[i]
            if word.hidden {
                greyText += "_____"
            } else {
                greyText += word.text
            }
            if i < words.count - 1 {
                greyText += " "
            }
        }
        fullText = blackText + greyText
        var attrText = NSMutableAttributedString(string: fullText)
        let blackRange = fullText.rangeOfString(blackText)
        attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: blackRange)
        attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: NSMakeRange(blackRange.length, countElements(greyText)))
        quoteText.attributedText = attrText
    }
    
    @IBAction func valueChanged(sender: UITextField) {
        let letter = sender.text
        sender.text = ""
        if !letter.isEmpty && letter[0] == words[guessedIndex].text[0] {
            words[guessedIndex].hidden = false
            guessedIndex++
            reloadQuote()
        } else {
            println("boo try again")
        }
    }


    override func viewWillAppear(animated: Bool) {
        reloadQuote()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
/* Taken from http://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language */

extension String {
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
}
