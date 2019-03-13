//
//  WalkingVC.swift
//  FitSpire
//
//  Created by Connor Clancy on 13/03/2019.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit
import CoreMotion
class WalkingVC: UIViewController {
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    // MARK: - Properties
    @IBOutlet weak var GoButton: UIButton!
    @IBOutlet weak var StepCounter: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func onPress(_ sender: UIButton) {
        if(CMPedometer.isStepCountingAvailable() ){
            beginCounting()
        }else{
            StepCounter.text = "No Pedometer Found"
        }
    }
    /*
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func beginCounting(){
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            
            DispatchQueue.main.async {
                self?.StepCounter.text = "Step Count: " +  pedometerData.numberOfSteps.stringValue
            }
        }
    }

}
