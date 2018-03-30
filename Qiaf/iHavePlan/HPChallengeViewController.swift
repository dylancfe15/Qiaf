//
//  HPChallengeViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 10/29/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
class HPChallengeViewController: UIViewController {
    
    var resultsArray = [IHavePlan]()
    let currentDate = Date()
    @IBOutlet weak var savingMoneyOutlet: UILabel!
    @IBOutlet weak var savingPeriodOutlet: UILabel!
    @IBOutlet weak var finishDateOutlet: UILabel!
    @IBOutlet weak var nextSavingDateOutlet: UILabel!
    @IBAction func AcceptAction(_ sender: Any) {
        let goals:Goals = NSEntityDescription.insertNewObject(forEntityName: "Goals", into: DatabaseController.getContext()) as! Goals
        goals.moneyPerPeriod = resultsArray[resultsArray.count-1].savingMoney
        goals.period = Int16(resultsArray[resultsArray.count-1].savingFrequancy)
        goals.finishedDate = resultsArray[resultsArray.count-1].targetDate
        goals.startDate = currentDate as NSDate
        
        let managedContext: NSManagedObjectContext = DatabaseController.getContext()
        //fetch GoalInfo
        let request: NSFetchRequest<GoalInfo> = GoalInfo.fetchRequest()
        do{
            let resultsArray = try DatabaseController.getContext().fetch(request)
            goals.title = resultsArray[resultsArray.count-1].goalTitle
            goals.task = resultsArray[resultsArray.count-1].goalTask
            goals.totalAmount = resultsArray[resultsArray.count-1].goalAmount
            goals.saving = resultsArray[resultsArray.count-1].goalSavings
            //delete GoalInfo
            for results in resultsArray as [GoalInfo]{
                managedContext.delete(results)
            }
        }catch{
            print("ERROR")
        }
        let IHRequest:NSFetchRequest<IHavePlan> = IHavePlan.fetchRequest()
        do{
            let resultsArray = try DatabaseController.getContext().fetch(IHRequest)
            for results in resultsArray as [IHavePlan]{
                managedContext.delete(results)
            }
        }catch{
            print("ERROR")
        }
        DatabaseController.saveContext()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var dateComponent = DateComponents()
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let iHavePlanRequest: NSFetchRequest<IHavePlan> = IHavePlan.fetchRequest()
        
        //fetch data
        do{
            resultsArray = try DatabaseController.getContext().fetch(iHavePlanRequest)
            let results = resultsArray as [IHavePlan]
            savingMoneyOutlet.text = "$ "+numberFormatter.string(from: NSNumber(value:results[results.count-1].savingMoney))!
            if(results[results.count-1].savingFrequancy==0){
                savingPeriodOutlet.text = "/ 1 Day"
                dateComponent.day = 1
            }else if(results[results.count-1].savingFrequancy==1){
                savingPeriodOutlet.text = "/ 7 Days"
                dateComponent.day = 7
            }else if(results[results.count-1].savingFrequancy==2){
                savingPeriodOutlet.text = "/ 15 Days"
                dateComponent.day = 15
            }else{
                savingPeriodOutlet.text = "/ 30 Days"
                dateComponent.day = 30
            }
            finishDateOutlet.text = dateFormatter.string(from: results[results.count-1].targetDate! as Date)
            let futureDate = Calendar.current.date(byAdding: dateComponent, to: Date())
            nextSavingDateOutlet.text = dateFormatter.string(from: futureDate!)
        }catch{
            print("ERROR")
        }
        
        
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
