//
//  MatchingViewController.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/14/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
import UIKit

//Displays a list of the potential matches that the current user may want to talk to

class MatchingViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    var users = [HLUser]()
    
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool{
        searchTable.hidden = false
        return true
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchTable.hidden = true
        searchBar.resignFirstResponder()
        
    }
    
    func searchBar(searchBar: UISearchBar,
        textDidChange searchText: String){
            //Mark: Send to the server
            //whatever is recieved users
            
            
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    @IBAction func sendRequest(sender: AnyObject) {
        let index = sender.tag
        //Mark: send the uuid to server with users[index]
        print("sent")
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentity = "SearchTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! SearchTableViewCell
        let user = users[indexPath.row]
        cell.name.text = user.name
        cell.profilePicture.image = user.profilePicture
        cell.sendRequestButton.tag = indexPath.row
        //Mark: Fills the view
        //cell.langaugesLearning.text! += stringFromLanguages(user.learningLanguages)
        //cell.languagesSpeaks.text! += stringFromLanguages(user.KnownLanguages)
        return cell
    }
    
    func loadSampleUser(){
        let photo = UIImage(named: "cantaloupe")
        let user = HLUser(UUID: "NOthing", name: "Bob John", displayName: "bob.john.24", knownLanguages: [Languages.English], learningLanguages: [Languages.Arabic], bio: "NOTHING", gender: Gender.Male, birthdate: NSDate(), profilePicture: photo!)
        let user1 = HLUser(UUID: "NOthing", name: "Noah is a BadAss", displayName: "bob.john.24", knownLanguages: [Languages.English], learningLanguages: [Languages.Arabic], bio: "NOTHING", gender: Gender.Male, birthdate: NSDate(), profilePicture: photo!)
        users += [user,user1]
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSampleUser()
    }
}