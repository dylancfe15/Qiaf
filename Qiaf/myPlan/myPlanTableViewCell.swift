//
//  myPlanTableViewCell.swift
//  Qiaf
//
//  Created by Difeng Chen on 11/2/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit

class myPlanTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var targetDate: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var completed: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var TitleIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
