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

class MatchingViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, iCarouselDelegate, iCarouselDataSource {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!

    @IBOutlet weak var carousel: iCarousel!

    var searchResults = [HLUser]()

    var matches = [HLUser]()
    var request = true

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
        return searchResults.count
    }
    
    @IBAction func sendRequest(sender: UIButton) {
        //let index = sender.tag
        print("sent")
        
        if (request){
            sender.setTitle("Cancel", forState: .Normal)
            request = false
            //send request to user
        }else{
            sender.setTitle("Send Request", forState: .Normal)
            request = true
            //send cancel
        }
        //sender.hidden = true
        //sender.userInteractionEnabled = false
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentity = "SearchTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! SearchTableViewCell
        let user = searchResults[indexPath.row]
        cell.name.text = user.name
        cell.profilePicture.layer.masksToBounds = false
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height/2
        cell.profilePicture.clipsToBounds = true
        cell.profilePicture.image = user.profilePicture
        cell.sendRequestButton.tag = indexPath.row
        //Mark: Fills the view
        cell.langaugesLearning.text! = "Learning: " + user.learningLanguages.toList()
        cell.languagesSpeaks.text! = "  Speaks: " + user.knownLanguages.toList()
        return cell
    }
    
    func loadSampleUser(){
        let photo = UIImage(named: "cantaloupe")
        let user = HLUser(UUID: "NOthing", name: "Bob John", displayName: "bob.john.24", knownLanguages: [Languages.English], learningLanguages: [Languages.Arabic], bio: "NOTHING", gender: Gender.Male, birthdate: NSDate(), profilePicture: photo!)
        let user1 = HLUser(UUID: "NOthing", name: "Noah is a BadAss", displayName: "bob.john.24", knownLanguages: [Languages.English], learningLanguages: [Languages.Arabic], bio: "NOTHING", gender: Gender.Male, birthdate: NSDate(), profilePicture: photo!)
        searchResults += [user,user1]
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadSampleUser()
        generateTestMatches(5)
        carousel.reloadData()
    }

    func generateTestMatches(count: Int) {
        for _ in 0..<count {
            matches.append(HLUser.generateTestUser())
        }
    }

    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return matches.count
    }

    func sendMessageButtonPressed(sender: AnyObject) {
        print("Send message button pressed")
    }

    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var profileViewCell: MatchProfileView

        if let cell = view as? MatchProfileView {
            profileViewCell = cell
        }

        else {
            profileViewCell = MatchProfileView()
            let sendMessageButton = UIButton(type: .System)

            sendMessageButton.setTitle("Send Message", forState: .Normal)
            sendMessageButton.addTarget(self, action: "sendMessageButtonPressed:", forControlEvents: .TouchUpInside)

            profileViewCell.profileView.addSubview(sendMessageButton)

            //Yay magic numbers! 💩
            //We'll change this when we convert this to a scroll view
            sendMessageButton.frame.size = CGSize(width: profileViewCell.profileView.frame.size.width, height: 12)
            sendMessageButton.center.x = profileViewCell.profileView.frame.size.width/2
            sendMessageButton.center.y = profileViewCell.profileView.frame.size.height - 20;
        }

        profileViewCell.profileView.user = matches[index]



        return profileViewCell
    }

    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault defaultValue: CGFloat) -> CGFloat {
        switch option {
        case .Spacing:
            return 1.05

        default:
            return defaultValue
        }
    }
}

class MatchProfileView: UIView {
    var profileView: ProfileView

    init() {
        let frame = CGRectMake(0, 0, 300, 500)
        self.profileView = ProfileView(decoder: nil, frame: frame)
        super.init(frame: frame)
        self.addSubview(profileView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //We're never using this method to so fuck it 😁
        fatalError("init(coder:) has not been implemented")
    }
}