//
//  ChatViewController.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/14/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import AVFoundation

class NonPastableTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

//Displays both the sent and received messages in a single chat

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var user: HLUser!
    var currentUser = HLUser.getCurrentUser()
    var messageTest = [String]()
    var messages = [HLMessage]()
    var scroll = 0
    var images: UIImage!

    var audioPlayer: AVAudioPlayer!
    var recordingSession: AVAudioSession!

    //This is not hard coding
    //This variable is set by another view when this view comes on screen
    var recipientId: Int64 = -1

    @IBOutlet weak var detailsProfile: UIBarButtonItem!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var hiddenTextField: UITextField!

    let tapRec = UITapGestureRecognizer()

    @IBOutlet weak var testView: AccessoryView!
    var selectedCellIndex: Int?


    var curPlayingMessage: UIButton?
    var isPlayingMessage = false

    var editingCellIndex: Int?
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ChatViewController.loadMoreMessages(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)

        self.title = user.name
        print(user.name)
        print(user.userId)
        loadMessages()
        self.chatTableView.estimatedRowHeight = 40
        self.chatTableView.rowHeight = UITableViewAutomaticDimension
        self.tabBarController?.tabBar.isHidden = true
        enableKeyboardHideOnTap()

        setupEditMenuButtons()

        testView.chatViewController = self

        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.handleNewMessageNotification(_:)), name: NSNotification.Name(rawValue: AppDelegate.NotificationTypes.newMessage.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.handleEditedMessageNotification(_:)), name: NSNotification.Name(rawValue: AppDelegate.NotificationTypes.editedMessage.rawValue), object: nil)

        //Code for bringing up audio scren
       // let controller = AudioRecorderViewController()
       // controller.audioRecorderDelegate = self
        //presentViewController(controller, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chatTableView.scrollToBottom(animated: true)
    }



    func tappedView() {
        print("image tapped")
    }


    override func viewWillDisappear(_ animated: Bool) {
        let chatURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(recipientId).chat")
        let count = messages.count

        //Caches up to 50 messages on disk
        let last50 = Array(messages[(count >= 50 ? count-50 : 0)..<count])
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            if NSKeyedArchiver.archiveRootObject(last50, toFile: chatURL.path) {
                //Succeeded in writing to file
                print("Wrote message cache to disk")
            } else {
                print("Failed to write chat cache")
            }
        })


        if let lastMessage = last50.last {
            if NSKeyedArchiver.archiveRootObject(lastMessage, toFile: chatURL.appendingPathExtension("last").path) {
                print("Wrote last message to disk")
            } else {
                print("Failed to write last message to disk")
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        for message in messages {
            message.image = nil
        }
    }

    func handleEditedMessageNotification(_ notification: Notification) {
        didReceiveMessage()
    }

    func handleNewMessageNotification(_ notification: Notification) {
        didReceiveMessage()
    }

    func didReceiveMessage() {
        loadMessages()
    }

    func saveMessageEdit(editedText: String) {
        let message = messages[editingCellIndex!]
        if editedText != message.text {
            message.editedText = editedText
            message.saveMessageEdit()
            tableView.reloadRows(at: [IndexPath(row: editingCellIndex!, section:0)], with: .automatic)
        }
    }

    func sendMessageWithText(_ text: String) -> Bool {
        if let message = HLServer.sendMessageWithText(text, receiverID: recipientId) {
            print("Sent message")
            print(message.text)

            loadMessages()

            return true
        }

        print("Faild to send message")

        return false
    }

    func sendImage(_ image: UIImage) {
         DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {

            if HLServer.sendImage(image, toUser: UInt64(self.recipientId)) {
                print("Sent image")
                DispatchQueue.main.async(execute: {
                    self.loadMessages()
                })
            } else {
                print("Failed to send image")
            }

        })
    }

    func sendImageWithData(_ data: Data) {
        if let message = HLServer.sendImageWithData(data, receiverID: recipientId) {
            print("Sent voice message")
            print(message)
        }

        loadMessages()

    }

    func sendVoiceMessageWithData(_ data: Data) {
        if let message = HLServer.sendVoiceMessageWithData(data, receiverID: recipientId) {
            print("Sent voice message")
            print(message)
        }

        loadMessages()

    }
    func setupEditMenuButtons() {
        let menuController = UIMenuController.shared

        let editItem = UIMenuItem(title: "Edit".localized, action: #selector(ChatViewController.editMessage))
        let translateItem = UIMenuItem(title: "Translate".localized, action: #selector(ChatViewController.translateMessage))

        menuController.menuItems = [editItem, translateItem]
    }

    func translateMessage() {

        let message = messages[selectedCellIndex!]

        if message.translatedText == nil {
            if let translatedText = HLServer.getTranslationForMessage(message, fromLanguage: nil) {
                message.translatedText = translatedText
            }

            if message.editedText != nil {
                if let translatedEdit = HLServer.getTranslationForMessage(message, edit: true, fromLanguage: nil) {
                    message.translatedEdit = translatedEdit
                }
            }
        }

        if message.translatedText != nil {
            message.showTranslation = !message.showTranslation
            if let cell = tableView.cellForRow(at: IndexPath(row: selectedCellIndex!, section: 0)) as? ChatTableViewCell {
                setupTextCell(cell, forMessage: message)
            } else if let cell = tableView.cellForRow(at: IndexPath(row: selectedCellIndex!, section: 0)) as? ChatEditedTableViewCell {
                setupEditedCell(cell, forMessage: message)
            }
        } else {
            print("Cannot translate message")
        }
    }

    func editMessage() {
        editingCellIndex = selectedCellIndex

        testView.textView.becomeFirstResponder()
        testView.didBegingEditing()
        let selectedMessage = messages[selectedCellIndex!]
        if let editText = selectedMessage.editedText {
            testView.textView.text = editText
        } else {
            testView.textView.text = selectedMessage.text
        }
        testView.textViewDidChange(testView.textView)

        tableView.scrollToRow(at: IndexPath(item: editingCellIndex!, section: 0), at: .bottom, animated: true)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(ChatViewController.editMessage) {
            return selectedCellIndex != nil && canEditMessage()
        } else if action == #selector(ChatViewController.translateMessage) {
            return selectedCellIndex != nil
        } else if selectedCellIndex != nil {
            return false
        }

        return super.canPerformAction(action, withSender: sender)
    }

    @IBAction func details(_ sender: AnyObject) {
        //load user profile

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "detailsSegue" {
            let messageDetailViewController = segue.destination as! DetailViewController
            messageDetailViewController.user = user
            messageDetailViewController.hiddenName = true
        } else if segue.identifier == "showImage" {
             let messageDetailViewController = segue.destination as! InlargeImageViewController
            messageDetailViewController.image = self.images
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    func canEditMessage() -> Bool {
        if selectedCellIndex != nil {
            return messages[selectedCellIndex!].senderID  !=  currentUser!.userId
        }
        return false
    }

    override var inputAccessoryView: UIView? {
        return testView
    }

    fileprivate func enableKeyboardHideOnTap() {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.menuWillHide(_:)), name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    func textViewDidChange(_ textView: UITextView) {
        tableView.scrollToBottom()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard editingCellIndex == nil else {
            return
        }

        let menuController = UIMenuController.shared

        let bubble: CGRect

        if let cell = tableView.cellForRow(at: indexPath) as? ChatTableViewCell {
            bubble = cell.convert(messages[(indexPath as NSIndexPath).row].senderID == currentUser?.userId ? cell.chatBubbleRight.frame : cell.chatBubbleLeft.frame, to: self.view)
        } else if let cell = tableView.cellForRow(at: indexPath) as? ChatEditedTableViewCell {
            bubble = cell.convert(messages[(indexPath as NSIndexPath).row].senderID == currentUser?.userId ? cell.chatBubbleRight.frame : cell.chatBubbleLeft.frame, to: self.view)
        } else {
            return
        }

        selectedCellIndex = (indexPath as NSIndexPath).row

        //This keeps the keyboard up if it's already up
        if testView.textView.isFirstResponder {
            hiddenTextField.becomeFirstResponder()
        }

        //This delay MUST be here
        //Otherwiser, the whenever the first responder changes, the menu immediately disappears
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 5 * 1000 * 1000), execute: {
            menuController.setTargetRect(bubble, in: self.view)
            menuController.setMenuVisible(true, animated: true)
        })
    }

    func menuWillHide(_ notification: Notification) {
        selectedCellIndex = nil
    }

    func keyboardWillShow(_ notification: Notification) {
        self.chatTableView.scrollToBottom()
    }

    func keyboardWillChangeFrame(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animate(withDuration: duration) { () -> Void in
            if let height = self.navigationController?.navigationBar.frame.height {
                let inset = UIEdgeInsetsMake(height + 20, 0, keyboardFrame.size.height, 0)
                self.chatTableView.contentInset = inset
                self.chatTableView.scrollIndicatorInsets = inset
            }
        }

        if editingCellIndex != nil {
            tableView.scrollToRow(at: IndexPath(item: editingCellIndex!, section: 0), at: .bottom, animated: true)
        }
    }

    func setupTextCell(_ cell: ChatTableViewCell, forMessage message: HLMessage) {
        if message.senderID  ==  currentUser?.userId {
            cell.chatBubbleLeft.isHidden = true
            cell.chatBubbleLeft.text = ""
            cell.chatLeftImage.isHidden = true
            cell.chatRightImage.layer.cornerRadius = 6
            //cell.chatBubbleRight.layer.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5).CGColor
            cell.chatBubbleRight.text = message.showTranslation ? message.translatedText! : message.text
            cell.chatBubbleRight.isHidden = false
            cell.chatRightImage.isHidden = false
        } else {
            cell.chatBubbleRight.isHidden = true
            cell.chatBubbleRight.text = ""
            cell.chatBubbleLeft.text = ""
            cell.chatRightImage.isHidden = true
            cell.chatLeftImage.layer.cornerRadius = 6
            //cell.chatBubbleLeft.layer.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5).CGColor
            cell.chatBubbleLeft.text = message.showTranslation ? message.translatedText! : message.text
            cell.chatLeftImage.isHidden = false
            cell.chatBubbleLeft.isHidden = false
        }
    }

    func setupEditedCell(_ cell: ChatEditedTableViewCell, forMessage message: HLMessage) {
        if message.attributedEditedText == nil {
            let lcs = longestCommonSubsequence(message.text, s2: message.editedText!)
            message.attributedEditedText = getDiff(message.text, s2: message.editedText!, lcs: lcs)
        }

        if message.senderID  ==  currentUser?.userId {
            cell.chatBubbleLeft.isHidden = true
            cell.leftMessageLabel.text = ""
            cell.leftEditedMessageLabel.text = ""
            cell.chatBubbleLeft.frame.size.height = 0
            cell.editChatLeftImage.isHidden = true
            cell.chatBubbleRight.isHidden = false
            cell.editChatRightImage.layer.cornerRadius = 6

            cell.rightMessageLabel.text = message.showTranslation ? message.translatedText! : message.text
            if message.showTranslation {
                cell.rightEditedMessageLabel.text = message.translatedEdit
            } else {
                cell.rightEditedMessageLabel.attributedText = message.attributedEditedText
            }
            cell.editChatRightImage.isHidden = false
        } else {
            cell.chatBubbleRight.isHidden = true
            cell.rightMessageLabel.text = ""
            cell.rightEditedMessageLabel.text = ""
            cell.chatBubbleLeft.isHidden = false
            cell.editChatRightImage.isHidden = true
            cell.editChatLeftImage.layer.cornerRadius = 6

            cell.leftMessageLabel.text = message.showTranslation ? message.translatedText! : message.text
            if message.showTranslation {
                cell.leftEditedMessageLabel.text = message.translatedEdit
            } else {
                cell.leftEditedMessageLabel.attributedText = message.attributedEditedText
            }
            cell.editChatLeftImage.isHidden = false
        }
    }

    //MARK:CELL ROW
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[(indexPath as NSIndexPath).row]

        if (message.audioURL != nil) {
            let cellIdentity = "ChatVoiceTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity, for: indexPath) as! ChatVoiceTableViewCell

            let shownButton: UIButton
            let hiddenButton: UIButton

            if messages[(indexPath as NSIndexPath).row].senderID  ==  currentUser?.userId {
                shownButton = cell.rightButton
                hiddenButton = cell.leftButton
            } else {
                shownButton = cell.leftButton
                hiddenButton = cell.rightButton
            }

            shownButton.isHidden = false
            hiddenButton.isHidden = true

            shownButton.tag = (indexPath as NSIndexPath).row

            if isPlayingMessage {
                shownButton.setImage(UIImage(named: "shittyx")?.withRenderingMode(.alwaysOriginal), for: UIControlState())
            } else {
                shownButton.setImage(UIImage(named: "shittyplay")?.withRenderingMode(.alwaysOriginal), for: UIControlState())
            }
            return cell

        } else if (message.pictureURL != nil) {
            let cellIdentity = "ChatPictureTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity, for: indexPath) as! ChatPictureTableViewCell

            let shownPicture: UIImageView
            let hiddenPicture: UIImageView
            let tap = UITapGestureRecognizer(target: self, action: #selector(FlashcardSetViewController.handleTap(_:)))
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(FlashcardSetViewController.handleTap(_:)))

            if messages[(indexPath as NSIndexPath).row].senderID  ==  currentUser?.userId {
                shownPicture = cell.rightPicture
                hiddenPicture = cell.leftPicture
            } else {
                shownPicture = cell.leftPicture
                hiddenPicture = cell.rightPicture
            }

            shownPicture.isHidden = false
            hiddenPicture.isHidden = true
            shownPicture.layer.cornerRadius = 8
            shownPicture.clipsToBounds = true
            shownPicture.layer.borderWidth = 0.5
            cell.tag = (indexPath as NSIndexPath).row
            cell.leftPicture.addGestureRecognizer(tap)
            cell.rightPicture.addGestureRecognizer(tap1)
            shownPicture.tag = (indexPath as NSIndexPath).row
            //shownPicture.addGestureRecognizer(tap)
            if let image = message.image {
                shownPicture.image = image
            } else {
                cell.loadingImageView = shownPicture
                HLServer.loadImageWithURL(message.pictureURL!, forCell: cell, inTableView: tableView, atIndexPath: indexPath, withCallback: { (image) in
                    message.image = image
                })
            }

            return cell

        } else if message.editedText == nil {
            let cellIdentity = "ChatTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity, for: indexPath) as! ChatTableViewCell

            setupTextCell(cell, forMessage: message)


            return cell
        } else {
            let cellIdentity = "ChatEditedTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity, for: indexPath) as! ChatEditedTableViewCell

            setupEditedCell(cell, forMessage: message)

            return cell
        }
    }
    //For riley
    @IBAction func handleTap(_ sender: AnyObject) {
        print(sender)
        let cell = tableView.cellForRow(at: IndexPath(row: sender.view.tag, section: 0)) as! ChatPictureTableViewCell
        print(cell.leftPicture)
        if sender.view === cell.leftPicture {
            images = cell.leftPicture.image
        } else {
            images = cell.rightPicture.image

        }
        performSegue(withIdentifier: "showImage", sender: self.view)
        print("tap")
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        curPlayingMessage!.setImage(UIImage(named: "shittyplay")?.withRenderingMode(.alwaysOriginal), for: UIControlState())
        isPlayingMessage = false
    }

    @IBAction func tapPlayButton(_ sender: UIButton) {
        if isPlayingMessage == true {
            if sender == curPlayingMessage {
                sender.setImage(UIImage(named: "shittyplay")?.withRenderingMode(.alwaysOriginal), for: UIControlState())
                isPlayingMessage = false
                audioPlayer.stop()
            } else {
                curPlayingMessage!.setImage(UIImage(named: "shittyplay")?.withRenderingMode(.alwaysOriginal), for: UIControlState())
                audioPlayer.stop()
                isPlayingMessage = false
                tapPlayButton(sender)
            }
        } else {
            let deviceURL = messages[sender.tag].messageUUID!
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioURL = documentsURL.appendingPathComponent("\(deviceURL).m4a")
            recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try recordingSession.setActive(true)

                //If an exception breakpoint stops here, you can usually ignore it because the exception is caught down below
                try audioPlayer = AVAudioPlayer(contentsOf: audioURL)
                audioPlayer.delegate = self
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
                audioPlayer.volume = 1
                curPlayingMessage = sender
                audioPlayer.play()
            } catch let error as NSError {
                print("Downloading audio...", error)
                ChatViewController.loadFileSync(messages[sender.tag].audioURL! as URL, writeTo: audioURL, completion: {(audioURL: String, error: NSError!) in
                    print("downloaded to: \(audioURL)")
                } as! (String, NSError?) -> Void)
                tapPlayButton(sender)
            }
            isPlayingMessage = true
            sender.setImage(UIImage(named: "shittyx")?.withRenderingMode(.alwaysOriginal), for: UIControlState())
        }
    }

    static func loadFileSync(_ url: URL, writeTo: URL, completion:(_ path: String, _ error: NSError?) -> Void) {
        //let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let urlToLoad: URL
        if url.scheme == "http" {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            components.scheme = "https"
            urlToLoad = components.url!
        } else {
            urlToLoad = url
        }
        let destinationUrl = writeTo
        if FileManager().fileExists(atPath: destinationUrl.path) {
            completion(destinationUrl.path, nil)
        } else if let dataFromURL = try? Data(contentsOf: urlToLoad) {
            if (try? dataFromURL.write(to: destinationUrl, options: [.atomic])) != nil {
                completion(destinationUrl.path, nil)
            } else {
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl.path, error)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func loadMoreMessages(_ refreshControl: UIRefreshControl) {
        if let previousMessages = HLServer.retrieveMessageFromUser(recipientId, before: messages.first!.messageUUID!, max: 20) {
            messages = previousMessages + messages
            tableView.reloadData()
        } else {
            print("Couldn't load any more messages")
        }

        refreshControl.endRefreshing()
    }

    func loadEdits(_ before: Int64, count: Int=50) {
        if let edits = HLServer.retrieveEditedMessages(recipientId, before: before) {
            for edit in edits {
                if let id = (edit["id"] as? NSNumber)?.int64Value {
                    if let encodedEditText = edit["editData"] as? String {
                        if let editText = encodedEditText.fromBase64() {
                            for message in messages {
                                if message.messageUUID == id {
                                    message.editedText = editText
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func loadMessages() {
        let chatURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(recipientId).chat")
        if let storedMessages = NSKeyedUnarchiver.unarchiveObject(withFile: chatURL.path) as? [HLMessage] {
            messages = storedMessages
        }

        let lastCached: Int64
        if messages.count > 0 {
            lastCached = messages.last!.messageUUID!
        } else {
            lastCached = 0
        }

        if let newMessages = HLServer.retrieveMessageFromUser(recipientId, after: lastCached, max: 1000) {
            if newMessages.count > 0 {
                messages += newMessages
            } else {
                print("No new messages")
            }

            loadEdits(lastCached, count: 50 - newMessages.count)

            tableView.reloadData()
            tableView.scrollToBottom()
        } else {
            print("Failed to retrieve messsages from server")
        }
    }

    //Longest Common Subsequence
    func longestCommonSubsequence(_ s1: String, s2: String) -> String {
        print("s1: ", s1)
        print("s2: ", s2)
        var L = [[Int]](repeating: [Int](repeating: 0, count: s2.characters.count+1), count: s1.characters.count+1)

        for i in 0...s1.characters.count {
            for j in 0...s2.characters.count {
                if i == 0 || j == 0 {
                    L[i][j] = 0
                } else if s1[i-1] == s2[j-1] {
                    L[i][j] = L[i-1][j-1] + 1
                } else {
                    L[i][j] = max(L[i-1][j], L[i][j-1])
                }
            }
        }

        // Create a character array to store the lcs string
        var lcs = ""

        // Start from the right-most-bottom-most corner and
        // one by one store characters in lcs[]
        var i = s1.characters.count
        var j = s2.characters.count
        while (i > 0 && j > 0) {
            // If current character in X[] and Y are same, then
            // current character is part of LCS
            if (s1[i-1] == s2[j-1]) {
                lcs.insert(s1[i-1]!, at: lcs.startIndex)
                i -= 1
                j -= 1
            }

            // If not same, then find the larger of two and
            // go in the direction of larger value
            else if (L[i-1][j] > L[i][j-1]) {
                i -= 1
            } else {
                j -= 1
            }
        }

        print(lcs)
        return lcs
    }

    func getDiff(_ s1: String, s2: String, lcs: String) -> NSAttributedString {

        var i = 0
        var j = 0
        var k = 0

        let attributedDiff = NSMutableAttributedString()
        var removedString = ""
        var addedString = ""
        var commonString = ""

        func appendRemovedString() {
            let attributedAddedString = NSAttributedString(string: removedString, attributes: [NSForegroundColorAttributeName : UIColor.gray, NSStrikethroughStyleAttributeName : NSNumber(value: Int32(NSUnderlineStyle.styleSingle.rawValue))])
            attributedDiff.append(attributedAddedString)
            removedString = ""
        }

        func appendAddedString() {
            let attributedRemovedString = NSAttributedString(string: addedString, attributes: [NSForegroundColorAttributeName : UIColor(red: 0, green: 169/255, blue: 0, alpha: 1)])
            attributedDiff.append(attributedRemovedString)
            addedString = ""
        }

        func appendCommonString() {
            let attributedCommonString = NSAttributedString(string: commonString)
            attributedDiff.append(attributedCommonString)
            commonString = ""
        }

        while i < s1.characters.count || j < s2.characters.count || k < lcs.characters.count {

            if s2[j] != lcs[k] {
                if removedString != "" {
                    appendRemovedString()
                } else if commonString != "" {
                    appendCommonString()
                }

                addedString.append(s2[j]!)
                j += 1
            } else if s1[i] != lcs[k] {
                if addedString != "" {
                    appendAddedString()
                } else if commonString != "" {
                    appendCommonString()
                }

                removedString.append(s1[i]!)
                i += 1
            } else {
                if removedString != "" {
                    appendRemovedString()
                } else if addedString != "" {
                    appendAddedString()
                }

                commonString.append(lcs[k]!)
                k += 1
                i += 1
                j += 1
            }
        }

        if addedString != "" {
            appendAddedString()
        } else if removedString != "" {
            appendRemovedString()
        } else if commonString != "" {
            appendCommonString()
        }

        return attributedDiff
    }

    override func didReceiveMemoryWarning() {
        print("Received memory warning")
        if !self.isViewLoaded || self.view.window == nil {
            print("Dumping messages")
            messages = []
        } else {
            print("Trimming messages array")
            messages.removeSubrange(0..<messages.count/2)
            tableView.reloadData()
        }
    }
}

extension UITableView {
    func scrollToBottom(ofSection section: Int=0, animated: Bool=true) {
        let cellCount = self.numberOfRows(inSection: section)

        guard cellCount > 0 else {
            return
        }
        self.scrollToRow(at: IndexPath(item: cellCount-1, section: section), at: .top, animated: animated)
    }
}


extension String {

    subscript (i: Int) -> Character? {
        if i >= self.characters.count {
            return nil
        }
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }

//    subscript (i: Int) -> String {
//        return String(self[i] as Character)
//    }

    subscript (r: Range<Int>) -> String {
        let start = characters.index(startIndex, offsetBy: r.lowerBound)
        let end = characters.index(start, offsetBy: r.upperBound - r.lowerBound)
        return self[Range(start ..< end)]
    }

    func toBase64() -> String? {
        return self.data(using: String.Encoding.utf8)?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }

    func fromBase64() -> String? {
        if let data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0)) {
            return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String
        }

        return nil
    }
}
