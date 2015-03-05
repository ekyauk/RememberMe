//
//  QuoteTableViewCell.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/3/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import UIKit

class QuoteTableViewCell: UITableViewCell {

    var quote : Quote? {
        didSet {
            self.textLabel?.text = quote?.title
            self.detailTextLabel?.text = quote?.text
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
