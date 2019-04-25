//
//  WalkingVC.swift
//  FitSpire
//
//  Created by Connor Clancy on 13/03/2019.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit
import CoreMotion
import Firebase
import FirebaseDatabase

class WalkingVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return distanceOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(distanceOptions[row]) + " m"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        distanceSelection = distanceOptions[row]
        print(distanceOptions[row])
    }

    private let pedometer = CMPedometer()
    // MARK: - Properties
    @IBOutlet weak var GoButton: UIButton!
    @IBOutlet weak var DistanceChoice: UIPickerView!
    @IBOutlet weak var PercentLabel: UILabel!
    @IBOutlet weak var MeterCounter: UILabel!
    @IBOutlet weak var Player1ScoreLabel: UILabel!
    @IBOutlet weak var Player2ScoreLabel: UILabel!
    
    
    /*
     Multiplayer Related Variables
     isSingleplayer to be passed in from previous vc as "false" if multiplayer is chosen.
     multiplayerDistance should be passed in from previous VC as the distance target for both players.
     */
    var isSingleplayer = true
    var multiplayerDistance = 20
    var winnerDeclared = false
    var currentPlayer = 0
    var currentCreatedGameID: AnyObject?
    var ref: DatabaseReference!
    var opponentScore:Double = 0
    var opponentName:String = ""
    var distanceOptions: [Int] = [Int]()
    var distanceSelection = 1
    var percentWalked = 0.00
    var metersWalked:Double = 0

    let shapeLayerP1 = CAShapeLayer()
    let shapeLayerP2 = CAShapeLayer()   //Multiplayer

    override func viewDidLoad() {
        super.viewDidLoad()
        if(isSingleplayer){
            distanceOptions = [10, 200, 300, 500]
            self.DistanceChoice.delegate = self
            self.DistanceChoice.dataSource = self
        }
        else if(!isSingleplayer){
            DistanceChoice.removeFromSuperview()
            MeterCounter.text = "Press GO to begin!"
        }
    // Do any additional setup after loading the view.
    }

    // MARK: - Actions
    @IBAction func onPress(_ sender: UIButton) {
        if(CMPedometer.isStepCountingAvailable() ){
            //If singleplayer -> pick the pickerview selection, otherwise pick the inputted distance
            if(isSingleplayer){
                distanceSelection = distanceOptions[DistanceChoice.selectedRow(inComponent: 0)]
                DistanceChoice.removeFromSuperview()
            }
            else{   //Multiplayer
                distanceSelection = multiplayerDistance
            }

            //hide other labels etc
            GoButton.isHidden=true
            beginCounting()
        }else{
            MeterCounter.text = "No Pedometer Found"
        }
    }

    private func beginCounting(){
        self.MeterCounter.text = "Meters: 0  Goal: \(distanceSelection)m"

        if(isSingleplayer){
            drawCircle(drawingEndPoint: 0.00, radius: 120, circle: shapeLayerP1)
        }else{
            drawCircle(drawingEndPoint: 0.00, radius: 120, circle: shapeLayerP1)
            drawCircle(drawingEndPoint: 0.00, radius: 90, circle: shapeLayerP2)
        }

        let savedDistanceGoal = distanceSelection
        let doubleDistance:Double = Double(distanceSelection) + 0.00
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }

            DispatchQueue.main.async {
                self!.metersWalked = pedometerData.distance as! Double
                
                //PUSH METERSWALKED TO FIREBASE
                self!.ref = Database.database().reference()

                if(self!.currentCreatedGameID==nil){
                    print("WE GOT EM")
                }
                if(self!.currentPlayer==1){
                    //push meters walked to player1Score
                    //self.ref.child("games/\(gameID)/player2ID").setValue(facebookID)
                    print(self!.currentCreatedGameID!)
                    print("HERE IS THE GAME ID ^^^^^^^")
                    self!.ref.child("games/\(self!.currentCreatedGameID!)/player1Score").setValue(self!.metersWalked.rounded())
                    self!.Player1ScoreLabel.text = "You: \(self!.metersWalked.rounded())m"
                    print("COMPLETED UPDATE^^")
                    if(self!.metersWalked/doubleDistance >= 1){
                        self!.ref.child("games/\(self!.currentCreatedGameID!)/gameFinished").setValue(true)
                        print("winner winner chicken dinner - player 1")
                        self!.performSegue(withIdentifier: "WinSegue", sender: self)
                    }

                }else if(self!.currentPlayer==2){
                    print(self!.currentCreatedGameID!)
                    print("HERE IS THE GAME ID ^^^^^^^")
                    self!.ref.child("games/\(self!.currentCreatedGameID!)/player2Score").setValue(self!.metersWalked.rounded())
                    self!.Player2ScoreLabel.text = "You: \(self!.metersWalked.rounded())m"
                    print("COMPLETED UPDATE^^")
                    if(self!.metersWalked/doubleDistance >= 1){
                        self!.ref.child("games/\(self!.currentCreatedGameID!)/gameFinished").setValue(true)
                        print("winner winner chicken dinner - player 2")
                        self!.performSegue(withIdentifier: "WinSegue", sender: self)
                    }

                }else{
                    print("CurrentPlayer not found")
                }
                
                //PULL OPPONENT METERSWALKED FROM FIREBASE
                if(self!.currentPlayer==1){
                    //pull payer 2
                    print("pulled opponents score start")
                    Database.database().reference().child("games/\(self!.currentCreatedGameID!)").observeSingleEvent(of: .value, with: {DataSnapshot in
                        if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                            print("pulled if let")
                            let finishStatus = dictionary["gameFinished"] as! Bool
                            self!.opponentScore = dictionary["player2Score"] as! Double
                            self!.opponentName = dictionary["player1ID"] as! String
                            self!.Player1ScoreLabel.text = "opponent: \(self!.opponentScore)m"
                            if(finishStatus == true){
                                self!.performSegue(withIdentifier: "LoseSgue", sender: self)
                            }
                        }
                        else{
                             self!.opponentScore = self!.opponentScore
                        }
                        print("pulled opponents score end")

                    })
                }else if(self!.currentPlayer==2){
                    //pull player 1
                    print("pulled opponents score start")
                    Database.database().reference().child("games/\(self!.currentCreatedGameID!)").observeSingleEvent(of: .value, with: {DataSnapshot in
                        if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                            print("pulled if let")
                            let finishStatus = dictionary["gameFinished"] as! Bool
                            self!.opponentScore = dictionary["player1Score"] as! Double
                            self!.opponentName = dictionary["player1ID"] as! String
                            self!.Player1ScoreLabel.text = "opponent: \(self!.opponentScore)m"
                            if(finishStatus == true){
                                self!.performSegue(withIdentifier: "LoseSgue", sender: self)
                            }
                        }
                        else{
                            self!.opponentScore = self!.opponentScore
                        }
                        print("pulled opponents score end")
                    })
                }
                
                let opponent_progress = Double((self?.opponentScore)!)
                
                //Current user's update
                
                if((self!.metersWalked/doubleDistance)>=1){
                    self?.MeterCounter.text = "Exercise Complete!"
                    self?.PercentLabel.text = "100%"
                    self?.drawCircle(drawingEndPoint: 1.00, radius: 120, circle: (self?.shapeLayerP1)!)
                    self?.pedometer.stopUpdates()
                    
                }else{
                    self?.MeterCounter.text = "Meters: \(Int(self!.metersWalked.rounded()))  Goal: \(savedDistanceGoal)m"
                    self?.drawCircle(drawingEndPoint: self!.metersWalked/doubleDistance, radius: 120, circle: (self?.shapeLayerP1)!)
                    let cleanPercentage = Int(((self!.metersWalked/doubleDistance)*100).rounded())
                    self?.PercentLabel.text = "\(cleanPercentage)%"
                }

                //Update opponent's progress circle
                if(!(self?.isSingleplayer)!){   //Multiplayer
                    self?.drawCircle(drawingEndPoint: opponent_progress/doubleDistance, radius: 90, circle: (self?.shapeLayerP2)!)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "WinSegue") {
            let winvc = segue.destination as! WinScreenVC
            winvc.opponentName = opponentName
            winvc.target = distanceSelection
            winvc.playerScore = Double(distanceSelection)
            winvc.opponentScore = opponentScore
            
        }
        else if (segue.identifier == "LoseSegue") {
            let losevc = segue.destination as! LossScreenVC
            losevc.target = distanceSelection
            losevc.lossScore = metersWalked
        }
    }

    fileprivate func DrawInnerCircle(_ circularPath: UIBezierPath, drawingEndPoint:Double, circle: CAShapeLayer) {
        circle.path = circularPath.cgPath
        circle.strokeColor=UIColor.red.cgColor
        circle.lineWidth = 10
        circle.lineCap = CAShapeLayerLineCap.round
        circle.fillColor = UIColor.clear.cgColor
        let standardisedAngle = drawingEndPoint*0.8
        circle.strokeEnd = CGFloat(standardisedAngle)
    }

    func drawCircle(drawingEndPoint:Double, radius: CGFloat, circle: CAShapeLayer){
        let center = view.center

        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi, clockwise: true)
        trackLayer.path=circularPath.cgPath

        trackLayer.strokeColor=UIColor.lightGray.cgColor
        var drawingEndPoint2:Double
        if(drawingEndPoint == 5.00){
            trackLayer.strokeColor=UIColor.clear.cgColor
            drawingEndPoint2 = 0.00
        }else{
            drawingEndPoint2 = drawingEndPoint
        }
        trackLayer.lineWidth = 10

        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(trackLayer)

        DrawInnerCircle(circularPath, drawingEndPoint: drawingEndPoint2, circle: circle)
        view.layer.addSublayer(circle)
    }
}
