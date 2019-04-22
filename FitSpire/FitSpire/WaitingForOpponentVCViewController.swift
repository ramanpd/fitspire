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
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        print(currentCreatedGameID)
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
            
        }
    }
}
