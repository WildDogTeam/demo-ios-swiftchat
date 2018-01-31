//
//  MessagesViewController.swift
//  WildChat-Swift
//
//  Created by Garin on 15/10/19.
//  Copyright © 2015年 wilddog. All rights reserved.
//

import UIKit
import Foundation
import Wilddog

class MessagesViewController: JSQMessagesViewController {
    
    var user: WDGUser?
    
    var messages = [Message]()
    var avatars = Dictionary<String, UIImage>()
    
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageView(with: UIColor.jsq_messageBubbleLightGray())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageView(with: UIColor.jsq_messageBubbleGreen())
    var senderImageUrl: String!
    var batchMessages = true
    var ref: WDGSyncReference!
    var auth: WDGAuth!
    
    
    // *** STEP 1: STORE WILDDOG REFERENCES
    var messagesRef: WDGSyncReference!
    
    func setupWilddog() {
        // *** STEP 2: SETUP WILDDOG
        messagesRef = WDGSync.sync().reference().child("messages")
        
        // *** STEP 4: RECEIVE MESSAGES FROM WILDDOG
        messagesRef.observe(WDGDataEventType.childAdded) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let text = value!["text"] as? String
            let sender = value!["sender"] as? String
            let imageUrl = value!["imageUrl"] as? String
            
            let message = Message(text: text, sender: sender, imageUrl: imageUrl)
            self.messages.append(message)
            self.finishReceivingMessage()
        }
    }
    
    func sendMessage(text: String!, sender: String!) {
        // *** STEP 3: ADD A MESSAGE TO WILDDOG
        messagesRef.childByAutoId().setValue([
            "text":text,
            "sender":sender,
            "imageUrl":senderImageUrl
            ])
    }
    
    func tempSendMessage(text: String!, sender: String!) {
        let message = Message(text: text, sender: sender, imageUrl: senderImageUrl)
        messages.append(message)
    }
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData.init(contentsOf: url as URL) {
                    let image = UIImage(data: data as Data)
                    let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage = JSQMessagesAvatarFactory.avatar(with: image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name: name, incoming: incoming)
    }
    
    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = name.count
        let initials : String? = name.substring(to: sender.index(sender.startIndex, offsetBy: min(3, nameLength)))
        let userImage = JSQMessagesAvatarFactory.avatar(withUserInitials: initials, backgroundColor: color, textColor: UIColor.black, font: UIFont.systemFont(ofSize: CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputToolbar!.contentView!.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        navigationController?.navigationBar.topItem?.title = "Logout"
        
        sender = (sender != nil) ? sender : "Anonymous"
        var profileImageUrl : String!
        if user!.providerData.count > 0 {
            profileImageUrl = try! NSString.init(contentsOf: (user?.providerData[0].photoURL)!, encoding: 0) as String
            
        }
        if let urlString = profileImageUrl {
            setupAvatarImage(name: sender, imageUrl: urlString as String, incoming: false)
            senderImageUrl = urlString as String
        } else {
            setupAvatarColor(name: sender, incoming: false)
            senderImageUrl = ""
        }
        
        setupWilddog()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView!.collectionViewLayout!.springinessEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if auth != nil {
            try! auth.signOut()
        }
    }
    
    // ACTIONS
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottom(animated: true);
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, sender: String!, date: Date!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        sendMessage(text: text, sender: sender);
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("Camera pressed!")
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAt indexPath: IndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        
        if message.sender() == sender {
            return UIImageView(image: outgoingBubbleImageView?.image, highlightedImage: outgoingBubbleImageView?.highlightedImage)
        }
        return UIImageView(image: incomingBubbleImageView?.image, highlightedImage: incomingBubbleImageView?.highlightedImage)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAt indexPath: IndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        if let avatar = avatars[message.sender()] {
            return UIImageView(image: avatar)
        } else {
            setupAvatarImage(name: message.sender(), imageUrl: message.imageUrl(), incoming: true)
            return UIImageView(image:avatars[message.sender()])
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.sender() == sender {
            cell.textView!.textColor = UIColor.black
        } else {
            cell.textView!.textColor = UIColor.white
        }
        //        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        //        cell.textView.linkTextAttributes = attributes
        return cell
    }
    
    
    // View  usernames above bubbles
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        
        // Sent by me, skip
        if message.sender() == sender {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.sender())
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.sender() == sender {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }

}
