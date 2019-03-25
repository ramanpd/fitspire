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
    
    var distanceOptions: [Int] = [Int]()
    var distanceSelection = 1
    var percentWalked = 0.00
    let shapeLayer = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        distanceOptions = [10, 200, 300, 500]
        self.DistanceChoice.delegate = self
        self.DistanceChoice.dataSource = self
    // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func onPress(_ sender: UIButton) {
        if(CMPedometer.isStepCountingAvailable() ){
            distanceSelection = distanceOptions[DistanceChoice.selectedRow(inComponent: 0)]
            
            //hide other labels etc
            DistanceChoice.removeFromSuperview()
            GoButton.isHidden=true
            beginCounting()
        }else{
            MeterCounter.text = "No Pedometer Found"
        }
    }
    
    private func beginCounting(){
        self.MeterCounter.text = "Meters: 0  Goal: \(distanceSelection)m"
        drawCircle(drawingEndPoint: 0.00)
        let savedDistanceGoal = distanceSelection
        let doubleDistance:Double = Double(distanceSelection) + 0.00
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            
            DispatchQueue.main.async {
                let metersWalked:Double = pedometerData.distance as! Double

                if((metersWalked/doubleDistance)>=1){
                    self?.MeterCounter.text = "Exercise Complete!"
                    self?.PercentLabel.text = ""
                    self?.drawCircle(drawingEndPoint: 5.00)
                    self?.pedometer.stopUpdates()
                }else{
                    self?.MeterCounter.text = "Meters: \(Int(metersWalked.rounded()))  Goal: \(savedDistanceGoal)m"
                    
                    self?.drawCircle(drawingEndPoint: metersWalked/doubleDistance)
                    let cleanPercentage = Int(((metersWalked/doubleDistance)*100).rounded())
                    self?.PercentLabel.text = "\(cleanPercentage)%"
                }
                
             
            }
        }
    }

    fileprivate func DrawInnerCircle(_ circularPath: UIBezierPath, drawingEndPoint:Double) {
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor=UIColor.red.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.fillColor = UIColor.clear.cgColor
        let standardisedAngle = drawingEndPoint*0.8
        shapeLayer.strokeEnd = CGFloat(standardisedAngle)
    }
    
    private func drawCircle(drawingEndPoint:Double){
        let center = view.center
        
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi, clockwise: true)
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
        
        DrawInnerCircle(circularPath, drawingEndPoint: drawingEndPoint2)
        view.layer.addSublayer(shapeLayer)
    }
    
    //this function is the action when it detects a tap
//    fileprivate func animateFunction() {
//        //stroke end means that as soon as you lift your finger from the tap, it initiates
//        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
//        basicAnimation.toValue = 1
//
//        basicAnimation.duration = 2
//        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
//        basicAnimation.isRemovedOnCompletion = false
//
//        shapeLayer.add(basicAnimation, forKey: "basic")
//    }
}
