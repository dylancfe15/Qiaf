//
//  iHavePlanViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 10/24/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData

class HavePlanViewController: UIViewController {
    
    @IBOutlet weak var goalTitleOutlet: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var durationOutlet: UILabel!
    @IBOutlet weak var savingMoneyText: UITextField!
    @IBOutlet weak var savingPeriodLabel: UILabel!
    @IBOutlet weak var expectedDateOutlet: UILabel!
    private var taskLab = String()
    var futureDate = Date()
    @IBAction func changeSavingMoneyAction(_ sender: Any) {
        if(Double(taskLab)! < Double(savingMoneyText.text!)!){
            savingMoneyText.text = String(Int(taskLab)!)
        }else if(Double(savingMoneyText.text!)! < 1.0){
            savingMoneyText.text = "1"
        }
        savingMoneySliderOutlet.value = Float(Double(Int(savingMoneyText.text!)!)/Double(Int(taskLab)!)*100)
        updateDate()
    }
    
    //frequancy
    @IBOutlet weak var savingFrequancyOutlet: UISegmentedControl!
    @IBAction func savingFrequancyAction(_ sender: Any) {
        updateDate()
    }
    
    //slider
    @IBOutlet weak var savingMoneySliderOutlet: UISlider!
    @IBAction func savingMoneySliderAction(_ sender: Any) {
        savingMoneyText.text = String(Int(Float(taskLab)!/100*savingMoneySliderOutlet.value))
        if(Int(savingMoneyText.text!)! < 1){
            savingMoneyText.text = "1"
        }
        updateDate()
    }
    
    //update the date
    func updateDate(){
        var days: Double = 0.0
        if(savingFrequancyOutlet.selectedSegmentIndex == 0){
            days = Double(taskLab)!/Double(savingMoneyText.text!)!
        }else if (savingFrequancyOutlet.selectedSegmentIndex == 1){
            days = Double(taskLab)!/Double(savingMoneyText.text!)!*7
        }else if (savingFrequancyOutlet.selectedSegmentIndex == 2){
            days = Double(taskLab)!/Double(savingMoneyText.text!)!*15
        }else {
            days = Double(taskLab)!/Double(savingMoneyText.text!)!*30
        }
        
        if(savingFrequancyOutlet.selectedSegmentIndex == 0){
            if(Int(Int(days)*Int(savingMoneyText.text!)!) < Int(taskLab)!){
                days = days + 1
            }
        }else if(savingFrequancyOutlet.selectedSegmentIndex == 1){
            if(Int(Int(days)*Int(savingMoneyText.text!)!) < Int(taskLab)!){
                days = days + 7
            }
        }else if(savingFrequancyOutlet.selectedSegmentIndex == 2){
            if(Int(Int(days)*Int(savingMoneyText.text!)!) < Int(taskLab)!){
                days = days + 15
            }
        }else{
            if(Int(Int(days)*Int(savingMoneyText.text!)!) < Int(taskLab)!){
                days = days + 30
            }
        }
        let currentDate = Date()
        let userCalendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.day = Int(days)
        futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        expectedDateOutlet.text = dateFormatter.string(from: futureDate)
        savingPeriodLabel.text = "/ " + savingFrequancyOutlet.titleForSegment(at: savingFrequancyOutlet.selectedSegmentIndex)!
        
        //get difference of dates
        let requestedComponent: Set<Calendar.Component> = [.year, .month, .day]
        let timeDifference = userCalendar.dateComponents(requestedComponent, from: currentDate, to: futureDate)
        if (timeDifference.year! > 0){
            durationOutlet.text = "\(timeDifference.year!)Y \(timeDifference.month!)M \(timeDifference.day!)D"
        }else if(timeDifference.month! > 0){
            durationOutlet.text = "\(timeDifference.month!)M \(timeDifference.day!)D"
        }else{
            durationOutlet.text = "\(timeDifference.day!)D"
        }
    }
    
    @IBAction func evaluationAction(_ sender: Any) {
        save()
    }
    
    //save data
    func save(){
        let ihaveplan : IHavePlan = NSEntityDescription.insertNewObject(forEntityName: "IHavePlan", into: DatabaseController.getContext()) as! IHavePlan
        
        ihaveplan.savingFrequancy = Int32(savingFrequancyOutlet.selectedSegmentIndex)
        ihaveplan.savingMoney = Int32(savingMoneyText.text!)!
        ihaveplan.targetDate = futureDate as NSDate
        
        DatabaseController.saveContext()
        
        viewDidLoad()
    }
    
    //load the view
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //number format
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        //request of GoalInfo
        let request:NSFetchRequest<GoalInfo> = GoalInfo.fetchRequest()
        do{
            let results = try DatabaseController.getContext().fetch(request)
            
            let resultsArray = results as [GoalInfo]
            goalTitleOutlet.text = "Goal: "+resultsArray[resultsArray.count-1].goalTitle!
            
            taskLabel.text = numberFormatter.string(from: NSNumber(value: resultsArray[resultsArray.count-1].goalTask))
            taskLab = (taskLabel.text?.replacingOccurrences(of: ",", with: ""))!
        }catch{
            print("ERROR")
        }
        
        //request of IHavePlan
        let requestHavePlan:NSFetchRequest<IHavePlan> = IHavePlan.fetchRequest()
        do{
            let results = try DatabaseController.getContext().fetch(requestHavePlan)
            
            let resultsArray = results as [IHavePlan]
            if(resultsArray.count>0){
                savingFrequancyOutlet.selectedSegmentIndex = Int(resultsArray[resultsArray.count-1].savingFrequancy)
                if(Int(taskLab)! < resultsArray[resultsArray.count-1].savingMoney){
                    savingMoneyText.text = String(Int(taskLab)!)
                }else{
                    savingMoneyText.text = String(resultsArray[resultsArray.count-1].savingMoney)
                }
                
            }else{
                savingMoneyText.text = String(Int(Float(taskLab)!/100*savingMoneySliderOutlet.value))
            }
        }catch{
            print("ERROR")
        }
        //update Slider
        savingMoneySliderOutlet.value = Float(Double(Int(savingMoneyText.text!)!)/Double(Int(taskLab)!)*100)
        updateDate()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
