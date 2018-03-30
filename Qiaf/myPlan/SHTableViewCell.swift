//
//  SHTableViewCell.swift
//  Qiaf
//
//  Created by Difeng Chen on 11/11/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit

class SHTableViewCell: UITableViewCell {

    //@IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var notes: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var money: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
