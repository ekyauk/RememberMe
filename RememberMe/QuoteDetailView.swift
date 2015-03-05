//
//  QuoteDetailView.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/4/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import UIKit

class QuoteDetailView: UIView {

    @IBOutlet weak var quoteText: UITextView!
    @IBOutlet weak var quoteTitle: UILabel!
    
    var quote: Quote? {
        didSet {
            quoteTitle.text = quote?.title
            quoteText.text = quote?.text
        }
    }
    
}
