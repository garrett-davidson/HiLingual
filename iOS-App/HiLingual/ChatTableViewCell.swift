//
//  ChatTableViewCell.swift
//  HiLingual
//
//  Created by Noah Maxey on 3/17/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatBubbleLeft: UILabel!
    @IBOutlet weak var chatBubbleRight: UILabel!
    @IBOutlet weak var rightConstraintMessageEqualOrLess: NSLayoutConstraint!
    @IBOutlet weak var leftConstraintMessageequal: NSLayoutConstraint!
    @IBOutlet var button: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
