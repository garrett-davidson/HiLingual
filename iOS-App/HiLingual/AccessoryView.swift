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

class AccessoryView: UIView, UITextViewDelegate ,AVAudioRecorderDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var view: UIView!
    @IBOutlet var recordingTimer: UILabel!
    @IBOutlet weak var leftButton: UIButton!

    var textViewTested = false
    var origTime = 0.0
    var curTime = 0.0
    var isRecording = false;
    var recordTimer: NSTimer!
    var curURL: NSURL!
    var lines: CGFloat = 0

    @IBOutlet var previewRecording: UIButton!
    @IBOutlet var deleteRecording: UIButton!


    var isSend = false
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    var isEditing = false
    var chatViewController: ChatViewController?

    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!

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

        loadViews()
    }

    func didBegingEditing() {
        isEditing = true

        leftButton.setImage(UIImage(named: "shittyx"), forState: .Normal)
        sendButton.setTitle("Save".localized, forState: .Normal)

        textViewDidChange(textView)
    }

    func didEndEditing() {
        isEditing = false

        leftButton.setImage(UIImage(named: "Microphone-128"), forState: .Normal)
        sendButton.setTitle("Send".localized, forState: .Normal)

        textView.text = ""
        textView.scrollEnabled = false
        textViewDidChange(textView)
        chatViewController?.editingCellIndex = nil
    }

    func startRecording() {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let audioURL = documentsURL.URLByAppendingPathComponent(String(CACurrentMediaTime()))
        curURL = audioURL

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
            changeToSend()
            sendButton.tintColor = UIColor.blueColor()
            sendButton.userInteractionEnabled = true
            print("recorded audio")
        }

        else {
            print("somethin fucked up rip")
        }
    }

    @IBAction func tapCameraDown(sender: AnyObject) {

        guard !isEditing else {
            //We don't want to do anything on touch down if we're editing
            return
        }

        textView.resignFirstResponder()
        // NOW PICTURE BUTTON TAP
        let imagePickerController = UIImagePickerController()
        let alertController = UIAlertController(title: nil, message: "Choose Source".localized, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Cancel) { (action) in
            return
        }
        alertController.addAction(cancelAction)

        let takePictureAction = UIAlertAction(title: "Take Picture".localized, style: .Default) { (action) in
            imagePickerController.sourceType = .Camera
            imagePickerController.delegate = self

            var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
            while((topVC!.presentedViewController) != nil) {
                topVC = topVC!.presentedViewController
            }
            topVC?.presentViewController(imagePickerController, animated: true, completion: nil)
        }
        alertController.addAction(takePictureAction)
        let usePhotoLibraryAction = UIAlertAction(title: "Photo Library".localized, style: .Default) { (action) in
            imagePickerController.sourceType = .PhotoLibrary
            imagePickerController.delegate = self

            var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
            while((topVC!.presentedViewController) != nil) {
                topVC = topVC!.presentedViewController
            }
            topVC?.presentViewController(imagePickerController, animated: true, completion: nil)
        }
        alertController.addAction(usePhotoLibraryAction)
        var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil) {
            topVC = topVC!.presentedViewController
        }
        topVC?.presentViewController(alertController, animated: true, completion: nil)



        //START MIC
        /*
         */


        //END MIC

    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.

        var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil) {
            topVC = topVC!.presentedViewController
        }
        topVC?.dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        selectedImage = UIImage(CGImage: selectedImage.CGImage!, scale: 0.02, orientation: UIImageOrientation.Up)

        chatViewController?.sendImage(selectedImage)

        //post to server
        var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil){
            topVC = topVC!.presentedViewController
        }
        topVC?.dismissViewControllerAnimated(true, completion: nil)
    }



    func updateLabel() {
        curTime = CACurrentMediaTime();
        recordingTimer.text = String(format:"%.1f", curTime-origTime)
    }


    @IBAction func tapMicUpOut(sender: AnyObject) {
        if isSend{
            return
        }
        if isRecording {
            finishRecording()
        }
    }
    @IBAction func tapMicCancel(sender: AnyObject) {
        if isSend{
            return
        }
        if isRecording {
            finishRecording()
        }
    }
    @IBAction func tapMicUpIn(sender: AnyObject) {
        if isSend{
            return
        }
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

        isSend = true
        changeToSend()

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
        textView.editable = true;
        recordingTimer.hidden = true
        previewRecording.hidden = true
        deleteRecording.hidden = true
        isRecording = false;

        isSend = false
        changeToMicroPhone()



    }


    @IBAction func sendClicked(sender: AnyObject) {
        var data: NSData? = nil
        print("isSend: ",isSend)
        if isSend {
            isSend = false
            changeToMicroPhone()
            if isRecording {
                print("sent voice")
                data = NSData(contentsOfURL: curURL)
                chatViewController!.sendVoiceMessageWithData(data!)
                tapDelete(sender)

                return
            } else if isEditing {
                chatViewController!.saveMessageEdit(editedText: textView.text)
                didEndEditing()
            } else {
                textView.text = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if (textView.text  ?? "").isEmpty {
                    print("String is nil or empty.")
                    textView.text = ""
                    textViewDidChange(textView)
                    return
                }
                if chatViewController!.sendMessageWithText(textView.text) {
                    textView.text = ""
                    textViewDidChange(textView)
                    chatViewController?.tableView.scrollToBottom()
                }
            }

        } else {
            //RECORDING GOES IN HERE RILEY
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
                //textView.editable = false;
                recordTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(AccessoryView.updateLabel), userInfo: nil, repeats: true)

            } catch let error as NSError {
                // failed to record!

                //If something fails, it would be nice to know...
                print("Recording failed: ", error)
            }

            startRecording()

        }
    }

    func textViewDidBeginEditing(textView: UITextView) {
        textView.textColor = UIColor.blackColor()
        if textView.text == "" || textView.text == "Message".localized {
            textView.text = ""

            //textView.scrollEnabled = false

        }
    }

    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5)
            textView.text = "Message".localized
            textView.scrollEnabled = false

        }
    }
    func textViewDidChange(textView: UITextView) {

        if textView.text == "" {
            textView.scrollEnabled = false
            textView.sizeToFit()
            textView.layoutIfNeeded()
            sendButton.tintColor = UIColor.blueColor()
            isSend = false
            changeToMicroPhone()
        }

        else {
            isSend = true
            changeToSend()

        }
        if isRecording {
            finishRecording()
            textView.hidden = false;
            textView.editable = true;
            recordingTimer.hidden = true
            previewRecording.hidden = true
            deleteRecording.hidden = true
            isRecording = false;
            isSend = false
            changeToSend()
        }

        var height = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.max)).height
        if height < 34 {
            height = 34
            textView.scrollEnabled = false
        } else if height > 110 {
            height = 110
            textView.scrollEnabled = true
        } else {
            textView.scrollEnabled = false
        }

        textViewHeightConstraint.constant = height

        if textView.text == "" && textViewTested == false {
            textViewTested = true
            textViewDidChange(textView)
        }
        textViewTested = false
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: view.frame.width, height: textView.font!.lineHeight)
    }

    func loadViews() {
        view.backgroundColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.7)
        view.layer.borderWidth = 0.4
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5
        textView.textColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5)
        textView.text = "Message".localized
        isSend = false
        changeToMicroPhone()
        leftButton.setTitle("\u{f083}", forState: UIControlState.Normal)
        deleteRecording.setTitle("\u{f057}", forState: UIControlState.Normal)
        previewRecording.setTitle("\u{f144}", forState: UIControlState.Normal)

        //textView.font = UIFont(name: "FontAwesome", size: 12)
        //textView.text = "\u{f0f9}"
    }
    
    func changeToSend(){
        sendButton.titleLabel?.font = UIFont(name: "System", size: 15)
        sendButton.setTitle("Send", forState: UIControlState.Normal)
    }

    func changeToMicroPhone() {
        sendButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 24)
        sendButton.setTitle("\u{f130}", forState: UIControlState.Normal)
        
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init(decoder: aDecoder, frame: nil)
    }
}

