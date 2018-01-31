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

    var ref: WDGSyncReference!
    var auth: WDGAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = WDGSync.sync().reference()
        auth = WDGAuth.auth()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Wild Chat"
    }

    @IBAction func login(sender: AnyObject) {

        auth?.signInAnonymously(completion: { (user, error) in
            if error != nil {
                //There was an error authenticating
            } else {
                NSLog("uid : %@", (user?.uid)!)
                let messagesVc = MessagesViewController()
                messagesVc.user = user
                let uid = user?.uid
//                let sub = uid?.suffix(uid!.count - 10)
                let sub = uid![uid!.index(uid!.startIndex, offsetBy: 10)..<uid!.endIndex]
//                let sub = user?.uid[(user?.uid.startIndex.advanced(10))!..<(user?.uid.endIndex)!]
                messagesVc.sender = String.init(describing: sub)
                messagesVc.ref = self.ref
                messagesVc.auth = self.auth
                self.navigationController!.pushViewController(messagesVc, animated: true)
            }
        })
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
