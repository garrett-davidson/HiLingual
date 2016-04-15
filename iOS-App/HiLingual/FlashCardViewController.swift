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
    var flashcards = [String]()
    override func viewDidLoad() {
        loadTest();
    }
    @IBAction func AddFlashCard(sender: AnyObject) {
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flashcards.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = flashcards[indexPath.row]
        cell.detailTextLabel?.text = "0"
        return cell
    }
    func loadTest(){
        flashcards = ["Japanese", "Chinese", "Stupid"]
        
    }
    
}