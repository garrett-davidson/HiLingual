//
//  AccessoryView.swift
//  HiLingual
//
//  Created by Noah Maxey on 3/30/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit
import QuartzCore

class AccessoryView: UIView, UITextViewDelegate {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var view: UIView!
    @IBOutlet var micButton: UIButton!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
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
        let color = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.7)
        view.backgroundColor = color
        view.layer.borderWidth = 0.4
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5
    }
    
   
    @IBAction func tapMicButton(sender: UIButton) {
        let controller = AudioRecorderViewController()
        //controller.audioRecorderDelegate = self
       // presentViewController(controller, animated: true, completion: nil)
        print("tapped")
    }
    
    func textViewDidChange(textView: UITextView) {
        
        //stop the view at top of screen somehow
        textView.reloadInputViews()
        if textView.text == "" {
            textView.scrollEnabled = false
            textView.sizeToFit()
            textView.layoutIfNeeded()
            sendButton.tintColor = UIColor.lightGrayColor()
            sendButton.userInteractionEnabled = false
        }else{
            sendButton.tintColor = UIColor.blueColor()
            sendButton.userInteractionEnabled = true
        }
        textView.reloadInputViews()
        let numLines = textView.contentSize.height / textView.font!.lineHeight;
        if numLines > 5 {
            textView.scrollEnabled = true
        }else{
            textView.scrollEnabled = false
        }
        textView.reloadInputViews()
        
        
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: view.frame.width, height: textView.font!.lineHeight)
        
    }
    
    
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init(decoder: aDecoder, frame: nil)
    }
}
