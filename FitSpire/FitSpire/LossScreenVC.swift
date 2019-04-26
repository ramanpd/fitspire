//
//  LossScreenVC.swift
//  FitSpire
//
//  Created by Connor Clancy on 25/04/2019.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit

class LossScreenVC: UIViewController {

    
    @IBOutlet weak var message: UILabel!
    
    var target:Int!
    var lossScore:Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let opponentScore = target
        let lossMargin = 1 - lossScore / Double(target)
//        let lossMargin = 0.2
        if(lossMargin <= 0.3){
            message.text = "Almost had it!\nOnly \((lossMargin * 100).rounded())% behind"
        }
        else{
            message.text = "You need to try a\nlittle harder next time"
        }
        // Do any additional setup after loading the view.
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
