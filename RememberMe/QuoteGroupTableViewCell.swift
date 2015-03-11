//
//  QuoteGroupTableViewCell.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/10/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import UIKit

class QuoteGroupTableViewCell: UITableViewCell {
    var group : QuoteGroup? {
        didSet {
            self.textLabel?.text = group?.name
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
