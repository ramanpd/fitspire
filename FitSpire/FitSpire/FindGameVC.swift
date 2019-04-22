////
////  FindGameVC.swift
////  FitSpire
////
////  Created by Raman Prasad on 08/04/19.
////  Copyright © 2019 Connor Clancy. All rights reserved.
////

import UIKit
import Firebase
import FirebaseDatabase

var games = [Game]()
var gameIndex = 0
class FindGameVC: UITableViewController{
    let cellId = "cellId"
    var dict : [String : AnyObject]!
    var ref: DatabaseReference!

    var profileName: AnyObject?
    var profileID: AnyObject?
    var gameID: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        games.removeAll()
        tableView.reloadData()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchGame()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func fetchGame()
    {
        Database.database().reference().child("games").observe(.childAdded, with: {(DataSnapshot) in print(DataSnapshot)
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                let game = Game()
                game.player1ID = dictionary["player1ID"] as! String
                game.gameType = dictionary["gameType"]! as! String
                game.player1Name = dictionary["player1Name"]! as! String
                game.target = dictionary["target"] as! Int
                game.gameID = DataSnapshot.key as AnyObject
                games.append(game)
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
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath: IndexPath)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is WalkingVC{
            let vc = segue.destination as? WalkingVC
            vc?.isSingleplayer=false
            vc?.multiplayerDistance=games[gameIndex].target
            vc?.currentPlayer=2
            vc?.currentCreatedGameID = games[gameIndex].gameID
            print("Succesfully changed VARIABLE")
        }
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        return games.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let game = games[indexPath.row]
        var gameTypeText: String = game.gameType
        var targetText = " Target: " + String(game.target)
        var challengerText = " Challenger: " + String(describing: game.player1Name)
        var cellText = gameTypeText + targetText + challengerText
        cell.textLabel?.text = cellText
        return cell
    }

class GameCell: UITableViewCell
{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
}
