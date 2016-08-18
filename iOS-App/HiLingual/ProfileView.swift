//
//  ProfileView.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/18/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

class ProfileView: UIView, ImageLoadingView {
    var hiddenName = true
    @IBOutlet var view: UIView!
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var displayNameLabel: UILabel!
    @IBOutlet fileprivate weak var genderLabel: UILabel!
    @IBOutlet fileprivate weak var ageLabel: UILabel!
    @IBOutlet fileprivate weak var speaksLabel: UILabel!
    @IBOutlet fileprivate weak var learningLabel: UILabel!
    @IBOutlet fileprivate weak var bioTextView: UITextView!

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

    var loadingImageView: UIImageView!
    var spinner: UIActivityIndicatorView?

    func refreshUI() {
        func redraw() {
            if user.profilePicture != nil {
                imageView.image = user.profilePicture
            } else {
                HLServer.loadImageWithURL(user.profilePictureURL!, forView: self, withCallback: { (image) in
                    self.user.profilePicture = image
                })
            }

            if(hiddenName) {
                nameLabel.isHidden = true
            } else {
                nameLabel.text = user.name
            }
            nameLabel.text = user.name
            displayNameLabel.text = user.displayName
            if (user.age != nil) {
                ageLabel.text = NSString.localizedStringWithFormat("%d", user.age!) as String
            } else {
                ageLabel.text = "Not Specified".localized
            }

            if user.gender != nil {
                genderLabel.text = "\(user.gender!)".localized
            } else {
                genderLabel.text = "Not Specified".localized
            }

            let knownList = user.knownLanguages.toList()
            let learningList = user.learningLanguages.toList()

            speaksLabel.text = "Speaks:".localized + " " + (knownList == "" ? "None".localized : knownList)
            learningLabel.text = "Learning:".localized + " " + (learningList == "" ? "None".localized : learningList)
            bioTextView.text = user.bio

            if (!editing) {
                bioTextView.isEditable = false
            } else {
                bioTextView.isEditable = true
            }
        }

        if Thread.isMainThread {
            redraw()
        } else {
            DispatchQueue.main.async(execute: {redraw()})
        }
    }

    convenience required init?(coder aDecoder: NSCoder) {
        self.init(decoder: aDecoder, frame: nil)
    }

    init(decoder: NSCoder?, frame: CGRect?) {
            if (decoder != nil) {
            super.init(coder: decoder!)!
        } else if (frame != nil) {
            super.init(frame: frame!)
        } else {
            super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        }
        Bundle.main.loadNibNamed(NSStringFromClass(type(of: self)).components(separatedBy: ".").last!, owner: self, options: nil)
        self.addSubview(view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: ["view": self.view]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["view": self.view]))
        loadingImageView = imageView

        imageView.layer.cornerRadius = imageView.frame.size.height / 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = UIColor.black.cgColor

    }
}
