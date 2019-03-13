//
//  WalkingVC.swift
//  FitSpire
//
//  Created by Connor Clancy on 13/03/2019.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit
import CoreMotion
class WalkingVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return distanceOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(distanceOptions[row]) + " km"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        distanceSelection = distanceOptions[row]
        print(distanceOptions[row])
    }
    
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    // MARK: - Properties
    @IBOutlet weak var GoButton: UIButton!
    @IBOutlet weak var StepCounter: UILabel!
    @IBOutlet weak var DistanceChoice: UIPickerView!
    var distanceOptions: [Int] = [Int]()
    var distanceSelection = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceOptions = [1, 2, 3, 4]
        self.DistanceChoice.delegate = self
        self.DistanceChoice.dataSource = self
    
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func onPress(_ sender: UIButton) {
        if(CMPedometer.isStepCountingAvailable() ){
            //DistanceChoice.removeFromSuperview()
            //can't really test this without an actual iPhone so commenting it for now
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
                self?.StepCounter.text = "Goal: " + String(self?.distanceSelection ?? 1*1000 - pedometerData.numberOfSteps.intValue)
                //requires slef? and ?? 1 to safely unwrap from Int? to int...
                //Not really aware of what any of that means personally
            }
        }
    }

}
