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

class WaitingForOpponentVCViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath )
//        cell.textLabel?.text = self.items[indexPath.row]
//        return cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let playerOnline = playersOnline[indexPath.row]
        let cellText = playerOnline.username
        cell.textLabel?.text = cellText as? String
        //cell.textLabel?.text = "JAMIE FOOKING LANNISTER"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.items.count;
        return playersOnline.count
    }
    

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
    var items: [String] = ["We", "Heart", "Swift"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        print(currentCreatedGameID)
        
        tableView.reloadData()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        //setupTable()
        fetchPlayersOnline()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        ref.child("games").observe(.childAdded, with: {(DataSnapshot) in
            self.ref.child("games").child(currentCreatedGameID).observe(.childChanged, with: {(DataSnapshot) in
                self.foundSnapshot(DataSnapshot)
                })
        })
    }
//    func setupTable()
//    {
//        tableView.register(PlayersOnlineCell.self, forCellReuseIdentifier: cellId)
//    }
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
        Database.database().reference().child("users").observe(.childAdded, with: {(DataSnapshot) in print(DataSnapshot)
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                let player = User()
                player.username = dictionary["username"]
                player.status = dictionary["status"] as? Int
                print("ROLORLOL")
                print(player.username)
                player.facebookId = DataSnapshot.key as AnyObject
                if player.status == 1{

                    print(PLAYER_PROFILENAME!)
                    print("goal")
                    if( String(describing: player.username) != String(describing: PLAYER_PROFILENAME)){
                    self.playersOnline.append(player)}
                }
            
                print(self.playersOnline.count)
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

    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        print("ENters stage 1")
//        return playersOnline.count
//    }
//
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//      //  let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
//       let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PlayersOnlineCell
//        let playerOnline = playersOnline[indexPath.row]
//        let cellText = playerOnline.username
//        cell.textLabel?.text = cellText as? String
//        cell.textLabel?.text = "JAMIE FOOKING LANNISTER"
//        return cell
//    }
//    class PlayersOnlineCell: UITableViewCell {
//
//        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//            super.init(style: style, reuseIdentifier: reuseIdentifier)
//        }
//
//        required init?(coder aDecoder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//
//    }

}
