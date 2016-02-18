//
//  ProfileView.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/18/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

class ProfileView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var genderLabel: UILabel!
    @IBOutlet private weak var ageLabel: UILabel!
    @IBOutlet private weak var speaksLabel: UILabel!
    @IBOutlet private weak var learningLabel: UILabel!
    @IBOutlet private weak var bioTextView: UITextView!

    var user: HLUser! {
        didSet {
            refreshUI()
        }
    }

    func refreshUI() {
        imageView.image = user.profilePicture
        nameLabel.text = user.displayName
        genderLabel.text = "TODO"
        ageLabel.text = "\(NSCalendar.currentCalendar().components(.Year, fromDate: user.birthdate).year)"
        speaksLabel.text = "Speaks: " + stringFromLanguages(user.knownLanguages)
        learningLabel.text = "Learning: " + stringFromLanguages(user.learningLanguages)
        bioTextView.text = user.bio
    }

    func stringFromLanguages(languages: [Languages]) -> String {
        var string = ""

        for lang in languages {
            string += lang.rawValue + ", "
        }

        //Remove the trailing ", "
        if (string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 2) {
            string = string.substringToIndex(string.endIndex.predecessor().predecessor())
        }

        return string
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSBundle.mainBundle().loadNibNamed(NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!, owner: self, options: nil)
        self.addSubview(view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.AlignAllCenterY , metrics: nil, views: ["view": self.view]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.AlignAllCenterX , metrics: nil, views: ["view": self.view]))
    }
}