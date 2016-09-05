//
//  LoginViewController.swift
//  WildChat-Swift
//
//  Created by Garin on 15/10/12.
//  Copyright © 2015年 wilddog. All rights reserved.
//

import UIKit
import WilddogAuth
import WilddogSync

class LoginViewController: UIViewController {

    var ref: Wilddog!
    var auth: WDGAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Wilddog(url: "https://swift-chat.wilddogio.com")
        auth = WDGAuth.auth(appID: "swift-chat")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        title = "Wild Chat"
    }

    @IBAction func login(sender: AnyObject) {

        auth?.signInAnonymouslyWithCompletion(){(user, error) in
            if error != nil{
                //There was an error authenticating
            }else{
                NSLog("uid : %@", (user?.uid)!)
                let messagesVc = MessagesViewController()
                messagesVc.user = user
                let sub = user?.uid[(user?.uid.startIndex.advancedBy(10))!..<(user?.uid.endIndex)!]
                messagesVc.sender = sub
                messagesVc.ref = self.ref
                messagesVc.auth = self.auth
                self.navigationController!.pushViewController(messagesVc, animated: true)
            }
        }
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
