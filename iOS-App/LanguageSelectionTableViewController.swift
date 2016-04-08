//
//  LanguageSelectionTableViewController.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/25/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

class LanguageSelectionTableViewController: UITableViewController {

    var delegate: LanguageSelectionDelegate?

    //Make sure you set this from wherever you are using this view!!!
    var selectedLanguages: [Languages]!

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("languageCell")!
        let currentLanguage = Languages.allValues[indexPath.row]
        cell.textLabel!.text = currentLanguage.rawValue

        if (selectedLanguages.contains(currentLanguage)) {
            cell.selected = true
            cell.accessoryType = .Checkmark
        }
        else {
            cell.selected = false
            cell.accessoryType = .None
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedLanguage = Languages.allValues[indexPath.row]
        if let languageIndex = selectedLanguages.indexOf(selectedLanguage) {
            selectedLanguages.removeAtIndex(languageIndex)
        }

        else {
            selectedLanguages.append(selectedLanguage)
        }

        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Languages.allValues.count
    }
    @IBAction func save(sender: AnyObject) {
        delegate?.setNewSelectedLanguages(selectedLanguages)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol LanguageSelectionDelegate {
    func performLanguageSelectionSegue(selectedLanguages: [Languages])
    func setNewSelectedLanguages(selectedLanguages: [Languages])
}