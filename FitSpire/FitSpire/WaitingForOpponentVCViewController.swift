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
//        ref = Database.database().reference()
//        ref.observe(.childChanged, with: {(DataSnapshot) in
//            if let value = DataSnapshot?.value["games/"]
//            )
//        ref.observeEventType(FEventTypeChildAdded, withBlock: { snapshot in
//            if let value = snapshot?.value["author"] {
//                print("\(value)")
//            }
//            if let value = snapshot?.value["title"] {
//                print("\(value)")
//            }
//        })
//        // Do any additional setup after loading the view.
//    })
//    // Retrieve new posts as they are added to the database
//
//
//}
}
}
