//
//  ProfileVC.swift
//  FitSpire
//
//  Created by Connor Clancy on 13/03/2019.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit
import FBSDKLoginKit
class ProfileVC: UIViewController {
    var dict : [String : AnyObject]!
    
    //MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let loginManager : FBSDKLoginManager = FBSDKLoginManager()
        self.getFBUserData()
        
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    print(result!)
                    print("CUNT")
                    
                    var profileName = self.dict?["name"]
                    var profileId=self.dict?["id"]
                    var profilePicture = self.dict?["picture"]
                    var pictureURL = profilePicture?["url"]
                    self.nameTextField.text = profileName as? String
                    let url = NSURL(string: "https://graph.facebook.com/\(profileId!)/picture?type=large&return_ssl_resources=1")
                    self.profilePicImageView.image = UIImage(data: NSData(contentsOf: url! as URL)! as Data)
                    print(self.dict)
                }
            })
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
