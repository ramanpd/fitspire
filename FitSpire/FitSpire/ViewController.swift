//
// ViewController.swift
//  FitSpire
//
//  Created by Connor Clancy on 12/03/2019.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//
//I make a comment
//I make a comment again

import UIKit
import FBSDKLoginKit
import FirebaseDatabase

class ViewController: UIViewController {
    
    var dict : [String : AnyObject]!
    var ref: DatabaseReference!
    var profileName: AnyObject?
    var profileID: AnyObject?
    
    //MARKS: Properties
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var logInBtn: UIButton!
    
    @IBOutlet weak var logOutBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        ref = Database.database().reference()
        NotificationCenter.default.addObserver(self,selector: #selector(self.changeStatusOnTermination),name: NSNotification.Name(rawValue: "applicationWillTerminate"),object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.changeStatusOnBecomingActive),name: NSNotification.Name(rawValue: "applicationDidBecomeActive"),object: nil)
        NotificationCenter.default.addObserver(self,selector:#selector(self.changeStatusOnEnteringBackground),name:NSNotification.Name(rawValue:"applicationDidEnterBackground"),object: nil)
        if(FBSDKAccessToken.current() == nil)
        {
            logInBtn.isHidden = false
            continueBtn.isHidden = true
            logOutBtn.isHidden = true
            
        }
        else
        {
            logInBtn.isHidden = true
            logOutBtn.isHidden = false
            continueBtn.isHidden = false
            self.getFBUserData()
            print(dict)
            
        }
    }
    @objc private func changeStatusOnTermination(notification: NSNotification){
        //do stuff using the userInfo property of the notification object
        self.ref.child("users/\(profileID!)/status").setValue(false)
    }
    @objc private func changeStatusOnEnteringBackground(notification: NSNotification){
        //do stuff using the userInfo property of the notification object
        self.ref.child("users/\(profileID!)/status").setValue(false)
    }
    @objc private func changeStatusOnBecomingActive(notification: NSNotification){
        //do stuff using the userInfo property of the notification object
        self.ref.child("users/\(profileID!)/status").setValue(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnFBLoginPressed(_ sender: UIButton) {
        if(FBSDKAccessToken.current() == nil)
        {
            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
                if (error == nil){
                    let fbloginresult : FBSDKLoginManagerLoginResult = result!
                    if fbloginresult.grantedPermissions != nil {
                        if(fbloginresult.grantedPermissions.contains("email"))
                        {
                            self.getFBUserData()
                            //fbLoginManager.logOut()
                        }
                    }
                }
            }
        }
        else
        {
//            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier:"secondViewController") as! SecondViewController
//            
//            self.navigationController?.pushViewController(secondViewController, animated: true)
            self.getFBUserData()
//            var userID = user["id"] as NSString
//            FBSDKProfilePicture
//            var facebookProfileUrl = "http://graph.facebook.com/\(userID)/picture?type=large"
        }
        
    }
    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        if(FBSDKAccessToken.current() != nil)
        {
            fbLoginManager.logOut()
            print("Logout success")
            logInBtn.isHidden = false
            logOutBtn.isHidden = true
            continueBtn.isHidden = false
        }
        else{
            print("logout failure")
        }
    }
    
    func updateDatabase(facebookID:AnyObject, facebookUsername:AnyObject)
    {
         print("-------- Database Command-------------")
        //self.ref.child("fitspire-a5dc1/User/").setValue("James is an asshole!!")
        print("checking id")
        //self.ref.child("users").child(facebookID).setValue(["name":self.dict?["name"]])
        //self.ref.child("users").child(facebookID).setValue(["name":self.dict?["name"]])
        self.ref.child("users/\(facebookID)/username").setValue(facebookUsername)
        self.ref.child("users/\(facebookID)/status").setValue(true)
        //self.ref.child("fitspire-a5dc1/users/\(String(describing: facebookID))/profilePicture/").setValue(self.dict?["profile"])
        print("---------------- Databse Command End --------------------")
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as? [String : AnyObject]
                    //print(result!)
                    
                    
                    self.profileName = self.dict?["name"]
                    self.profileID=self.dict?["id"]
                    print("holahola")
                    print(self.profileName!)
                    print(self.profileID!)
                    self.updateDatabase(facebookID: self.profileID!, facebookUsername:self.profileName!)
                    //var profilePicture = self.dict?["picture"]
                    //var pictureURL = profilePicture?["url"]
                }
            })
        }
    }
    //    func btnFBLoginPressed(_ sender: AnyObject) {
//        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
//        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
//            if (error == nil){
//                let fbloginresult : FBSDKLoginManagerLoginResult = result!
//                if fbloginresult.grantedPermissions != nil {
//                    if(fbloginresult.grantedPermissions.contains("email"))
//                    {
//                        self.getFBUserData()
//                        fbLoginManager.logOut()
//                    }
//                }
//            }
//        }
//    }
    
//    func getFBUserData(){
//        if((FBSDKAccessToken.current()) != nil){
//            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
//                if (error == nil){
//                    self.dict = result as! [String : AnyObject]
//                    print(result!)
//                    print(self.dict)
//                }
//            })
//        }
//    }

}

//class ViewController: UIViewController{
//
//    var dict : [String : AnyObject]!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        //creating button
//        //creating button
//        let loginButton = FBSDKLoginButton(readPermissions: [ .publicProfile ])
//        loginButton.center = view.center
//
//        //adding it to view
//        view.addSubview(loginButton)
//
//        //if the user is already logged in
//        if let accessToken = FBSDKAccessToken.current(){
//            getFBUserData()
//        }
//    }
//
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        // Do any additional setup after loading the view, typically from a nib.
////        let accessToken=FBSDKAccessToken.current()
////
////
////        if (accessToken == nil){
////            print("Success")
////            let loginButton = FBSDKLoginButton.init()
////            loginButton.readPermissions = ["public_profile", "email"]
////
////            loginButton.center = view.center
////
////            view.addSubview(loginButton)
////        }
////        else{
////            print("Failure")
////        }
////    }
//    //when login button clicked
//    @objc func loginButtonClicked(sender: UIButton) {
//
//        let loginManager=FBSDKLoginManager();
//        loginManager.logIn(readPermissions: [ReadPermission.publicProfile], viewController : self) { loginResult in
//            switch loginResult {
//            case .failed(let error):
//                print(error)
//            case .cancelled:
//                print("User cancelled login")
//            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
//                print("Logged in")
//            }
//        }
//    }
//
//    //function is fetching the user data
//    func getFBUserData(){
//        if((FBSDKAccessToken.current()) != nil){
//            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
//                if (error == nil){
//                    self.dict = result as! [String : AnyObject]
//                    print(result!)
//                    print(self.dict)
//                }
//            })
//        }
//    }
//
//
//}

