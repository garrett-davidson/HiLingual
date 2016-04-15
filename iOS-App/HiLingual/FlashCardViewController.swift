//
//  FlashCardView.swift
//  HiLingual
//
//  Created by Noah Maxey on 4/12/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
import UIKit

class FlashCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var flashcardTitle = [String]()
    var flashcards = [[HLFlashCard]]()
    
    @IBOutlet weak var flashcardTable: UITableView!
    
    
    override func viewDidLoad() {
        loadTest();
        navigationItem.leftBarButtonItem = editButtonItem()
    }
    @IBAction func AddFlashCard(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Flashcard Name:", message: "", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
        })
        alert.addAction(UIAlertAction(title: "Done", style: .Default, handler: { (action) -> Void in

            let textField = alert.textFields![0] as UITextField
            self.flashcardTitle.insert(textField.text!, atIndex: 0)
            self.flashcards.insert([], atIndex: 0)
            self.flashcardTable.beginUpdates()
            self.flashcardTable.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            self.flashcardTable.endUpdates()
            
            
            self.view.endEditing(true)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
            self.view.endEditing(true)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flashcardTitle.count
    }
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.flashcardTable.setEditing(editing, animated: animated)
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            flashcardTitle.removeAtIndex(indexPath.row)
            flashcards.removeAtIndex(indexPath.row)
            flashcardTable.beginUpdates()
            flashcardTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            flashcardTable.endUpdates()
            flashcardTable.reloadData()

        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toFlashcardRing" {
            let messageDetailViewController = segue.destinationViewController as! FlashcardSetViewController
            print(sender)
            if let selectedMessageCell = sender as? UITableViewCell {
                let indexPath = flashcardTable.indexPathForCell(selectedMessageCell)!
                flashcardTable.deselectRowAtIndexPath(indexPath, animated: false)
                messageDetailViewController.flashcards = flashcards[indexPath.row]
                messageDetailViewController.title = flashcardTitle[indexPath.row]
                
            }
            
            
        }
        
        
    }
    func tableView(tableView: UITableView,
                            moveRowAtIndexPath sourceIndexPath: NSIndexPath,
                                               toIndexPath destinationIndexPath: NSIndexPath) {
        // remove the dragged row's model
        let val = self.flashcardTitle.removeAtIndex(sourceIndexPath.row)
        let val1 = self.flashcards.removeAtIndex(sourceIndexPath.row)
        
        // insert it into the new position
        self.flashcardTitle.insert(val, atIndex: destinationIndexPath.row)
        self.flashcards.insert(val1, atIndex: destinationIndexPath.row)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = flashcardTitle[indexPath.row]
        cell.detailTextLabel?.text = "\(flashcards[indexPath.row].count)"
        return cell
    }
    func loadTest(){
        flashcardTitle = ["Japanese", "Chinese", "Stupid"]
        let flash = HLFlashCard(frontText: "nothing", backText: "Nothing")

        flashcards.insert([flash,flash,flash], atIndex: 0)
        flashcards.insert([flash], atIndex: 1)
        flashcards.insert([flash,flash,flash,flash], atIndex: 2)
        
    }
    
}