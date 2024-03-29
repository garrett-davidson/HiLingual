//
//  SearchTableViewCell.swift
//  HiLingual
//
//  Created by Noah Maxey on 2/18/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell, ImageLoadingView {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var langaugesLearning: UILabel!
    @IBOutlet weak var languagesSpeaks: UILabel!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var sendRequestButton: UIButton!

    var spinner: UIActivityIndicatorView?

}
