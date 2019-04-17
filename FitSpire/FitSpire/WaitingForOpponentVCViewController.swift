//
//  WaitingForOpponentVCViewController.swift
//  FitSpire
//
//  Created by Raman Prasad on 08/04/19.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit
import FirebaseDatabase

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
        print("Yipeee")
        
        //Process new coordinates
    }
}
