//
//  ProfileView.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/18/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

class ProfileView: UIView {
    var hiddenName = true
    @IBOutlet var view: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var displayNameLabel: UILabel!
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

    var editing = false {
        didSet {
            refreshUI()
        }
    }

    func refreshUI() {
        imageView.image = user.profilePicture
        if(hiddenName){
            nameLabel.hidden = true
        }
        else {
            nameLabel.text = user.name
        }
        nameLabel.text = user.name
        displayNameLabel.text = user.displayName
        if (user.age != nil) {
            ageLabel.text = "\(user.age!)"
        }
        else {
            ageLabel.text = "Not Specified".localized
        }
        
        if user.gender != nil {
            genderLabel.text = "\(user.gender!)"
        }
        else {
            genderLabel.text = "Not Specified".localized
        }

        let knownList = user.knownLanguages.toList()
        let learningList = user.learningLanguages.toList()

        speaksLabel.text = "Speaks: ".localized + (knownList == "" ? "None".localized : knownList)
        learningLabel.text = "Learning: ".localized + (learningList == "" ? "None".localized : learningList)
        bioTextView.text = user.bio

        if (!editing) {
            bioTextView.editable = false
        }
        else {
            bioTextView.editable = true
        }

    }

    convenience required init?(coder aDecoder: NSCoder) {
        self.init(decoder: aDecoder, frame: nil)
    }

    init(decoder: NSCoder?, frame: CGRect?) {
        if (decoder != nil) {
            super.init(coder: decoder!)!
        }
        else if (frame != nil) {
            super.init(frame: frame!)
        }
        else {
            super.init(frame: CGRectMake(0, 0, 200, 200))
        }
        NSBundle.mainBundle().loadNibNamed(NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!, owner: self, options: nil)
        self.addSubview(view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.AlignAllCenterY , metrics: nil, views: ["view": self.view]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.AlignAllCenterX , metrics: nil, views: ["view": self.view]))
    }
}