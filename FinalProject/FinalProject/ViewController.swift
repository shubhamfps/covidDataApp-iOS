//
//  ViewController.swift
//  FinalProject
//
//  Created by user186049 on 4/27/21.
//

import UIKit
import Charts
import CoreLocation

struct CovidData: Codable {
    var totalConfirmed: Int?
    var totalDeaths: Int?
    var totalRecovered: Int?
    var displayName: String?
    
    var totalDeathsDelta: Int?
    var totalRecoveredDelta: Int?
}


struct countryInfo : Decodable{
    
    var deaths : Double
    var recovered : Double
    var active : Double
    var critical : Double
    var cases : Double
    var _id : Double
    //var active: Double
}




class ViewController: UIViewController, ChartViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var nDeaths: UILabel!
    @IBOutlet weak var nrecovered: UILabel!
    @IBOutlet weak var nTotal: UILabel!
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var Deaths: UILabel!
    @IBOutlet weak var RecoveredLabel: UILabel!
    @IBOutlet weak var TotalLabel: UILabel!
    
    @IBOutlet weak var percentRecovered: UILabel!
    @IBOutlet weak var perentDeaths: UILabel!
    
    
     
    
   
    var dailyCases:[Double:Double] = [:]
    
    
    func fetchData(){
     
        
        
        let country = "USA"
        let url = "https://corona.lmao.ninja/v2/countries/\(country)?yesterday=false"
        let queryUrl = URL(string: url)
        print(queryUrl as Any)
        let task = URLSession.shared.dataTask(with: queryUrl!) {
            data, response, error in
        
            if error != nil || data == nil {
                print("Client Error")
                return
            }
            
            guard let response = response as?HTTPURLResponse,(200...299).contains(response.statusCode)
            else{
                print("server Error")
                return
            }
            guard let mime = response.mimeType,
                  mime == "application/json"
            else{
                print("Incorrect Mime Type")
                return
                
            }
            
            do{
                let json = try
                JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                print(json ?? "Error -No JSON recieved")
                
                let days = json?["daily"] as? [Any]
               /*let tZone = json?["timezone"] as? String
                for day in days! {
                    var cases = 0.0
                    let d = day as? [String:Any]
                    let dt = d!["dt"] as? Double
                    cases = d!["rain"] as? Double ?? 0.0
                    self.dailyCases[dt!] = cases
                
                }*/
                var z = -1
                let yVals = (self.dailyCases).map {(i)
                    -> BarChartDataEntry in
                    let val = i.value
                    z+=1
                    let b = BarChartDataEntry(x: Double(i.key),
                                              y: val)
                    return b
                }
                
                DispatchQueue.main.sync {
                    
        var set1: BarChartDataSet! = nil
                    
        if let set = self.chartView.data?.first as? BarChartDataSet{
            set1 = set
            set1.replaceEntries(yVals)
        }else{
            set1 = BarChartDataSet(entries: yVals, label: "Data set")
            set1.colors = ChartColorTemplates.colorful()
            set1.drawValuesEnabled = true
            set1.barBorderColor = .blue
            set1.barBorderWidth = 1
            let data = BarChartData(dataSet:set1)
            data.barWidth = Double(1)
            self.chartView.data = data
            self.chartView.fitBars = true
        }
        self.chartView.barData?.barWidth = 3600
        self.chartView.data?.notifyDataChanged()
        self.chartView.notifyDataSetChanged()
        self.chartView.setNeedsDisplay()
        
        }
            
            }catch{
                print("Error in JSON")
            }
        }
        task.resume()
    }
    
    func getData(filename fileName: String) -> Data? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                return data
            } catch {
                print("I can not read your file \(fileName).json")
                print(error)
            }
        }
        print("I can not read the file \(fileName).json")
        return nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let data = getData(filename: "covid_data") {
            do {
                // ***** This the data for covid 19 that you read from bing site url *****
                // Do whatever you like here
                
                print(data)
                
                // For example you can decode it:
                
                let jsonDecoder = JSONDecoder()
                let covidData = try jsonDecoder.decode(CovidData.self, from: data)
                let percentDeaths = covidData.totalConfirmed! / covidData.totalDeaths!
                let percentRecovered = covidData.totalConfirmed! / covidData.totalRecovered!
                print("percent deaths: \(percentDeaths)%")
                // I unwrap it without checking for nil :), you should check for nil!!
                print("Total Confirmed:\(covidData.totalConfirmed!)")
                print("Total Deaths:\(covidData.totalDeaths!)")
                print("Total Recovered:\(covidData.totalRecovered!)")
                self.TotalLabel.text = "\(covidData.totalConfirmed!)"
                self.RecoveredLabel.text = "\(covidData.totalRecovered!)"
                self.Deaths.text = "\(covidData.totalDeaths!)"
                self.percentRecovered.text = "\(percentRecovered)"
                self.perentDeaths.text = "\(percentDeaths)"
                self.nTotal.text = "\(covidData.totalConfirmed!)"
                self.nrecovered.text = "\(covidData.totalRecoveredDelta!)"
                self.nDeaths.text = "\(covidData.totalDeathsDelta!)"
            } catch {
                print("Cannot decode your data")
                print(error)
            }
            
            
        }
          
        
        fetchData()
        
        // Do any additional setup after loading the view.
        self.chartView.delegate = self
        self.chartView.chartDescription.enabled = true
        self.chartView.legend.enabled = true
        self.chartView.marker = MarkerImage()
        
      
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.granularity = 3600
        xAxis.labelCount = 10
        xAxis.valueFormatter = DateValueFormatter()
        xAxis.labelRotationAngle = -90
        xAxis.spaceMin = 3600
        xAxis.spaceMax = 3600
        xAxis.xOffset = 3600
        
        let yAxis = chartView.leftAxis
        yAxis.labelPosition = .outsideChart
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 40
        yAxis.valueFormatter = IntAxisValueFormatter()
        
        let rightAxis = chartView.rightAxis
        rightAxis.labelPosition = .outsideChart
        rightAxis.axisMinimum = 0
        rightAxis.axisMaximum = 40
        rightAxis.valueFormatter = IntAxisValueFormatter()
        
        
        
        
    
    
    }
    
    


}


    
    
   


