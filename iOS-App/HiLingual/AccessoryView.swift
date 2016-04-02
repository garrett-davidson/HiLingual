//
//  AccessoryView.swift
//  HiLingual
//
//  Created by Noah Maxey on 3/30/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation


class AccessoryView: UIView, UITextViewDelegate {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var view: UIView!
    @IBOutlet var recordingTimer: UILabel!
    var origTime = 0.0
    var curTime = 0.0
    var isRecording = false;
    var recordTimer: NSTimer!
    
    @IBOutlet var previewRecording: UIButton!
    @IBOutlet var deleteRecording: UIButton!
    @IBOutlet var micButton: UIButton!
    
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    
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

        loadTexetView()
    }
    
    @IBAction func tapMicDown(sender: AnyObject) {
        
        print("down");
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    return;
                }
                
            }
            
            isRecording = true;
            recordingTimer.hidden = false
            previewRecording.hidden = true
            deleteRecording.hidden = true
            origTime =  CACurrentMediaTime();
            textView.hidden = true
            recordTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(AccessoryView.updateLabel), userInfo: nil, repeats: true)

        } catch {
            // failed to record!
        }
        
        
        
    }
    func updateLabel() {
        curTime = CACurrentMediaTime();
        recordingTimer.text = String(format:"%.1f", curTime-origTime)
    }
    
    
    @IBAction func tapMicUpOut(sender: AnyObject) {
        recordingTimer.hidden = false
        previewRecording.hidden = false
        deleteRecording.hidden = false
        recordTimer.invalidate()
        print("up");
    }
    @IBAction func tapMicUpIn(sender: AnyObject) {
        recordingTimer.hidden = false
        previewRecording.hidden = false
        deleteRecording.hidden = false
        recordTimer.invalidate()
        print("up");
    }
    
    @IBAction func tapPreview(sender: AnyObject) {
         print("preview");
        
    }
    @IBAction func tapDelete(sender: AnyObject) {
        textView.hidden = false;
        recordingTimer.hidden = true
        previewRecording.hidden = true
        deleteRecording.hidden = true
        isRecording = false;
        print("delete");
        
    }
    
    
    @IBAction func sendClicked(sender: AnyObject) {
        if(isRecording == true){
            //send recorded audio
            return
        }
        
        
    }
    func textViewDidBeginEditing(textView: UITextView) {
        textView.textColor = UIColor.blackColor()
        textView.text = ""
    }
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5)
            textView.text = "Message"
        }
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
    
    func loadTexetView() {
        view.backgroundColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.7)
        view.layer.borderWidth = 0.4
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5
        textView.textColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5)
        textView.text = "Message"
    }
    
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init(decoder: aDecoder, frame: nil)
    }
}
