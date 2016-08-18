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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell")!
        let currentLanguage = Languages.allValues[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = String.localizedLanguageForLanguageName(languageName: currentLanguage.rawValue)

        if (selectedLanguages.contains(currentLanguage)) {
            cell.isSelected = true
            cell.accessoryType = .checkmark
        } else {
            cell.isSelected = false
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLanguage = Languages.allValues[(indexPath as NSIndexPath).row]
        if let languageIndex = selectedLanguages.index(of: selectedLanguage) {
            selectedLanguages.remove(at: languageIndex)
        } else {
            selectedLanguages.append(selectedLanguage)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Languages.allValues.count
    }
    @IBAction func save(_ sender: AnyObject) {
        delegate?.setNewSelectedLanguages(selectedLanguages)
        self.dismiss(animated: true, completion: nil)
    }
}

protocol LanguageSelectionDelegate {
    func performLanguageSelectionSegue(_ selectedLanguages: [Languages])
    func setNewSelectedLanguages(_ selectedLanguages: [Languages])
}
