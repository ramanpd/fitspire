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
import Firebase
import FirebaseDatabase

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
    var isSingleplayer = true
    var multiplayerTarget:Int!
    var ref: DatabaseReference!
    var winnerDeclared = false
    
    var currentPlayer = 0
    var currentCreatedGameID: AnyObject?
    var opponentScore = 0
    var opponentName = ""
    var onScreenCount = 0
    
    
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
            
            var iterCount = 0
            var valueCount = 0
            var currentTime:Float = 0
            var timeStamp:Float = 0
            var currentScore:Double = 0
            var stnOffsetYZ: Double = 0
            
            let REST_AVERAGE:Double = -0.3258    //15 seconds of rest Average, improved upon later
            var WaitForRest = true
            var R_BUFFER: [Double] = [0,0,0,0,0,0,0,0,0]
            
            //Needed to track x and y at time of score measurement (AKA 5 iterations previous)
            var X_BUFFER: [Double] = [0.0,0.0,0.0,0.0,0.0]
            var Y_BUFFER: [Double] = [0.0,0.0,0.0,0.0,0.0]
            
            var GX_GY_CHECK_BUFFER : [Double] = [0,0,0,0,0,0,0,0,0,0]
            
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
                    let gx = data.rotationRate.x
                    let gy = data.rotationRate.y
                    let gz = data.rotationRate.z
                    
                    if(!self.isSingleplayer){
                        /*
                        UPDATE MULTIPLAYER VALUES
                        This loop runs every 0.2 seconds so the network is updated here
                        */
                        //PUSH SCORE TO FIREBASE AND DETERMINE WIN-STATE
                        self.ref = Database.database().reference()
                        
                        if(self.currentPlayer==1){
                            print(self.currentCreatedGameID!)
                            print("HERE IS THE GAME ID ^^^^^^^")
                            self.ref.child("games/\(self.currentCreatedGameID!)/player1Score").setValue(self.onScreenCount)
                            //self.Player1ScoreLabel.text = "You: \(self!.onScreenCount) sit-ups"
                            print("COMPLETED UPDATE^^")
                            if(self.onScreenCount >= self.multiplayerTarget){
                                self.ref.child("games/\(self.currentCreatedGameID!)/gameFinished").setValue(true)
                                self.MotionManager.stopGyroUpdates()
                                self.MotionManager.stopAccelerometerUpdates()
                                self.performSegue(withIdentifier: "WinSegue", sender: self)
                                print("winner winner chicken dinner - player 1")
                            }
                        }
                        else if(self.currentPlayer==2){
                            print(self.currentCreatedGameID!)
                            print("HERE IS THE GAME ID ^^^^^^^")
                            self.ref.child("games/\(self.currentCreatedGameID!)/player2Score").setValue(self.onScreenCount)
                            //self.Player2ScoreLabel.text = "You: \(self!.onScreenCount) sit-ups"
                            print("COMPLETED UPDATE^^")
                            if(self.onScreenCount >= self.multiplayerTarget){
                                self.ref.child("games/\(self.currentCreatedGameID!)/gameFinished").setValue(true)
                                self.MotionManager.stopGyroUpdates()
                                self.MotionManager.stopAccelerometerUpdates()
                                self.performSegue(withIdentifier: "WinSegue", sender: self)
                                print("winner winner chicken dinner - player 2")
                            }
                        }
                        else{
                            print("CurrentPlayer not found")
                        }
                    
                    //PULL OPPONENT SCORE FROM FIREBASE
                        if(self.currentPlayer==1){
                            //pull payer 2
                            print("pulled opponents score start")
                            Database.database().reference().child("games/\(self.currentCreatedGameID!)").observeSingleEvent(of: .value, with: {DataSnapshot in
                                if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                                    print("pulled if let")
                                    let finishStatus = dictionary["gameFinished"] as! Bool
                                    self.opponentScore = dictionary["player2Score"] as! Int
                                    self.opponentName = dictionary["player1ID"] as! String
//                                  self.Player1ScoreLabel.text = "opponent: \(self.opponentScore)m"
                                    if(finishStatus == true && self.onScreenCount < self.multiplayerTarget){
                                        self.MotionManager.stopGyroUpdates(); self.MotionManager.stopAccelerometerUpdates()
                                        self.performSegue(withIdentifier: "LoseSegue", sender: self)
                                    }
                                }
                                else{
                                    //self.opponentScore = self.opponentScore
                                }
                                print("pulled opponents score end")
                            
                            })
                        }
                        else if(self.currentPlayer == 2){
                            //pull payer 2
                            print("pulled opponents score start")
                            Database.database().reference().child("games/\(self.currentCreatedGameID!)").observeSingleEvent(of: .value, with: {DataSnapshot in
                                if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                                    print("pulled if let")
                                    let finishStatus = dictionary["gameFinished"] as! Bool
                                    self.opponentScore = dictionary["player1Score"] as! Int
                                    self.opponentName = dictionary["player2ID"] as! String
//                                self.Player1ScoreLabel.text = "opponent: \(self.opponentScore)m"
                                    if(finishStatus == true && self.onScreenCount < self.multiplayerTarget){
                                        self.MotionManager.stopGyroUpdates(); self.MotionManager.stopAccelerometerUpdates()
                                        self.performSegue(withIdentifier: "LoseSegue", sender: self)
                                    }
                                }
                                else{
                                    //self.opponentScore = self.opponentScore
                                }
                                print("pulled opponents score end")
                            })
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
                        GX_GY_CHECK_BUFFER = self.leftshiftArr(inputArr: GX_GY_CHECK_BUFFER, value: max(gx, gy))
                        
                        X_BUFFER = self.leftshiftArr(inputArr: X_BUFFER, value: x)
                        Y_BUFFER = self.leftshiftArr(inputArr: Y_BUFFER, value: y)
                        
                        currentScore = self.peakScore(range: YZ.Array())
                        if(self.onScreenCount < 3){
                            stnOffsetYZ = YZ.stnOffsetCalc(nextValue: currentScore, Iteration: Double(iterCount))
                        }
                        
                        let currentMax = self.arrayMax(inputArr: GX_GY_CHECK_BUFFER)
//                        print("GXGY MAX \(currentMax)")
                        
//                        print("Score: \(self.peakScore(range: YZ.Array()))\t\tstdDev\(stnOffsetYZ)")
                        if (currentScore > max(stnOffsetYZ, 0.1) && currentScore < stnOffsetYZ*3  && currentTime - timeStamp > 2) {
                            let x2 = pow(X_BUFFER[0], 2)
                            
                            if(x2 < YZ.mid()  && currentMax < 3){
                                self.drawCircle()
                                self.onScreenCount += 1
                                self.Counter.text = String(self.onScreenCount)
                                print("Time: \(currentTime)\t\tscore: \(currentScore)")
                                timeStamp = currentTime
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

     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "WinSegue") {
            let winvc = segue.destination as! WinScreenVC
            winvc.opponentName = opponentName
            winvc.target = multiplayerTarget
            winvc.playerScore = Double(onScreenCount)
            winvc.opponentScore = Double(opponentScore)
            
            
        }
        else if (segue.identifier == "LoseSegue") {
            let losevc = segue.destination as! LossScreenVC
            losevc.target = multiplayerTarget
            losevc.lossScore = Double(onScreenCount)
        }
    }

    //MARK: - Methods
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
    
    private func arrayMax(inputArr: [Double]) -> Double{
        var i = 0
        var m : Double = -10
        while(i < inputArr.count){
            if(inputArr[i] > m){
                m = inputArr[i]
            }
            i += 1
        }
        return m
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
