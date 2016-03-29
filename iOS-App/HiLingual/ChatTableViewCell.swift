//
//  ChatTableViewCell.swift
//  HiLingual
//
//  Created by Noah Maxey on 3/17/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var chatBubble: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
