//
//  ProfileVC.swift
//  FitSpire
//
//  Created by Connor Clancy on 13/03/2019.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Charts
import Firebase
import FirebaseDatabase


class ProfileVC: UIViewController {
    var dict : [String : AnyObject]!

    //MARK: Properties

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var profilePicImageView: UIImageView!


    var months: [String]!
    var noOfGamesPlayedMonthwise: [Int]!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let noOfGamesPlayedMonthwise = [30,1,24,53,66,77,4,3,2,1,6,8]
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        barChartView.xAxis.granularity = 1
        setBarChart(dataPoints: months, values: noOfGamesPlayedMonthwise)
        // Do any additional setup after loading the view.
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)
        self.getFBUserData()
        let exercises = ["Walking", "Squats", "Push-ups", "Sit-ups"]
        let numberOfGamesPlayedInEachCategory = [20.0,5.0,5.0,8.0]

        setChart(dataPoints: exercises, values: numberOfGamesPlayedInEachCategory )

    }
    func setChart(dataPoints: [String], values: [Double]) {

        var dataEntries: [ChartDataEntry] = []

        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: Double(i), label: dataPoints[i], data:  dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }

        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "Units Sold")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.data = pieChartData

        var colors: [UIColor] = []

        for i in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))

            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }

        pieChartDataSet.colors = colors

    }
    func setBarChart(dataPoints: [String], values: [Int])
    {
        barChartView.noDataText = "No Game played yet to generate the data"
        var dataEntries: [BarChartDataEntry] = []

        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [Double(values[i])])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Games Played")
        let chartData = BarChartData(dataSet: chartDataSet)
        self.barChartView.data = chartData
        chartDataSet.stackLabels=months

        chartDataSet.colors = ChartColorTemplates.colorful()
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)


    }
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    print(result!)
                    var profileName = self.dict?["name"]
                    var profileId=self.dict?["id"]
                    var profilePicture = self.dict?["picture"]
                    var pictureURL = profilePicture?["url"]
                    self.nameTextField.text = profileName as? String
                    self.nameTextField.isUserInteractionEnabled = false
                    let url = NSURL(string: "https://graph.facebook.com/\(profileId!)/picture?type=large&return_ssl_resources=1")
                    self.profilePicImageView.image = UIImage(data: NSData(contentsOf: url! as URL)! as Data)
                    print(self.dict)
                    self.profilePicImageView.layer.borderWidth=1.0
                    self.profilePicImageView.layer.masksToBounds = false
                    self.profilePicImageView.layer.borderColor = UIColor.white.cgColor
                    self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.frame.size.height/2
                    self.profilePicImageView.clipsToBounds = true
                }
            })
        }
    }
}
