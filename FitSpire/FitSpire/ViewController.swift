//
//  ViewController.swift
//  FitSpire
//
//  Created by Connor Clancy on 12/03/2019.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let accessToken=FBSDKAccessToken.current()
        
        
        if (accessToken == nil){
            print("Success")
            let loginButton = FBSDKLoginButton.init()
            loginButton.readPermissions = ["public_profile", "email"]
            loginButton.center = view.center
            
            view.addSubview(loginButton)
        }
        else{
            print("Failure")
        }
    }


}

