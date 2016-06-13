//
//  TipsCell.swift
//  JMSampleFourSquare
//
//  Created by Jeremy Medford on 6/11/16.
//  Copyright © 2016 Vintage Robot. All rights reserved.
//

import UIKit

class TipsCell: UITableViewCell {

    @IBOutlet weak var tipTextLabel: UILabel?
    @IBOutlet weak var timeStampLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureForTip(tip:Tip) {
        tipTextLabel?.text = tip.text
        let createdDate = NSDate(timeIntervalSince1970: tip.createdAt)
        timeStampLabel?.text = createdDate.standardFormat()
    }

}
