//
//  FlashcardTableViewController.swift
//  HiLingual
//
//  Created by Noah Maxey on 4/17/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
import UIKit

class FlashcardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var flashcards = [HLFlashCard]()
    var ringTitle: String?

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        enableKeyboardHideOnTap()
        navigationItem.rightBarButtonItem = editButtonItem
        self.tableView.tableFooterView = UIView()
    }

    let flashcardDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/Flashcards/"

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !FileManager.default.fileExists(atPath: flashcardDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: flashcardDirectory, withIntermediateDirectories: false, attributes: nil)

            } catch let createDirectoryError as NSError {
                print("Error with creating directory at path: \(createDirectoryError.localizedDescription)")
            }
        }
        HLServer.saveFlaschcardRing(flashcards, withName: ringTitle!)
//        NSKeyedArchiver.archiveRootObject(flashcards, toFile: flashcardDirectory + ringTitle! + ".ring")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlashcardCell", for: indexPath) as! FlashcardCell
        cell.front.text = flashcards[(indexPath as NSIndexPath).row].frontText
        cell.back.text = flashcards[(indexPath as NSIndexPath).row].backText
        cell.front.tag = (indexPath as NSIndexPath).row
        cell.back.tag = (indexPath as NSIndexPath).row
        cell.front.addTarget(self, action: #selector(FlashcardTableViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        cell.back.addTarget(self, action: #selector(FlashcardTableViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flashcards.count
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }


    @IBAction func addFlashcard(_ sender: AnyObject) {
        flashcards.append(HLFlashCard(frontText: "", backText: ""))
        tableView.insertRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)], with: UITableViewRowAnimation.left)


    }
    func keyboardWillChangeFrame(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animate(withDuration: duration) { () -> Void in
            if let height = self.navigationController?.navigationBar.frame.height {

                let inset = UIEdgeInsetsMake(height + 20, 0, keyboardFrame.size.height, 0)
                self.tableView.contentInset = inset
                self.tableView.scrollIndicatorInsets = inset
            }
        }
    }
    fileprivate func enableKeyboardHideOnTap() {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            flashcards.remove(at: (indexPath as NSIndexPath).row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()

        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "beginViewing" {
            let messageDetailViewController = segue.destination as! FlashcardSetViewController
            print(flashcards.count)
            messageDetailViewController.flashcards = flashcards
            messageDetailViewController.title = title
        }

    }
    func textFieldDidChange(_ textField: UITextField) {
        let i = textField.tag
        let index = IndexPath(row: i, section: 0)
        tableView.scrollToRow(at: index, at: .bottom, animated: true)
        if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? FlashcardCell {
            if textField === cell.front {
                flashcards[i].frontText = textField.text
            } else {
                flashcards[i].backText = textField.text
            }
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let i = textField.tag

        if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? FlashcardCell {
            if textField === cell.front {
                flashcards[i].frontText = textField.text
            } else {
                flashcards[i].backText = textField.text
            }
        }
    }
    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                                      to destinationIndexPath: IndexPath) {
        // remove the dragged row's model
        let val1 = self.flashcards.remove(at: (sourceIndexPath as NSIndexPath).row)

        // insert it into the new position
        self.flashcards.insert(val1, at: (destinationIndexPath as NSIndexPath).row)
    }
}
