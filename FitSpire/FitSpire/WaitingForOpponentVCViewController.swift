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
        ref.child("games/\(currentCreatedGameID)/gameStarted").observe(.childChanged, with: {(DataSnapshot) in
            print("Yipeee")
        })
        


}
}
