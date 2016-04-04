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

public extension String {
    var NS: NSString { return (self as NSString) }
}
class AccessoryView: UIView, UITextViewDelegate ,AVAudioRecorderDelegate{

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var view: UIView!
    @IBOutlet var recordingTimer: UILabel!
    @IBOutlet weak var leftButton: UIButton!

    var origTime = 0.0
    var curTime = 0.0
    var isRecording = false;
    var recordTimer: NSTimer!
    
    @IBOutlet var previewRecording: UIButton!
    @IBOutlet var deleteRecording: UIButton!
    
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    var isEditing = false
    var chatViewController: ChatViewController?

    
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

        loadTextView()
    }

    func didBegingEditing() {
        isEditing = true

        leftButton.setImage(UIImage(named: "shittyx"), forState: .Normal)
        sendButton.setTitle("Save", forState: .Normal)

        textViewDidChange(textView)
    }

    func didEndEditing() {
        isEditing = false

        leftButton.setImage(UIImage(named: "Microphone-128"), forState: .Normal)
        sendButton.setTitle("Send", forState: .Normal)

        textView.text = ""
        textViewDidChange(textView)

        chatViewController?.editingCellIndex = nil
    }

    func startRecording() {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let audioURL = documentsURL.URLByAppendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        
        if success {
            print("recorded audio")
        }

        else {
            print("somethin fucked up rip")
        }
    }
    
    @IBAction func tapMicDown(sender: AnyObject) {
        guard !isEditing else {
            //We don't want to do anything on touch down if we're editing
            return
        }


        recordingTimer.text = "0.0"
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

        } catch let error as NSError {
            // failed to record!

            //If something fails, it would be nice to know...
            print("Recording failed: ", error)
        }

        startRecording()
    }
    func updateLabel() {
        curTime = CACurrentMediaTime();
        recordingTimer.text = String(format:"%.1f", curTime-origTime)
    }
    
    
    @IBAction func tapMicUpOut(sender: AnyObject) {
        if isRecording {
            finishRecording()
        }
    }
    @IBAction func tapMicUpIn(sender: AnyObject) {
        if isRecording {
            finishRecording()
        }
        else if isEditing {
            didEndEditing()
        }
    }

    func finishRecording() {
        recordingTimer.hidden = false
        previewRecording.hidden = false
        deleteRecording.hidden = false
        recordTimer.invalidate()
        finishRecording(success: true)
    }
    
    @IBAction func tapPreview(sender: AnyObject) {
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: audioRecorder.url)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
            audioPlayer.volume = 1;
            audioPlayer.play()
        } catch let error as NSError {
            print("Failed to preview recording: ", error)
        }
    }
    @IBAction func tapDelete(sender: AnyObject) {
        textView.hidden = false;
        recordingTimer.hidden = true
        previewRecording.hidden = true
        deleteRecording.hidden = true
        isRecording = false;
    }
    
    
    @IBAction func sendClicked(sender: AnyObject) {
        if isRecording {
            //TODO:
            //Send recorded audio
        }
        else if isEditing {
            //TODO:
            //Save edit
            chatViewController?.saveMessageEdit(editedText: textView.text)
            didEndEditing()
        }
        else {
            //TODO:
            //Send message
            chatViewController!.sendMessageWithText(textView.text)
        }
    }

    func textViewDidBeginEditing(textView: UITextView) {
        textView.textColor = UIColor.blackColor()
        if textView.text == "" || textView.text == "Message" {
            textView.text = ""
        }
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
        }

        else {
            sendButton.tintColor = UIColor.blueColor()
            sendButton.userInteractionEnabled = true
        }

        textView.reloadInputViews()
        let numLines = textView.contentSize.height / textView.font!.lineHeight;

        if numLines > 5 {
            textView.scrollEnabled = true
        }

        else {
            textView.scrollEnabled = false
        }

        textView.reloadInputViews()
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: view.frame.width, height: textView.font!.lineHeight)
    }
    
    func loadTextView() {
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

