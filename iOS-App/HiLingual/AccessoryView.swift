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

class AccessoryView: UIView, UITextViewDelegate, AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var view: UIView!
    @IBOutlet var recordingTimer: UILabel!
    @IBOutlet weak var leftButton: UIButton!

    var textViewTested = false
    var origTime = 0.0
    var curTime = 0.0
    var isRecording = false
    var recordTimer: Timer!
    var curURL: URL!
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

        loadViews()
    }

    func didBegingEditing() {
        isEditing = true

        leftButton.setImage(UIImage(named: "shittyx"), for: UIControlState())
        sendButton.setTitle("Save".localized, for: UIControlState())

        textViewDidChange(textView)
    }

    func didEndEditing() {
        isEditing = false

        leftButton.setImage(nil, for: UIControlState())
        leftButton.setTitle("\u{f083}", for: UIControlState())

        textView.text = ""
        textView.isScrollEnabled = false
        textViewDidChange(textView)
        chatViewController?.editingCellIndex = nil
    }

    func startRecording() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsURL.appendingPathComponent(String(CACurrentMediaTime()))
        curURL = audioURL

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]

        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    func finishRecording(success: Bool) {
        audioRecorder.stop()

        if success {
            changeToSend()
            sendButton.tintColor = UIColor.blue
            sendButton.isUserInteractionEnabled = true
            print("recorded audio")
        } else {
            print("somethin fucked up rip")
        }
    }

    @IBAction func tapCameraDown(_ sender: AnyObject) {

        guard !isEditing else {
            //We don't want to do anything on touch down if we're editing
            didEndEditing()
            return
        }

        textView.resignFirstResponder()
        // NOW PICTURE BUTTON TAP
        let imagePickerController = UIImagePickerController()
        let alertController = UIAlertController(title: nil, message: "Choose Source".localized, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { (action) in
            return
        }
        alertController.addAction(cancelAction)

        let takePictureAction = UIAlertAction(title: "Take Picture".localized, style: .default) { (action) in
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self

            var topVC = UIApplication.shared.keyWindow?.rootViewController
            while((topVC!.presentedViewController) != nil) {
                topVC = topVC!.presentedViewController
            }
            topVC?.present(imagePickerController, animated: true, completion: nil)
        }
        alertController.addAction(takePictureAction)
        let usePhotoLibraryAction = UIAlertAction(title: "Photo Library".localized, style: .default) { (action) in
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self

            var topVC = UIApplication.shared.keyWindow?.rootViewController
            while((topVC!.presentedViewController) != nil) {
                topVC = topVC!.presentedViewController
            }
            topVC?.present(imagePickerController, animated: true, completion: nil)
        }
        alertController.addAction(usePhotoLibraryAction)
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil) {
            topVC = topVC!.presentedViewController
        }
        alertController.preferredContentSize = alertController.view.frame.size
        topVC?.present(alertController, animated: true, completion: nil)



    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.

        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil) {
            topVC = topVC!.presentedViewController
        }
        topVC?.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage = (info[UIImagePickerControllerOriginalImage] as! UIImage).rotateImageByOrientation()
        selectedImage = UIImage(cgImage: selectedImage.cgImage!, scale: 0.02, orientation: UIImageOrientation.up)

        chatViewController?.sendImage(selectedImage)

        //post to server
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil) {
            topVC = topVC!.presentedViewController
        }
        topVC?.dismiss(animated: true, completion: nil)
    }



    func updateLabel() {
        curTime = CACurrentMediaTime()
        recordingTimer.text = String(format:"%.1f", curTime-origTime)
    }


    @IBAction func tapMicUpOut(_ sender: AnyObject) {
        if isSend {
            return
        }
        if isRecording {
            finishRecording()
        }
    }
    @IBAction func tapMicCancel(_ sender: AnyObject) {
        if isSend {
            return
        }
        if isRecording {
            finishRecording()
        }
    }
    @IBAction func tapMicUpIn(_ sender: AnyObject) {
        if isSend {
            return
        }
        if isRecording {
            finishRecording()
        } else if isEditing {
            didEndEditing()
        }
    }

    func finishRecording() {
        recordingTimer.isHidden = false
        previewRecording.isHidden = false
        deleteRecording.isHidden = false
        recordTimer.invalidate()

        isSend = true
        changeToSend()

        finishRecording(success: true)
    }

    @IBAction func tapPreview(_ sender: AnyObject) {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            audioPlayer.volume = 1
            audioPlayer.play()
        } catch let error as NSError {
            print("Failed to preview recording: ", error)
        }
    }
    @IBAction func tapDelete(_ sender: AnyObject) {
        textView.isHidden = false
        textView.isEditable = true
        recordingTimer.isHidden = true
        previewRecording.isHidden = true
        deleteRecording.isHidden = true
        isRecording = false

        isSend = false
        changeToMicroPhone()



    }


    @IBAction func sendClicked(_ sender: AnyObject) {
        var data: Data? = nil
        print("isSend: ", isSend)
        if isSend {
            isSend = false
            changeToMicroPhone()
            if isRecording {
                print("sent voice")
                data = try? Data(contentsOf: curURL)
                chatViewController!.sendVoiceMessageWithData(data!)
                tapDelete(sender)

                return
            } else if isEditing {
                chatViewController!.saveMessageEdit(editedText: textView.text)
                didEndEditing()
            } else {
                textView.text = textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
                recordingSession.requestRecordPermission() { (allowed: Bool) -> Void in
                    DispatchQueue.main.async {
                        return
                    }

                }

                isRecording = true
                recordingTimer.isHidden = false
                previewRecording.isHidden = true
                deleteRecording.isHidden = true
                origTime =  CACurrentMediaTime()
                textView.isHidden = true
                //textView.editable = false;
                recordTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AccessoryView.updateLabel), userInfo: nil, repeats: true)

            } catch let error as NSError {
                // failed to record!

                //If something fails, it would be nice to know...
                print("Recording failed: ", error)
            }

            startRecording()

        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = UIColor.black
        if textView.text == "" || textView.text == "Message".localized {
            textView.text = ""

            //textView.scrollEnabled = false

        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5)
            textView.text = "Message".localized
            textView.isScrollEnabled = false

        }
    }
    func textViewDidChange(_ textView: UITextView) {

        if textView.text == "" {
            textView.isScrollEnabled = false
            textView.sizeToFit()
            textView.layoutIfNeeded()
            sendButton.tintColor = UIColor.blue
            isSend = false
            changeToMicroPhone()
        } else {
            isSend = true
            changeToSend()

        }
        if isRecording {
            finishRecording()
            textView.isHidden = false
            textView.isEditable = true
            recordingTimer.isHidden = true
            previewRecording.isHidden = true
            deleteRecording.isHidden = true
            isRecording = false
            isSend = false
            changeToSend()
        }

        var height = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
        if height < 34 {
            height = 34
            textView.isScrollEnabled = false
        } else if height > 110 {
            height = 110
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
        }

        textViewHeightConstraint.constant = height

        if textView.text == "" && textViewTested == false {
            textViewTested = true
            textViewDidChange(textView)
        }
        textViewTested = false
    }

    override var intrinsicContentSize: CGSize {
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
        leftButton.setTitle("\u{f083}", for: UIControlState())
        deleteRecording.setTitle("\u{f057}", for: UIControlState())
        previewRecording.setTitle("\u{f144}", for: UIControlState())

        //textView.font = UIFont(name: "FontAwesome", size: 12)
        //textView.text = "\u{f0f9}"
    }

    func changeToSend() {
        sendButton.titleLabel?.font = UIFont(name: "System", size: 15)
        sendButton.setTitle("Send", for: UIControlState())
    }

    func changeToMicroPhone() {
        sendButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 24)
        sendButton.setTitle("\u{f130}", for: UIControlState())

    }

    convenience required init?(coder aDecoder: NSCoder) {
        self.init(decoder: aDecoder, frame: nil)
    }
}

extension UIImage {
    func rotateImageByOrientation() -> UIImage {
        // No-op if the orientation is already correct
        guard self.imageOrientation != .up else {
            return self
        }

        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity

        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))

        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))

        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))

        default:
            break
        }

        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        default:
            break
        }

        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                                        bitsPerComponent: (self.cgImage?.bitsPerComponent)!, bytesPerRow: 0,
                                        space: (self.cgImage?.colorSpace!)!,
                                        bitmapInfo: (self.cgImage?.bitmapInfo.rawValue)!)
        ctx?.concatenate(transform)
        switch (self.imageOrientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))

        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }

        // And now we just create a new UIImage from the drawing context
        if let cgImage = ctx?.makeImage() {
            return UIImage(cgImage: cgImage)
        } else {
            return self
        }
    }
}
