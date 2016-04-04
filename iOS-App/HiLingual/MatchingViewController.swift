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

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool{
        searchTable.hidden = false
        searchBar.showsCancelButton = true
        searchBar.showsSearchResultsButton = true
        return true
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchTable.hidden = true
        searchBar.showsCancelButton = false
        searchBar.showsSearchResultsButton = false
        searchBar.resignFirstResponder()
        
    }
    /*
    func searchBar(searchBar: UISearchBar,
        textDidChange searchText: String){
            //Mark: Send to the server
            //whatever is recieved users
            //fill requests with true for each user
            searchTable.reloadData()
    }
    */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //Mark: Send to the server
        //whatever users that are received go into users
        //fill requests with true for each user
        print("sent search")
        if let text = searchBar.text {
            let urlString = "https://gethilingual.com/api/user/search?query=" + text
            let request = NSMutableURLRequest(URL: NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!)
            request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "HLAT " + HLUser.getCurrentUser().getSession()!.sessionId]
            //TODO: Use non-deprecated API
            if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil) {
                print(returnedData)
                if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                    print(returnString)
                }
                searchResults = HLUser.fromJSONArray(returnedData)
            }
            searchTable.reloadData()
        }
    }

    func sendRequestToUser(userId: Int64) {
        var resp: NSURLResponse?

        let request = NSMutableURLRequest(URL: NSURL(string: "https://gethilingual.com/api/chat/\(userId)/")!)
        if let session = HLUser.getCurrentUser().getSession() {
            request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "HLAT " + session.sessionId]
            request.HTTPMethod = "POST"

            if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &resp) {
                if let response = resp as? NSHTTPURLResponse {
                    if response.statusCode == 204 {
                        print("Sent request")
                        return
                    }
                }

                print(returnedData)
                if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                    print(returnString)
                }

            }
        }
        
        print("Failed to send request")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    @IBAction func sendRequest(sender: UIButton) {
        //From search bar


        let index = sender.tag

//        sender.setTitle("Send Request", forState: .Normal)
        sendRequestToUser(searchResults[index].userId)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentity = "SearchTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! SearchTableViewCell
        let user = searchResults[indexPath.row]
        cell.name.text = user.displayName
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

    override func viewDidLoad() {
        super.viewDidLoad()

        carousel.bounceDistance = 0.1;
        carousel.decelerationRate = 0.2;
        carousel.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        loadMatches()
    }

    func loadMatches() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://gethilingual.com/api/user/match")!)
        if let session = HLUser.getCurrentUser().getSession() {
            request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "HLAT " + session.sessionId]
            request.HTTPMethod = "GET"

            if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil) {
                print(returnedData)
                if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                    print(returnString)
                    matches = HLUser.fromJSONArray(returnedData)
                    carousel.reloadData()
                }
            }
        }
    }

    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return matches.count
    }

    func sendMessageButtonPressed(sender: AnyObject) {

        sendRequestToUser(matches[sender.tag].userId)
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
            sendMessageButton.addTarget(self, action: #selector(MatchingViewController.sendMessageButtonPressed(_:)), forControlEvents: .TouchUpInside)

            profileViewCell.profileView.addSubview(sendMessageButton)

            //Yay magic numbers! 💩
            //We'll change this when we convert this to a scroll view
            sendMessageButton.frame.size = CGSize(width: profileViewCell.profileView.frame.size.width, height: 12)
            sendMessageButton.center.x = profileViewCell.profileView.frame.size.width/2
            sendMessageButton.center.y = profileViewCell.profileView.frame.size.height - 20;
            sendMessageButton.tag = index
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