//
//  SitupScreen.swift
//  FitSpire Testing
//
//  Created by Connor Clancy on 30/03/2019.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class SitupScreen: UIViewController {

    
    private let MotionManager = CMMotionManager()
    
    
    
    @IBOutlet weak var BeginButton: UIButton!
    @IBOutlet weak var Counter: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func BeginSitupDetection(_ sender: UIButton) {
        BeginButton
        if(MotionManager.isAccelerometerAvailable){
            MotionManager.accelerometerUpdateInterval = 0.2
            //declare used variables
            var YZ_BUFFER: [Double] = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0] //used to measure peaks ("significance" of middle point)
            var iterCount = 0
            var valueCount = 0
            var currentTime:Float = 0
            var timeStamp:Float = 0
            var scoreAve:Double = 0, scoreTotal:Double = 0, setAve:Double = 0, totalAve:Double = 0
            var currentScore:Double = 0
            var onScreenCount = 0
            
            let REST_AVERAGE:Double = -0.3258    //15 seconds of rest Average, improved upon later
            var restAchieved = false
            
            var XY_BUFFER: [Double] = [0.0,0.0,0.0,0.0,0.0,0.0]
            
            //Following line acts as loop statement, loops every 0.2 seconds
            MotionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (input, error) in
                if let data = input {
                    self.view.reloadInputViews()
                    let x = data.acceleration.x
                    let y = data.acceleration.y
                    let z = data.acceleration.z
                    
                    /*
                    Initial input of 9 values (1.8 seconds) to fill up YZ_BUFFER array so that operations can be applied to it.
                     */
                    if(iterCount < 9){
                        YZ_BUFFER[iterCount] = y-z
                    }
                    /*
                    "Wind-up" period where average waits to be very close to a predetermined "rest" level to standardise input before detection begins.
                     */
                    else if(iterCount >= 9 && !restAchieved){
                        if(self.currentAve(set: YZ_BUFFER) - REST_AVERAGE > 0.01){
                            YZ_BUFFER = self.leftshiftArr(inputArr: YZ_BUFFER, value: y-z)
                            XY_BUFFER = self.leftshiftArr(inputArr: XY_BUFFER, value: (x+y+1)-(y-z))
                            valueCount += 1
                        }
                        else{
                            restAchieved = true
                        }
                    }
                    /*
                    Sit-up Detection algorithm designed around detecting a peak in Y - Z coordinates and then detecting
                         the relative positions of X^2 and X+Y+1 to further refine it to sit-ups specifically.
                     */
                    else{
                        print("iteration: \(iterCount)\t\tValueCount: \(valueCount)")
                        YZ_BUFFER = self.leftshiftArr(inputArr: YZ_BUFFER, value: y-z)
                        
                        currentScore = self.peakScore(range: YZ_BUFFER)
                        scoreTotal = scoreTotal + currentScore
                        scoreAve = scoreTotal / Double(valueCount)//replace 10 with wait period length
                        
                        if(pow(currentScore - scoreAve, 2) != Double.infinity){
                            totalAve = totalAve + pow(currentScore - scoreAve, 2)
                        }
                        setAve = totalAve / Double(valueCount)
                        
                       
                        let stndev = sqrt(setAve)
                        print("Score: \(self.peakScore(range: YZ_BUFFER))\t\tstdDev\(stndev)")
                        if (currentScore > max(setAve + stndev, 0.1) && currentScore < setAve + stndev*3 && currentTime - timeStamp > 2) {
                            let x2 = pow(x, 2)
                            if(x2 < y-z || x2 < y){
                                print("Time: \(currentTime)\t\tscore: \(currentScore)")
                                timeStamp = currentTime
                                onScreenCount += 1
                                self.Counter.text = String(onScreenCount)
                            }
                        }
                        valueCount += 1
                    }
                    iterCount += 1
                    currentTime += 0.2
                }
            }
        }
        else{
            print("no accel, using test data")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    private func peakScore(range: [Double]) -> Double{
        let prevScore = range[4] - ((range[0] + range[1] + range[2] + range[3])/4)
        let postScore = range[4] - ((range[5] + range[6] + range[7] + range[8])/4)
        return (prevScore + postScore) / 2
    }
    
    private func currentAve(set: [Double]) -> Double{
        var i = 0
        var total:Double = 0
        while(i < set.count){
            total += set[i]
            i += 1
        }
        return total / Double(set.count-1)
    }
    
    private func leftshiftArr(inputArr: [Double], value: Double) -> [Double]{
        var i = 0
        var outputArr = inputArr
        while(i < outputArr.count-1){
            outputArr[i] = outputArr[i+1]
            i += 1
        }
        outputArr[outputArr.count-1] = value
        return outputArr
    }

}
