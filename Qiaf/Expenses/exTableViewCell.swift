//
//  exTableViewCell.swift
//  Qiaf
//
//  Created by Difeng Chen on 11/28/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit

class exTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var Categries: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
