//
//  IOTableViewCell.swift
//  Qiaf
//
//  Created by Difeng Chen on 10/30/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit

class IOTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
