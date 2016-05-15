//
//  EditProfileView.swift
//  HiLingual
//
//  Created by Noah Maxey on 2/25/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit

class EditProfileView: UIView, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, ImageLoadingView {

    enum PickerField {
        case Gender, Age
    }

    enum LanguageFields {
        case Knows, Learning
    }

    var currentPickerField = PickerField.Age
    let minimunAge = 13

    var isPickerViewDown = true

    var languageSelectionDelegate: LanguageSelectionDelegate?
    var currentLanguageField = LanguageFields.Knows

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var bioText: UITextView!
    @IBOutlet weak var languagesLearning: UILabel!
    @IBOutlet weak var languagesSpeaks: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!

    var loadingImageView: UIImageView!
    var spinner: UIActivityIndicatorView?

    var user: HLUser! {
        didSet {
            ageLabel.userInteractionEnabled = false
            refreshUI()
        }
    }

    func refreshUI() {
        func redraw() {
            if let image = user.profilePicture {
                profileImage.image = image
            } else {
                HLServer.loadImageWithURL(user.profilePictureURL!, forView: self, withCallback: { (image) in
                    self.user.profilePicture = image
                })
            }

            nameLabel.text = user.name
            nameText.text = user.displayName

            if user.gender != nil {
                genderLabel.text = "\(user.gender!)".localized
            } else {
                genderLabel.text = "Not Specified".localized
            }

            if (user.age != nil) {
                ageLabel.text = NSString.localizedStringWithFormat("%d", user.age!) as String
            } else {
                ageLabel.text = "Not Specified".localized
            }

            let knownList = user.knownLanguages.toList()
            let learningList = user.learningLanguages.toList()

            languagesSpeaks.text = "Speaks:".localized + " " + (knownList == "" ? "None".localized : knownList)
            languagesLearning.text = "Learning:".localized + " " + (learningList == "" ? "None".localized : learningList)
            bioText.text = user.bio
        }

        if NSThread.isMainThread() {
            redraw()
        } else {
            dispatch_async(dispatch_get_main_queue(), {redraw()})
        }
    }

    enum UserValidationError: ErrorType {
        case userId, name, displayName, knownLanguages, learningLanguages, bio, gender, age, profilePicture
    }

    func isValidUser() -> Bool {
        var errorMessage: String = ""

        do {

            func validateUser() throws {
                //userId
                if user.userId < 1 {
                    throw UserValidationError.userId
                }
                //name
                if nameLabel.text == nil || nameLabel.text == "" {
                    throw UserValidationError.name
                }
                //display name
                //TODO: Check unique
                if nameText.text == nil || nameText.text == "" || nameText.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 32
                    || nameText.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 2 {
                    throw UserValidationError.displayName
                }
                //bio
                if bioText.text == nil || bioText.text == "" || bioText.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 500 {
                    throw UserValidationError.bio
                }
                //speaking
                if languagesSpeaks.text == "Speaks: None".localized || languagesLearning.text == "Speaks: None".localized {
                    throw UserValidationError.knownLanguages
                }
                var index = 0
                for _ in 1...user.knownLanguages.count {
                    if user.learningLanguages.contains(user.knownLanguages[index]) {
                         throw UserValidationError.learningLanguages
                    }
                    index += 1
                }
                let nameExists = HLServer.getUniqueDisplayName(nameText.text!)
                if nameExists == "true" {
                    throw UserValidationError.displayName
                }
            }

            try validateUser()

        } catch UserValidationError.userId {
            errorMessage = "Invalid user id"
        } catch UserValidationError.name {
            errorMessage = "Invalid Name"
        } catch UserValidationError.displayName {
            errorMessage = "Invalid Display Name"
        } catch UserValidationError.bio {
            errorMessage = "Invalid Bio"
        } catch UserValidationError.age {
            errorMessage = "Invalid Age"
        } catch UserValidationError.knownLanguages {
            errorMessage = "Select A Language"
        } catch UserValidationError.learningLanguages {
            errorMessage = "You Cannot Learn And Speak The Same Language"
        } catch {
        }
        if(errorMessage != "") {
            let alertController = UIAlertController(title: nil, message: errorMessage.localized, preferredStyle: .ActionSheet)
            let okayAction = UIAlertAction(title: "Okay".localized, style: .Cancel) { (action) in
                return
            }
            alertController.addAction(okayAction)
            var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
            while((topVC!.presentedViewController) != nil) {
                topVC = topVC!.presentedViewController
            }
            topVC?.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        return true
    }


    convenience required init?(coder aDecoder: NSCoder) {
        self.init(decoder: aDecoder, frame: nil)
    }

    @IBAction func pictureTap(sender: UITapGestureRecognizer) {
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
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.

        var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil) {
            topVC = topVC!.presentedViewController
        }
        topVC?.dismissViewControllerAnimated(true, completion: nil)
    }
    static func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage!)

        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size

        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat

        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }

        let rect: CGRect = CGRectMake(posX, posY, width, height)

        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)

        return image
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        profileImage.image = EditProfileView.cropToSquare(image: selectedImage)
        user.profilePicture = EditProfileView.cropToSquare(image: selectedImage).rotateImageByOrientation()

        var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil) {
            topVC = topVC!.presentedViewController
        }

        if let picurl = HLServer.sendImageToProfile(user.profilePicture!, onUser: UInt64(HLUser.getCurrentUser().userId)) {
            user.profilePictureURL = picurl
        }

        topVC?.dismissViewControllerAnimated(true, completion: nil)
    }

    func updateSelectedLanguages(selectedLangauges: [Languages]) {
        switch currentLanguageField {
        case .Knows:
            user.knownLanguages = selectedLangauges
        case .Learning:
            user.learningLanguages = selectedLangauges
        }

        self.refreshUI()
    }

    @IBAction func genderTap(sender: AnyObject) {
        dismissKeyboard(self)
        currentPickerField = .Gender
        pickerView.reloadAllComponents()
        animationUp()
    }

    @IBAction func ageTap(sender: AnyObject) {
        dismissKeyboard(self)
        currentPickerField = .Age
        pickerView.reloadAllComponents()
        animationUp()
    }

    @IBAction func speaksTap(sender: AnyObject) {
        currentLanguageField = .Knows
        languageSelectionDelegate?.performLanguageSelectionSegue(user.knownLanguages)
    }

    @IBAction func learningTap(sender: AnyObject) {
        currentLanguageField = .Learning
        languageSelectionDelegate?.performLanguageSelectionSegue(user.learningLanguages)
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch currentPickerField {
        case .Age:
            return NSString.localizedStringWithFormat("%d", minimunAge + row) as String

        case .Gender:
            return "\(Gender.allValues[row])".localized
        }
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch currentPickerField {
        case .Age:
            ageLabel.text = "\(minimunAge + row)"
            user.birthdate = NSCalendar.currentCalendar().dateByAddingUnit(.Year, value: -(minimunAge + row), toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))
        case .Gender:
            genderLabel.text = "\(Gender.allValues[row])".localized
            user.gender = Gender(rawValue: row)
        }
    }

    @IBAction func dismissPickerView(sender: AnyObject) {
        animationDown()
    }


    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch (currentPickerField) {
        case .Age:
            //Max age = 100
            return 100 - minimunAge + 1

        case .Gender:
            return Gender.allValues.count
        }
    }

    @IBAction func donePicker(sender: AnyObject) {
        animationDown()
    }

    @IBAction func dismissKeyboard(sender: AnyObject) {
        self.endEditing(false)
    }

    func textViewDidBeginEditing(textView: UITextView) {
        self.dismissPickerView(self)
    }

    func textViewDidEndEditing(textView: UITextView) {
        self.dismissKeyboard(self)
        user.bio = bioText.text
    }

    init(decoder: NSCoder?, frame: CGRect?) {
        if (decoder != nil) {
            super.init(coder: decoder!)!
        } else if (frame != nil) {
            super.init(frame: frame!)
        } else {
            super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        }
        NSBundle.mainBundle().loadNibNamed(NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!, owner: self, options: nil)
        self.addSubview(view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: ["view": self.view]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["view": self.view]))
        pickerView.backgroundColor = .whiteColor()
        toolBar.backgroundColor = .whiteColor()
        self.toolBar.center.y = self.frame.height + self.toolBar.frame.height/2
        self.pickerView.center.y = self.frame.height + self.pickerView.frame.height/2
        /*
        ToDo:
        genderLabel.layer.borderWidth = 0.5
        genderLabel.layer.borderColor = UIColor.grayColor().CGColor
        genderLabel.layer.cornerRadius = 5

        ageLabel.layer.borderWidth = 0.5
        ageLabel.layer.borderColor = UIColor.grayColor().CGColor
        ageLabel.layer.cornerRadius = 5
        languagesLearning.layer.borderWidth = 0.5
        languagesLearning.layer.borderColor = UIColor.grayColor().CGColor
        languagesLearning.layer.cornerRadius = 5
        languagesSpeaks.layer.borderWidth = 0.5
        languagesSpeaks.layer.borderColor = UIColor.grayColor().CGColor
        languagesSpeaks.layer.cornerRadius = 5
         */

        loadingImageView = profileImage
    }


    func animationUp() {

        switch currentPickerField {
        case .Age:
            if (user.age != nil) {
                pickerView.selectRow(user.age! - minimunAge, inComponent: 0, animated: false)
            }
        case .Gender:
            if (user.gender != nil) {
                pickerView.selectRow(user.gender!.rawValue, inComponent: 0, animated: false)
            }
        }

        if (isPickerViewDown) {
            let animationDuration = 0.2
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseOut, animations: {self.toolBar.center.y = self.frame.height - self.toolBar.frame.height/2 - self.pickerView.frame.height }, completion: nil)
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseOut, animations: {self.pickerView.center.y = self.frame.height - self.pickerView.frame.height/2}, completion: nil)

            isPickerViewDown = false
        }
    }

    func animationDown() {

        if (!isPickerViewDown) {
            let animationDuration = 0.2
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseOut, animations: {self.toolBar.center.y = self.frame.height + self.toolBar.frame.height/2}, completion:nil)
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseOut, animations: {self.pickerView.center.y = self.frame.height + self.pickerView.frame.height/2}, completion: nil)

            isPickerViewDown = true
        }
    }
    @IBAction func displayNameDidEndEditing(sender: AnyObject) {
        user.displayName = nameText.text
    }
}
