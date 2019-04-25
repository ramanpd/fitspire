//
//  WinScreenVC.swift
//  FitSpire
//
//  Created by Connor Clancy on 25/04/2019.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit

class WinScreenVC: UIViewController {
    
    @IBOutlet weak var Targetlabel: UILabel!
    @IBOutlet weak var WinScoreLabel: UILabel!
    @IBOutlet weak var OpponentScoreLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var TitleText: UILabel!
    
    /*
     PASS IN FROM SEGUE
     */
    var opponentName:String!
    var target:Int!
    var playerScore:Double!
    var opponentScore:Double!
    let time = "120s"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TitleText.text = TitleText.text! + "\n" + opponentName
        Targetlabel.text = Targetlabel.text! + "\t\t\t\t\(target)"
        WinScoreLabel.text = WinScoreLabel.text! + "\t\t\(playerScore)"
        OpponentScoreLabel.text = OpponentScoreLabel.text! + "\t\(opponentScore.rounded())"
        TimeLabel.text = TimeLabel.text! + "\t\t\t\t\(time)"
        
        
        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "ToLose") {
//            let losevc = segue.destination as! LossScreenVC
//            losevc.target = target
//            losevc.lossScore = opponentScore
//
//        }
//    }
 
   

}
