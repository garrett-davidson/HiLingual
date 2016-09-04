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

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchTable.isHidden = false
        searchBar.showsCancelButton = true
        searchBar.showsSearchResultsButton = true
        return true

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchResults = []
        searchTable.reloadData()
        searchTable.isHidden = true
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Mark: Send to the server
        //whatever users that are received go into users
        //fill requests with true for each user
        print("sent search")
        if let text = searchBar.text {
            if let results = HLServer.getSearchResultsForQuery(text) {
                searchResults = results
                searchTable.reloadData()
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults = []
        searchTable.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    @IBAction func sendRequest(_ sender: UIButton) {
        //From search bar

        let index = sender.tag
        sender.isHidden = true
        if !HLServer.sendChatRequestToUser(searchResults[index].userId) {
            print("Failed to send request")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentity = "SearchTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity, for: indexPath) as! SearchTableViewCell
        let user = searchResults[(indexPath as NSIndexPath).row]

        cell.name.text = user.displayName
        cell.loadingImageView.layer.masksToBounds = false
        cell.loadingImageView.layer.cornerRadius = cell.loadingImageView.frame.height/2
        cell.loadingImageView.clipsToBounds = true
        if user.profilePicture != nil {
            cell.loadingImageView.image = user.profilePicture
        } else {
            HLServer.loadImageWithURL(user.profilePictureURL!, forCell: cell, inTableView: tableView, atIndexPath: indexPath, withCallback: { (image) in
                user.profilePicture = image
            })
        }
        cell.sendRequestButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 28)
        cell.sendRequestButton.setTitle("\u{f086}", for: UIControlState())
        cell.sendRequestButton.tag = (indexPath as NSIndexPath).row
        //Mark: Fills the view
        cell.langaugesLearning.text! = "Learning:".localized + " " + user.learningLanguages.toList()
        cell.languagesSpeaks.text! = "Speaks:".localized + " " + user.knownLanguages.toList()
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTable.estimatedRowHeight = 40
        self.searchTable.rowHeight = UITableViewAutomaticDimension
        carousel.bounceDistance = 0.1
        carousel.decelerationRate = 0.2
        carousel.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        loadMatches()
    }

    func loadMatches() {
        if let myMatches = HLServer.getMyMatches() {
            matches = myMatches
            carousel.reloadData()
        }
    }

    func numberOfItems(in carousel: iCarousel) -> Int {
        return matches.count
    }

    func sendMessageButtonPressed(_ sender: AnyObject) {
        //For the carousel view

        if !HLServer.sendChatRequestToUser(matches[sender.tag].userId) {
            print("Failed to send request to user")
        }
    }

    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var profileViewCell: MatchProfileView

        if let cell = view as? MatchProfileView {
            profileViewCell = cell
        } else {
            let width = self.view.frame.width - 50
            let height = self.view.frame.height - 150
            profileViewCell = MatchProfileView(frame: CGRect(x: 0, y: 0, width: width, height: height))

            profileViewCell.sendMessageButton = UIButton(type: .system)
            profileViewCell.sendMessageButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 48)
            profileViewCell.sendMessageButton.setTitle("\u{f086}", for: UIControlState())

            profileViewCell.sendMessageButton.addTarget(self, action: #selector(MatchingViewController.sendMessageButtonPressed(_:)), for: .touchUpInside)

            profileViewCell.profileView.addSubview(profileViewCell.sendMessageButton)

            //Yay magic numbers! 💩
            //We'll change this when we convert this to a scroll view
            profileViewCell.sendMessageButton.frame.size = CGSize(width: profileViewCell.profileView.frame.size.width/3, height: 30)
            profileViewCell.sendMessageButton.center.x = profileViewCell.profileView.frame.size.width/1.2
           // profileViewCell.sendMessageButton.layer.cornerRadius = 5
            //profileViewCell.sendMessageButton.layer.borderWidth = 1
           // profileViewCell.sendMessageButton.layer.borderColor = UIColor.blackColor().CGColor

            profileViewCell.sendMessageButton.center.y = profileViewCell.profileView.loadingImageView.center.y + 120
        }

        profileViewCell.sendMessageButton.tag = index
        profileViewCell.profileView.user = matches[index]
        profileViewCell.layer.borderWidth = 1

        return profileViewCell
    }

    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault defaultValue: CGFloat) -> CGFloat {
        switch option {
        case .spacing:
            return 1.05

        default:
            return defaultValue
        }
    }
}

class MatchProfileView: UIView {
    var profileView: ProfileView

    override init(frame: CGRect) {
        self.profileView = ProfileView(decoder: nil, frame: frame)
        super.init(frame: frame)
        self.addSubview(profileView)
    }

    required init?(coder aDecoder: NSCoder) {
        //We're never using this method to so fuck it 😁
        fatalError("init(coder:) has not been implemented")
    }

    var sendMessageButton: UIButton!
}
