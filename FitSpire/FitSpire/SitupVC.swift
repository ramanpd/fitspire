//
//  SitupVC.swift
//  FitSpire Testing
//
//  Created by Connor Clancy on 30/03/2019.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
import AudioToolbox

class SitupVC: UIViewController {
    
    
    private let MotionManager = CMMotionManager()
    
    
    @IBOutlet var BeginButton: UIView!
    @IBOutlet weak var Counter: UILabel!
    @IBOutlet weak var OpponentScore: UILabel!
    @IBOutlet weak var ScoreBox: UIImageView!
    @IBOutlet weak var OpponentText: UILabel!
    
    /*
     Multiplayer options: isSingleplayer, multiplayerTarget passed in from segue
    */
    var isSingleplayer = false
    var multiplayerTarget = 10
    var winnerDeclared = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(isSingleplayer){
            OpponentScore.removeFromSuperview();
            ScoreBox.removeFromSuperview();
            OpponentText.removeFromSuperview();
        }
        // Do any additional setup after loading the view.
    }
    
     let shapeLayer = CAShapeLayer()
    
    @IBAction func BeginSitupDetection(_ sender: UIButton) {
        BeginButton.removeFromSuperview()
        if(MotionManager.isAccelerometerAvailable && MotionManager.isGyroAvailable){
            MotionManager.accelerometerUpdateInterval = 0.2
            MotionManager.gyroUpdateInterval = 0.2
            //declare used variables
            let YZ = DeviatedArray()  //used to measure peaks ("significance" of middle point)
            let XZ1 = DeviatedArray()
            
            var iterCount = 0
            var valueCount = 0
            var currentTime:Float = 0
            var timeStamp:Float = 0
            var currentScore:Double = 0
            var onScreenCount = 0
            var stnOffsetYZ: Double = 0, stnOffsetXZ1: Double = 0
            var PRE_REQ = false
            
            let REST_AVERAGE:Double = -0.3258    //15 seconds of rest Average, improved upon later
            var WaitForRest = true
            var R_BUFFER: [Double] = [0,0,0,0,0,0,0,0,0]
            
            //Needed to track x and y at time of score measurement (AKA 5 iterations previous)
            var X_BUFFER: [Double] = [0.0,0.0,0.0,0.0,0.0]
            var Y_BUFFER: [Double] = [0.0,0.0,0.0,0.0,0.0]
            
            var x:Double = 0, y:Double = 0, z:Double = 0
            //Following line acts as loop statement, loops every 0.2 seconds
            MotionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (input, error) in
                if let data = input {
                    self.view.reloadInputViews()
                    x = data.acceleration.x
                    y = data.acceleration.y
                    z = data.acceleration.z
                   
                }
            }
            MotionManager.startGyroUpdates(to: OperationQueue.current!) { (input, error) in
                if let data = input {
//                    let gx = data.rotationRate.x
                    let gy = data.rotationRate.y
                    let gz = data.rotationRate.z
                    
                    if(!self.isSingleplayer){
                        /*
                        UPDATE MULTIPLAYER LABEL HERE
                        This loop runs every 0.2 seconds so a network listener could be used
                        */
                        //get Opponent's current score and winnerTarget.
                        if(onScreenCount >= self.multiplayerTarget && self.winnerDeclared == false){
                            //you win - send to server
                            self.winnerDeclared = true;
                            print("winner!")
                        }
                    }
                    /*
                     Initial input of 9 values (1.8 seconds) to fill up YZ_BUFFER array so that operations can be applied to it.
                     */
                    if(iterCount < 9){
                        YZ.leftshift(value: (gy + gz)/2 + (y-z))
                        R_BUFFER[iterCount] = (x+y+z)/3
                    }
                        /*
                         "Wind-up" period where average waits to be very close to a predetermined "rest" level to standardise input before detection begins.
                         */
                    else if(WaitForRest){
                        if(abs(self.currentAve(set: R_BUFFER) - REST_AVERAGE) > 0.05){
                            YZ.leftshift(value: (gy + gz)/2 + (y-z))
                            XZ1.leftshift(value: x+z+1) //(x+y+1)-(y-z)
                            X_BUFFER = self.leftshiftArr(inputArr: X_BUFFER, value: x)
                            Y_BUFFER = self.leftshiftArr(inputArr: Y_BUFFER, value: y)
                            R_BUFFER = self.leftshiftArr(inputArr: R_BUFFER, value: (x+y+z)/3)
                            valueCount += 1
                        }
                        else{
                            WaitForRest = false
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        }
                    }
                        /*
                         Sit-up Detection algorithm designed around detecting a peak in Y - Z coordinates and then detecting
                         the relative positions of X^2 and X+Y+1 to further refine it to sit-ups specifically.
                         */
                    else{
                        print("iteration: \(iterCount)\t\tValueCount: \(valueCount)")
                        YZ.leftshift(value: (gy + gz)/2 + (y-z))
                        XZ1.leftshift(value: x+z+1)
                        
                        X_BUFFER = self.leftshiftArr(inputArr: X_BUFFER, value: x)
                        Y_BUFFER = self.leftshiftArr(inputArr: Y_BUFFER, value: y)
                        
                        currentScore = self.peakScore(range: YZ.Array())
                        if(onScreenCount < 3){
                            stnOffsetYZ = YZ.stnOffsetCalc(nextValue: currentScore, Iteration: Double(iterCount))
                        }
                        
                        
                        //print("Score: \(self.peakScore(range: YZ.Array()))\t\tstdDev\(stnOffsetYZ)")
                        if (currentScore > max(stnOffsetYZ, 0.1) && currentScore < stnOffsetYZ*3) {
                            let x2 = pow(X_BUFFER[0], 2)
                            if(x2 < YZ.mid()){
                                print("Time: \(currentTime)\t\tscore: \(currentScore)")
                                timeStamp = currentTime
                                PRE_REQ = true
                            }
                        }
                        if(currentTime - timeStamp > 3.5){
                            PRE_REQ = false
                        }
                        //If peak initial peak detected, proceed to look for follow up peak of x+z+1
                        //done using the direct value instead of a score as line tends to have lesser slope on peaks
                        if(PRE_REQ){
                            currentScore = XZ1.mid()
                            if(onScreenCount < 4){
                                stnOffsetXZ1 = YZ.stnOffsetCalc(nextValue: currentScore, Iteration: Double(iterCount))
                            }
                            if (currentScore > max(stnOffsetXZ1, 0.1) && currentScore < stnOffsetXZ1*3 && currentTime - timeStamp > 1) {
                                self.drawCircle()
                                onScreenCount += 1
                                self.Counter.text = String(onScreenCount)
                                PRE_REQ = false
                                print("\nXZpeak: \(currentScore)\t\tTime: \(currentTime)\t\tthreshold: \(stnOffsetXZ1)\n")
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
            print("no accelerometer or no gyroscope error")
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
        let mid = (range.count/2)
        var i:Int = 0
        var prevScore: Double = 0, postScore: Double = 0
        while(i < mid){
            prevScore = prevScore + range[i]
            i += 1
        }
        prevScore = range[mid] - prevScore/Double(mid)
        i = mid + 1
        while(i < range.count){
            postScore = postScore + range[i]
            i += 1
        }
        postScore = range[mid] - postScore/Double(mid)
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
    
    private func drawCircle(){
        let center = view.center
        
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi, clockwise: true)
        trackLayer.path=circularPath.cgPath
        trackLayer.strokeColor=UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path=circularPath.cgPath
        shapeLayer.strokeColor=UIColor.yellow.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(shapeLayer)
        animateFunction()
    }
    
    fileprivate func animateFunction() {
        //stroke end means that as soon as you lift your finger from the tap, it initiates
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        
        basicAnimation.duration = 0.5
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "basic")
    }

}
