//
//  LoginViewController.swift
//  WildChat-Swift
//
//  Created by Garin on 15/10/12.
//  Copyright © 2015年 wilddog. All rights reserved.
//

import UIKit
import Wilddog

class LoginViewController: UIViewController {

    var ref: Wilddog!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Wilddog(url: "https://swift-chat.wilddogio.com")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        title = "Wild Chat"
    }

    @IBAction func login(sender: AnyObject) {

        [ref.authAnonymouslyWithCompletionBlock({ (error , authData) -> Void in
            if error != nil{
                //There was an error authenticating
            }else {
                NSLog("uid : %@", (authData?.uid)!)
                let messagesVc = MessagesViewController()
                messagesVc.user = authData
                let sub = authData.uid[authData.uid.startIndex.advancedBy(10)..<authData.uid.endIndex]
                messagesVc.sender = sub
                messagesVc.ref = self.ref
                self.navigationController!.pushViewController(messagesVc, animated: true)
            }
        })]
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
