//
//  ChatEditedTableViewCell.swift
//  HiLingual
//
//  Created by Garrett Davidson on 4/3/16.
//  Copyright © 2016 Team3. All rights reserved.
//

class ChatEditedTableViewCell: UITableViewCell {
    @IBOutlet weak var chatBubbleLeft: UIView!
    @IBOutlet weak var chatBubbleRight: UIView!

    @IBOutlet weak var leftMessageLabel: UILabel!
    @IBOutlet weak var leftEditedMessageLabel: UILabel!
    @IBOutlet weak var rightMessageLabel: UILabel!
    @IBOutlet weak var rightEditedMessageLabel: UILabel!
    
    @IBOutlet weak var rightConstraintMessageEqualOrLess: NSLayoutConstraint!
    @IBOutlet weak var leftConstraintMessageequal: NSLayoutConstraint!
}
