//
//  FlashCardView.swift
//  HiLingual
//
//  Created by Noah Maxey on 4/12/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
import UIKit

class FlashCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var flashcardTitle = [String]()
    var flashcards = [[HLFlashCard]]()

    @IBOutlet weak var flashcardTable: UITableView!
    var sent = 0

    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = editButtonItem
    }

    let flashcardDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/Flashcards/"

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        let fileManager = NSFileManager.defaultManager()
//        if let enumerator = fileManager.enumeratorAtPath(flashcardDirectory) {
            flashcardTitle.removeAll()
            flashcards.removeAll()
        if let rings = HLServer.retrieveFlashcards() {
            for (ringName, cards) in rings {
                flashcardTitle.append(ringName)
                flashcards.append(cards)
            }
            flashcardTable.reloadData()
        }
//            while let ringFile = enumerator.nextObject() as? String {
//                if ringFile.hasSuffix(".ring") {
//                    if let ringTitle = ringFile.componentsSeparatedByString(".").first {
//                        if let ring = NSKeyedUnarchiver.unarchiveObjectWithFile(flashcardDirectory + ringFile) as? [HLFlashCard] {
//                            flashcards.append(ring)
//                            flashcardTitle.append(ringTitle)
//                            flashcardTable.reloadData()
//                        }
//                    }
//                }
//            }
//        }
    }

    @IBAction func AddFlashCard(_ sender: AnyObject) {

        let alert = UIAlertController(title: "Flashcard Name:".localized, message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = ""
        })

        alert.addAction(UIAlertAction(title: "Done".localized, style: .default, handler: { (action) -> Void in

            let textField = alert.textFields![0] as UITextField
            self.flashcardTitle.insert(textField.text!, at: 0)
            self.flashcards.insert([], at: 0)
            self.flashcardTable.beginUpdates()
            self.flashcardTable.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.left)
            self.flashcardTable.endUpdates()


            self.view.endEditing(true)

        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { (action) -> Void in
            self.view.endEditing(true)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flashcardTitle.count
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.flashcardTable.setEditing(editing, animated: animated)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            flashcardTitle.remove(at: (indexPath as NSIndexPath).row)
            flashcards.remove(at: (indexPath as NSIndexPath).row)
            flashcardTable.beginUpdates()
            flashcardTable.deleteRows(at: [indexPath], with: .fade)
            flashcardTable.endUpdates()
            flashcardTable.reloadData()

        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFlashcardRing" {
            if let messageDetailViewController = segue.destination as? FlashcardTableViewController {
                print(sender)
                //get flashcards from server

                if let selectedMessageCell = sender as? UITableViewCell {
                    let indexPath = flashcardTable.indexPath(for: selectedMessageCell)!
                    flashcardTable.deselectRow(at: indexPath, animated: false)
                    messageDetailViewController.flashcards = flashcards[(indexPath as NSIndexPath).row]
                    sent = (indexPath as NSIndexPath).row
                    //messageDetailViewController.title = flashcardTitle[indexPath.row]
                    messageDetailViewController.ringTitle = flashcardTitle[(indexPath as NSIndexPath).row]
                }
            }
        }
    }
    @IBAction func unwindFlashCard(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? FlashcardTableViewController {
            flashcards[sent] = sourceViewController.flashcards
            flashcardTable.reloadData()
        }
        //send to server
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // remove the dragged row's model
        let val = self.flashcardTitle.remove(at: (sourceIndexPath as NSIndexPath).row)
        let val1 = self.flashcards.remove(at: (sourceIndexPath as NSIndexPath).row)

        // insert it into the new position
        self.flashcardTitle.insert(val, at: (destinationIndexPath as NSIndexPath).row)
        self.flashcards.insert(val1, at: (destinationIndexPath as NSIndexPath).row)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell

        cell.textLabel?.text = flashcardTitle[(indexPath as NSIndexPath).row]
        cell.detailTextLabel?.text = "\(flashcards[(indexPath as NSIndexPath).row].count)"
        return cell
    }
    /*
    func toJSON() -> NSData? {
        let userDict = [String : [String : String]]()
        for set:[HLFlashCard] in flashcards{
            for card:HLFlashCard in set{

            }
        }
        if frontText != nil {
            userDict.setObject(frontText!, forKey: "frontText")
        }
        if backText != nil {
            userDict.setObject(backText!, forKey: "backText")
        }
        return try? NSJSONSerialization.dataWithJSONObject(userDict, options: NSJSONWritingOptions(rawValue: 0))
    }*/

}
