//
//  ConversationTableViewCell.swift
//  HiLingual
//
//  Created by Noah Maxey on 2/18/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell, ImageLoadingView {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var haveMessageDot: UIImageView!
    var spinner: UIActivityIndicatorView?
}
