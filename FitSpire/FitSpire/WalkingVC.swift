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
    var opponentScore:Int = 0
    var distanceOptions: [Int] = [Int]()
    var distanceSelection = 1
    var percentWalked = 0.00

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
                let metersWalked:Double = pedometerData.distance as! Double
                
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
                    self!.ref.child("games/\(self!.currentCreatedGameID!)/player1Score").setValue(metersWalked)
                    self!.Player1ScoreLabel.text = "\(metersWalked)"
                    print("COMPLETED UPDATE^^")

                }else if(self!.currentPlayer==2){
                    print(self!.currentCreatedGameID!)
                    print("HERE IS THE GAME ID ^^^^^^^")
                    self!.ref.child("games/\(self!.currentCreatedGameID!)/player2Score").setValue(metersWalked)
                    self!.Player2ScoreLabel.text = "\(metersWalked)"
                    print("COMPLETED UPDATE^^")


                }else{
                    print("CurrentPlayer not found")
                }
                
                //PULL OPPONENT METERSWALKED FROM FIREBASE
                if(self!.currentPlayer==1){
                    Database.database().reference().child("games/\(self!.currentCreatedGameID!)").observeSingleEvent(of: .value, with: {DataSnapshot in
                         let dictionary = DataSnapshot.value as? [String: AnyObject]
                        self!.opponentScore = dictionary!["player2Score"] as! Int
                        self!.Player2ScoreLabel.text = "\(self!.opponentScore)"

                    })
                }else if(self!.currentPlayer==2){
                    //pull player 1
                    Database.database().reference().child("games/\(self!.currentCreatedGameID!)").observeSingleEvent(of: .value, with: {DataSnapshot in
                        let dictionary = DataSnapshot.value as? [String: AnyObject]
                        self!.opponentScore = dictionary!["player1Score"] as! Int
                        self!.Player1ScoreLabel.text = "\(self!.opponentScore)"

                    })
                }
                
                
                let opponent_progress = Double((self?.opponentScore)!)
                
                //UPDATE OPPONENT SCORE
                
                if((metersWalked/doubleDistance)>=1){
                    self?.MeterCounter.text = "Exercise Complete!"
                    self?.PercentLabel.text = "100%"
                    self?.drawCircle(drawingEndPoint: 1.00, radius: 120, circle: (self?.shapeLayerP1)!)
                    self?.pedometer.stopUpdates()
                    /*
                    if(!(self?.winnerDeclared)! && self?.isSingleplayer == false){  //Multiplayer
                        self?.winnerDeclared = true
                        //send declaration to database
                        print("player 1 wins")
                        self?.MeterCounter.text = "You Win!"
                     }*/
                    
                }else{
                    self?.MeterCounter.text = "Meters: \(Int(metersWalked.rounded()))  Goal: \(savedDistanceGoal)m"

                    self?.drawCircle(drawingEndPoint: metersWalked/doubleDistance, radius: 120, circle: (self?.shapeLayerP1)!)
                    let cleanPercentage = Int(((metersWalked/doubleDistance)*100).rounded())
                    self?.PercentLabel.text = "\(cleanPercentage)%"
                }


                if(!(self?.isSingleplayer)!){   //Multiplayer
                    //count up opponests circle
                    //opponent_progress to be updated by listener to database
                    self?.drawCircle(drawingEndPoint: opponent_progress, radius: 90, circle: (self?.shapeLayerP2)!)
                    if(opponent_progress >= 1 && !(self?.winnerDeclared)!){
                        self?.winnerDeclared = true
                        //send declaration to database
                        print("player 2 wins")
                        self!.MeterCounter.text = "player 2 wins"
                    }
                }
            }
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
