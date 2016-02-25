//
//  EditProfileView.swift
//  HiLingual
//
//  Created by Noah Maxey on 2/25/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit

class EditProfileView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var pickerData = [String]()
    var pickerAge = [Int]()
    var genderBool = false
    var ageBool = false
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var bioText: UITextView!
    @IBOutlet weak var languagesLearning: UILabel!
    @IBOutlet weak var languagesSpeaks: UILabel!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    var user: HLUser! {
        didSet {
            refreshUI()
        }
    }
    func refreshUI() {
        profileImage.image = user.profilePicture
        nameText.text = user.displayName
        genderLabel.text = "Gender"
        ageLabel.text = "\(NSCalendar.currentCalendar().components(.Year, fromDate: user.birthdate).year)"
        languagesSpeaks.text = "Speaks: " + user.knownLanguages.toList()
        languagesLearning.text = "Learning: " + user.learningLanguages.toList()
        bioText.text = user.bio
    }
    convenience required init?(coder aDecoder: NSCoder) {
        self.init(decoder: aDecoder, frame: nil)
    }
    
    @IBAction func genderTap(sender: AnyObject) {
        //if gender is set can't change
        
        //Do animation still 💩
        genderBool = true
        toolBar.hidden = false
        pickerView.hidden = false
        pickerData = ["Male", "Female"]
        pickerView.reloadAllComponents()
        
    }
    
    @IBAction func ageTap(sender: AnyObject) {
        //if age is set can't change
        ageBool = true
        pickerView.hidden = false
        toolBar.hidden = false
        pickerAge += 13...100
        pickerView.reloadAllComponents()
    }
    
    @IBAction func speaksTap(sender: AnyObject) {
        
    }

    @IBAction func learningTap(sender: AnyObject) {
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (genderBool){
            return pickerData[row]
        } else if (ageBool){
            return "\(pickerAge[row])"
        } else{
            return pickerData[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (genderBool){
            genderLabel.text = pickerData[row]
        } else if (ageBool){
            ageLabel.text = "\(pickerAge[row])"
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (genderBool){
            return pickerData.count
        } else if (ageBool){
            return pickerAge.count
        } else{
            return pickerData.count
        }
    }
    
    @IBAction func donePicker(sender: AnyObject) {
        
        ageBool = false
        genderBool = false
        pickerView.hidden = true
        toolBar.hidden = true
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
        
    }



}
