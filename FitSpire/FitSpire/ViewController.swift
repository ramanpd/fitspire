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
var PLAYER_PROFILENAME: AnyObject?
var PLAYER_ID: AnyObject?
var TOTAL_GAMES: Int?
var TOTAL_LOSSES: Int?
var TOTAL_PUSHUP_GAMES: Int?
var TOTAL_SITUP_GAMES: Int?
var TOTAL_SQUATS_GAMES: Int?
var TOTAL_WALKING_GAMES: Int?
var TOTAL_WINS: Int?
class ViewController: UIViewController {
    
    var dict : [String : AnyObject]!
    var ref: DatabaseReference!
    var profileName: AnyObject?
    var profileID: AnyObject?
    var users = [User]()
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
        //fetchPlayerGameRecord()
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
    func fetchPlayerGameRecord()
    {
        print("FETtttttttchinnnggggggg")
        print(self.profileID)
        print(PLAYER_ID)

        Database.database().reference().child("users/\(self.profileID!)").observe(.value, with: {(DataSnapshot) in print(DataSnapshot)
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{

                TOTAL_GAMES = dictionary["totalGames"] as! Int
                if(TOTAL_GAMES==nil){
                    print("Found totalGamesPlayed to be nil when pulling from Firebase")
                }
                TOTAL_LOSSES = dictionary["totalLosses"] as! Int
                TOTAL_PUSHUP_GAMES = dictionary["totalPushupsGames"] as! Int
                TOTAL_SITUP_GAMES = dictionary["totalSitupsGames"] as! Int
                TOTAL_SQUATS_GAMES = dictionary["totalSquatsGames"] as! Int
                TOTAL_WALKING_GAMES = dictionary["totalWalkingGames"] as! Int
                TOTAL_WINS = dictionary["totalWins"] as! Int


                print(self.profileName)
                print(TOTAL_GAMES!)
                print(TOTAL_LOSSES!)
                print(TOTAL_PUSHUP_GAMES!)
                print(TOTAL_SITUP_GAMES!)
                print(TOTAL_SQUATS_GAMES!)
                print(TOTAL_WALKING_GAMES!)
                print(TOTAL_WINS!)
            }
        }, withCancel: nil)
        print("Feeeeeeeeeeeettttccchhhhhhh eeeeennnnddddddd")

    }
    func getUsers()
    {
        print("-------- Database Command-------------")
        Database.database().reference().child("users").observe(.childAdded, with: {(DataSnapshot) in print(DataSnapshot)
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                let user = User()
                print("profileID: \(self.profileID!)")
                user.facebookId = dictionary["id"]
                print(dictionary["id"])
                user.username = dictionary["username"]
                print(user.username)
                self.users.append(user)
                print("lololololololol")
                print(user.facebookId)
                
            }
        }, withCancel: nil)
    }
    func updateDatabase(facebookID:AnyObject, facebookUsername:AnyObject)
    {
            getUsers()
        var playerExists = false
        for user in self.users{
            if String(describing: user.facebookId) == String(describing: PLAYER_ID)
            {
                playerExists = true
            }
        }
            if(!playerExists){
                print("PLAYER DID NOT EXIST")
                self.ref.child("users/\(facebookID)/username").setValue(facebookUsername)
                self.ref.child("users/\(facebookID)/status").setValue(true)
                
                self.ref.child("users/\(facebookID)/totalGames").setValue(0)
                self.ref.child("users/\(facebookID)/totalWins").setValue(0)
                self.ref.child("users/\(facebookID)/totalLosses").setValue(0)
                
                self.ref.child("users/\(facebookID)/totalWalkingGames").setValue(0)
                self.ref.child("users/\(facebookID)/totalSitupsGames").setValue(0)
                self.ref.child("users/\(facebookID)/totalPushupsGames").setValue(0)
                self.ref.child("users/\(facebookID)/totalSquatsGames").setValue(0)
            }
        else
            {
                self.ref.child("users/\(facebookID)/username").setValue(facebookUsername)
                self.ref.child("users/\(facebookID)/status").setValue(true)
                
        }
            print("Feeeeeeeeeeeettttccchhhhhhh eeeeennnnddddddd")

        
        print("checking id")
    
        print("---------------- Databse Command End --------------------")
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as? [String : AnyObject]
                    //print(result!)
                    
                    
                    self.profileName = self.dict?["name"]
                    self.profileID = self.dict?["id"]
                    
                    print("REEEEEEEEeEEeeeeeeeeeeee")
                    print(self.profileID)
                    

                    PLAYER_PROFILENAME = self.profileName
                    PLAYER_ID  = self.profileID
                    print("CHECKOUT VALUE BELOW")

                    print(self.profileID)
                    print(PLAYER_ID)

                    self.updateDatabase(facebookID: self.profileID!, facebookUsername:self.profileName!)
                    self.fetchPlayerGameRecord()
                }
            })
        }
    }
    func getProfileID()-> AnyObject! {
        return profileID
    }
    func getProfileName()-> AnyObject!{
        return profileName
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

