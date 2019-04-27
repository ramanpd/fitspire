//
//  WaitingForOpponentVCViewController.swift
//  FitSpire
//
//  Created by Raman Prasad on 08/04/19.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit
import FirebaseDatabase
var currentGame = Game()

class WaitingForOpponentVCViewController: UIViewController {

    @IBOutlet weak var OpponentImage: UIImageView!
    @IBOutlet weak var OpponentName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference!
    var playersOnline = [User]()
    let cellId = "cellId"
    var dict : [String : AnyObject]!
    
    var profileName: AnyObject?
    var profileID: AnyObject?
    var gameID: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        print(currentCreatedGameID)
        
        tableView.reloadData()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchPlayersOnline()
        ref.child("games").observe(.childAdded, with: {(DataSnapshot) in
            self.ref.child("games").child(currentCreatedGameID).observe(.childChanged, with: {(DataSnapshot) in
                self.foundSnapshot(DataSnapshot)
                })
        })
        
}
    func foundSnapshot(_ snapshot: DataSnapshot){
    
        if(currentCreatedGameType == "Running"){
            performSegue(withIdentifier: "Wait2WalkingSegue", sender: self)
        }
}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is WalkingVC{
            let vc = segue.destination as? WalkingVC
            vc?.isSingleplayer = false
            vc?.multiplayerDistance=currentCreateGameTarget
            vc?.currentPlayer=1
            vc?.currentCreatedGameID=currentCreatedGameID as AnyObject
            
        }
    }
    func fetchPlayersOnline()
    {
        Database.database().reference().child("users").observe(.value, with: {(DataSnapshot) in print(DataSnapshot)
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                let player = User()
                player.username = dictionary["username"]
                player.status = dictionary["status"] as! Bool
                player.facebookId = DataSnapshot.key as AnyObject
                if player.status == true{
                    self.playersOnline.append(player)
                }
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    @objc func handleCancel()
    {
        dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath: IndexPath)
    {
        gameIndex = indexPath.row
        print(games[gameIndex].gameID!)
        gameID = games[gameIndex].gameID as! String
        ref = Database.database().reference()
        getFBUserData()
        playGame()
    }
    /*
     Function playGame:
     The goal is to identify what type of game has been selected and then perform a segue to that game screen while also setting its variable
     "isSinglePlayer" to false
     */
    func playGame()
    {
        if(games[gameIndex].gameType=="Running"){
            print("\nIdentified game: Running")
            performSegue(withIdentifier: "MultiWalkingSegue", sender: self)
            
        }else if(games[gameIndex].gameType=="Push-ups"){
            print("\nIdentified game: Push-ups")
        }else if(games[gameIndex].gameType=="Sit-ups"){
            print("\n Identified game: Sit-ups")
        }
        print("Almost there"+games[gameIndex].gameType)
    }

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
        
        self.ref.child("games/\(gameID)/player2ID").setValue(facebookID)
        self.ref.child("games/\(gameID)/gameStarted").setValue(true)
        self.ref.child("games/\(gameID)/player2Score").setValue(0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return playersOnline.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let playerOnline = playersOnline[indexPath.row]
        let cellText = playerOnline.username
        cell.textLabel?.text = cellText as! String
        return cell
    }
}
