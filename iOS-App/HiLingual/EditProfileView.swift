//
//  EditProfileView.swift
//  HiLingual
//
//  Created by Noah Maxey on 2/25/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit

class EditProfileView: UIView, UIPickerViewDataSource, UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    enum PickerField {
        case Gender, Age
    }

    var currentPickerField = PickerField.Age

    let minimunAge = 13

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
    
    var user: HLUser! {
        didSet {
            refreshUI()
        }
    }
    func refreshUI() {
        profileImage.image = user.profilePicture
        nameLabel.text = user.name
        nameText.text = user.displayName
        //can people have the same display name 💩
        //don't know how to send infoback to accountcreationview
        if user.gender != nil {
            genderLabel.text = "\(user.gender!)"
        }
        else {
            genderLabel.text = "Not Specified"
        }

        if (user.age != nil) {
            ageLabel.text = "\(user.age!)"
        }
        else {
            ageLabel.text = ""
        }
        languagesSpeaks.text = "Speaks: " + user.knownLanguages.toList()
        languagesLearning.text = "Learning: " + user.learningLanguages.toList()
        bioText.text = user.bio
    }
    convenience required init?(coder aDecoder: NSCoder) {
        self.init(decoder: aDecoder, frame: nil)
    }
    @IBAction func pictureTap(sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.delegate = self
        
        var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil){
            topVC = topVC!.presentedViewController
        }
        topVC?.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        
        var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil){
            topVC = topVC!.presentedViewController
        }
        topVC?.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        profileImage.image = selectedImage
        
        var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil){
            topVC = topVC!.presentedViewController
        }
        topVC?.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func genderTap(sender: AnyObject) {
        currentPickerField = .Gender
        pickerView.reloadAllComponents()
        animationUp()
    }
    @IBAction func ageTap(sender: AnyObject) {
        currentPickerField = .Age
        pickerView.reloadAllComponents()
        animationUp()
    }
    
    @IBAction func speaksTap(sender: AnyObject) {
        
    }

    @IBAction func learningTap(sender: AnyObject) {
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch currentPickerField {
        case .Age:
            return "\(minimunAge + row)"

        case .Gender:
            return "\(Gender.allValues[row])"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch currentPickerField {
        case .Age:
            ageLabel.text = "\(minimunAge + row)"
        case .Gender:
            genderLabel.text = "\(Gender.allValues[row])"
        }
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
        pickerView.backgroundColor = .whiteColor()
        toolBar.backgroundColor = .whiteColor()
        self.toolBar.center.y = self.frame.height + self.toolBar.frame.height/2
        self.pickerView.center.y = self.frame.height + self.pickerView.frame.height/2
        
        
    }
    
    func animationUp(){
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
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {self.toolBar.center.y = self.frame.height - self.toolBar.frame.height/2 - self.pickerView.frame.height }, completion: nil)
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {self.pickerView.center.y = self.frame.height - self.pickerView.frame.height/2}, completion: nil)
        
    }
    
    func animationDown(){
        
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {self.toolBar.center.y = self.frame.height + self.toolBar.frame.height/2}, completion:nil)
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {self.pickerView.center.y = self.frame.height + self.pickerView.frame.height/2}, completion: nil)
    }
}
