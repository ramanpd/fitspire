//
//  CreateGameVC.swift
//  FitSpire
//
//  Created by Raman Prasad on 08/04/19.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseDatabase

class CreateGameVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    @IBOutlet weak var picker_0: UIPickerView!
    @IBOutlet weak var picker_2: UIPickerView!
    @IBOutlet weak var picker_1: UIPickerView!
    @IBOutlet weak var textField_0: UITextField!
    @IBOutlet weak var textField_1: UITextField!
    @IBOutlet weak var textField_2: UITextField!
    // Maintaining the other arrays as single array of arrays for efficient loading
    var subContentArray = [["Millimeter", "Centimeter", "Meter", "Kilometer", "Foot", "Yard", "Mile"],
                                   ["Milliliter", "Centiliter", "Liter", "Gallon", "Quart", "Pint", "Fluid ounce"],
                                   ["Milligram", "Centigram", "Gram", "Kilogram", "Stone", "Pound", "Ounce"]]
    
    
    // To keep track of user's current selection from the main content array
    var pickerGeneral1 = ["Length", "Volume", "Mass"]
    var _currentSelection: Int = 0
    
    // whenever current selection is modified, we need to reload other pickers as their content depends upon the current selection index only.
    var currentSelection: Int {
        get {
            return _currentSelection
        }
        set {
            _currentSelection = newValue
            picker_1 .reloadAllComponents()
            picker_2 .reloadAllComponents()
            
            textField_0.text = pickerGeneral1[_currentSelection]
            textField_1.text = subContentArray[_currentSelection][0]
            textField_2.text = subContentArray[_currentSelection][0]
        }
    }
    
    
    @IBOutlet weak var createGameBtn: UIButton!
    
    var dict : [String : AnyObject]!
    var ref: DatabaseReference!
    var profileName: AnyObject?
    var profileID: AnyObject?
    var gameID: String = ""
    
    
    @IBAction func CreateGameButtonPressed(_ sender: UIButton) {
        print("good 1")
        ref = Database.database().reference()
        print("good 2")
        getFBUserData()
        print("Good 3")
        performSegue(withIdentifier: "GoToWait", sender: self)
    }
    
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as? [String : AnyObject]
                    print("Here")
                    self.profileName = self.dict?["name"]
                    self.profileID=self.dict?["id"]
                    print("tree")
                    self.updateDatabase(facebookID: self.profileID!, facebookUsername:self.profileName!)
                    //var profilePicture = self.dict?["picture"]
                    //var pictureURL = profilePicture?["url"]
                }
            })
        }
    }
    func updateDatabase(facebookID:AnyObject, facebookUsername:AnyObject)
    {
        let gameID = 1222992
        print("abcd")
        self.ref.child("games").setValue(gameID)
        self.ref.child("games/\(gameID)/player1ID").setValue(facebookID)
        self.ref.child("games/\(gameID)/player1Score").setValue(0)
        self.ref.child("games/\(gameID)/player2Score").setValue(0)
        self.ref.child("games/\(gameID)/gameFinished").setValue(false)
        self.ref.child("games/\(gameID)/gameStarted").setValue(false)
        self.ref.child("games/\(gameID)/target").setValue(0)
    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if(pickerView == gameTarget)
//        {
//            return gameOptions.count
//        }
//        return targetOptions.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if(pickerView == gameTarget)
//        {
//            return String(gameOptions[row])
//        }
//        return String(targetOptions[row])
//    }
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        gameChoice = gameOptions[row]
//        print(gameOptions[row])
//    }
//
//    var gameChoice: String = ""
//    var gameOptions: [String] = [String]()
//    var targetOptions: [Int] = [Int]()
    override func viewDidLoad() {
        print("here first")
        super.viewDidLoad()
        currentSelection = 0;
        
        picker_0.delegate = self
        picker_0.dataSource = self
        picker_0.tag = 0
        
        picker_1.delegate = self
        picker_1.dataSource = self
        picker_1.tag = 1
        
        picker_2.delegate = self
        picker_2.dataSource = self
        picker_2.tag = 2
//        gameOptions = ["Running", "Sit-ups", "Push-ups", "Squats"]
//
//        targetOptions = []
//        self.gameType.delegate = self
//        self.gameType.dataSource = self
//
//
//        self.gameTarget.delegate = self
//        self.gameTarget.dataSource = self
        
        // Do any additional setup after loading the view.
    }
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return pickerGeneral1.count
        } else {
            return subContentArray[currentSelection].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return pickerGeneral1[row]
        } else {
            return subContentArray[currentSelection][row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            currentSelection = row
            
            textField_0.text = pickerGeneral1[row]
            textField_0.resignFirstResponder()
        } else if pickerView.tag == 1 {
            textField_1.text = subContentArray[currentSelection][row]
            textField_1.resignFirstResponder()
        } else if pickerView.tag == 2 {
            textField_2.text = subContentArray[currentSelection][row]
            textField_2.resignFirstResponder()
        }
    }

}
