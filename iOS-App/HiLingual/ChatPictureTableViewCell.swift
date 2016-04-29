//
//  ChatPictureTableViewCell.swift
//  HiLingual
//
//  Created by Riley Shaw on 4/14/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

import UIKit

class ChatPictureTableViewCell: UITableViewCell, ImageLoadingView {
    
    @IBOutlet weak var leftPicture: UIImageView!
    @IBOutlet weak var rightPicture: UIImageView!

    var loadingImageView: UIImageView!
    var spinner: UIActivityIndicatorView?
}