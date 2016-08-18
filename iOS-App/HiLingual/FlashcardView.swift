//
//  FlashcardView.swift
//  HiLingual
//
//  Created by Noah Maxey on 4/17/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit

class FlashcardView: UIView {

    @IBOutlet var view: UIView!

    @IBOutlet weak var label: UILabel!

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
    }
}
