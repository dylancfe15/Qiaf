//
//  APChallengeViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 11/1/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
class APChallengeViewController: UIViewController ,UITextFieldDelegate, GADBannerViewDelegate{
    
    let numberFormatter = NumberFormatter()
    var dateFormatter = DateFormatter()
    var futureDate = Date()
    var task = Int32()
    var netIcome = Int32()
    var savingMoney = Int32()
    var currentDate = Date()
    let userCalendar = Calendar.current
    var dateComponent = DateComponents()
    var category = String()
    let Electronics:[String] = []
    let Sport:[String] = []
    let Car:[String] = []
    let House:[String] = []
    let Clothes:[String] = []
    let Game:[String] = []
    let Trip:[String] = []
    let College:[String] = []
    let Wedding:[String] = []
    let Loans:[String] = []
    var currentLocalizedDateString = String()
    var futureLocalizedDateString = String()
    
    @IBOutlet weak var myBanner: GADBannerView!
    @IBOutlet weak var acceptButtonOutlet: UIButton!
    @IBOutlet weak var totalGoalOutlet: UILabel!
    @IBOutlet weak var periodTextOutlet: UILabel!
    @IBOutlet weak var savingMoneyOutlet: UILabel!
    @IBOutlet weak var challengeLevelOutlet: UILabel!
    @IBOutlet weak var netincomeTextOutlet: UILabel!
    //textField
    @IBOutlet weak var contributionPersentageOutlet: UITextField!
    @IBAction func contributionPersentageAction(_ sender: Any) {
        if(Int(contributionPersentageOutlet.text!) == nil){
            let alert = UIAlertController(title: "Oops!", message: "Please enter a vaild integer to the contribution!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }else{
            if Float(contributionPersentageOutlet.text!)! >= 1 && Float(contributionPersentageOutlet.text!)! <= 100{
                contributionSliderOutlet.value = Float(contributionPersentageOutlet.text!)!
                updateSavingMoney()
                updateChallengeLevel()
                updateDate()
            }else{
                contributionPersentageOutlet.text = String(Int(contributionSliderOutlet.value))
                let alert = UIAlertController(title: "Warning!", message: "Please enter a number between 1 and 100.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    //slider
    @IBOutlet weak var contributionSliderOutlet: UISlider!
    @IBAction func contributionSliderAction(_ sender: Any) {
        updateSavingMoney()
        contributionPersentageOutlet.text = String(Int(contributionSliderOutlet.value))
        updateChallengeLevel()
        updateDate()
    }
    func updateSavingMoney(){
        if(savingPeriodSegmentOutlet.selectedSegmentIndex == 0){
            savingMoney = netIcome * Int32(contributionSliderOutlet.value)/100/30
        }else if(savingPeriodSegmentOutlet.selectedSegmentIndex == 1){
            savingMoney = netIcome * Int32(contributionSliderOutlet.value)/100/30*7
        }else if(savingPeriodSegmentOutlet.selectedSegmentIndex == 2){
            savingMoney = netIcome * Int32(contributionSliderOutlet.value)/100/30*15
        }else{
            savingMoney = netIcome * Int32(contributionSliderOutlet.value)/100
        }
        if(savingMoney<1){
            savingMoney = 1
        }
        savingMoneyOutlet.text = "$ " + numberFormatter.string(from: NSNumber(value:savingMoney))!
    }
    func updateChallengeLevel(){
        //change challenge level
        if(Int(contributionSliderOutlet.value)<=20){
            challengeLevelOutlet.text = "So easy!"
            challengeLevelOutlet.textColor = UIColor.green
        }else if(Int(contributionSliderOutlet.value)<=40){
            challengeLevelOutlet.text = "Easy!"
            challengeLevelOutlet.textColor = UIColor.green
        }else if(Int(contributionSliderOutlet.value)<=60){
            challengeLevelOutlet.text = "Medium!"
            challengeLevelOutlet.textColor = UIColor.orange
        }else if(Int(contributionSliderOutlet.value)<=80){
            challengeLevelOutlet.text = "Hard!"
            challengeLevelOutlet.textColor = UIColor.red
        }else{
            challengeLevelOutlet.text = "Hell!"
            challengeLevelOutlet.textColor = UIColor.red
        }
    }
    //period
    @IBOutlet weak var savingPeriodSegmentOutlet: UISegmentedControl!
    @IBAction func savingPeriodSegmentAction(_ sender: Any) {
        if(savingPeriodSegmentOutlet.selectedSegmentIndex == 0){
            savingMoney = netIcome * Int32(contributionSliderOutlet.value)/100/30
        }else if(savingPeriodSegmentOutlet.selectedSegmentIndex == 1){
            savingMoney = netIcome * Int32(contributionSliderOutlet.value)/100/30*7
        }else if(savingPeriodSegmentOutlet.selectedSegmentIndex == 2){
            savingMoney = netIcome * Int32(contributionSliderOutlet.value)/100/30*15
        }else{
            savingMoney = netIcome * Int32(contributionSliderOutlet.value)/100
        }
        if(savingMoney<1){
            savingMoney = 1
        }
        savingMoneyOutlet.text = "$ " + String(savingMoney)
        updateDate()
    }
    @IBOutlet weak var nextSavingDateOutlet: UILabel!
    @IBOutlet weak var finishedByDate: UILabel!
    @IBOutlet weak var durationOutlet: UILabel!
    
    //view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        //get task
        let goalRequest:NSFetchRequest<GoalInfo> = GoalInfo.fetchRequest()
        do{
            let resultsArray = try DatabaseController.getContext().fetch(goalRequest)
            let results = resultsArray as [GoalInfo]
            task = results[results.count-1].goalTask
        }catch{
            print("ERROR")
        }
        totalGoalOutlet.text = "$ " + numberFormatter.string(from: NSNumber(value:task))!
        
        //get net income
        let income:NSFetchRequest<Income> = Income.fetchRequest()
        var totalIncome: Int32 = 0
        do{
            let resultsArray = try DatabaseController.getContext().fetch(income)
            for results in resultsArray as [Income]{
                totalIncome = results.money + totalIncome
            }
        }catch{
            print("ERROR")
        }
        let outcome:NSFetchRequest<Outcome> = Outcome.fetchRequest()
        var totalOutcome: Int32 = 0
        do{
            let resultsArray = try DatabaseController.getContext().fetch(outcome)
            for results in resultsArray as [Outcome]{
                totalOutcome = results.money + totalOutcome
            }
        }catch{
            print("ERROR")
        }
        netIcome = totalIncome - totalOutcome
        netincomeTextOutlet.text = "$ " + numberFormatter.string(from: NSNumber(value:netIcome))!
        
        //set segment
        savingPeriodSegmentOutlet.selectedSegmentIndex = 3
        periodTextOutlet.text = "/ 30 Days"
        savingMoney = netIcome * Int32(contributionSliderOutlet.value)/100
        savingMoneyOutlet.text = "$ " + numberFormatter.string(from: NSNumber(value:savingMoney))!
        
        //challenge
        challengeLevelOutlet.textColor = UIColor.green
        updateDate()
        
        //create keyboard tool bar
        let toolBar  = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        contributionPersentageOutlet.inputAccessoryView = toolBar
        
        acceptButtonOutlet.layer.cornerRadius = 10
        
        //Banner
        let adRequest = GADRequest()
        adRequest.testDevices = [kGADSimulatorID]
        myBanner.adUnitID = "ca-app-pub-6779325502552778/7579109991"
        myBanner.rootViewController = self
        myBanner.delegate = self
        
        myBanner.load(adRequest)
        
        //move view with keyboard
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //move view
    @objc func keyboardDidShow(notification: Notification)  {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardY = self.view.frame.size.height - keyboardSize.height
        let editingTextFieldY: CGFloat! = self.activeTextField?.frame.origin.y
        
        if (self.view.frame.origin.y >= 0 ){
            if(editingTextFieldY > keyboardY - 130){
                UIView.animate(withDuration:0.25, delay: 0.0, options:UIViewAnimationOptions.curveEaseIn,animations:{
                    self.view.frame = CGRect(x:0,y:self.view.frame.origin.y - (editingTextFieldY! - (keyboardY - 130)),width:self.view.bounds.width,height:self.view.bounds.height)
                },completion: nil)
            }
        }
    }
    @objc func keyboardWillHide(notification: Notification)  {
        UIView.animate(withDuration:0.25, delay: 0.0, options:UIViewAnimationOptions.curveEaseIn,animations:{
            self.view.frame = CGRect(x:0,y:0,width:self.view.bounds.width,height:self.view.bounds.height)
        },completion: nil)
    }
    
    var activeTextField : UITextField!
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func doneClicked(){
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //update date
    func updateDate(){
        var days: Int = 0
        if(savingPeriodSegmentOutlet.selectedSegmentIndex == 0){
            days = Int(task)/Int(savingMoney)
            dateComponent.day = 1
        }else if (savingPeriodSegmentOutlet.selectedSegmentIndex == 1){
            days = Int(task)/Int(savingMoney)*7
            dateComponent.day = 7
        }else if (savingPeriodSegmentOutlet.selectedSegmentIndex == 2){
            days = Int(task)/Int(savingMoney)*15
            dateComponent.day = 15
        }else {
            days = Int(task)/Int(savingMoney)*30
            dateComponent.day = 30
        }
        nextSavingDateOutlet.text = dateFormatter.string(from: Calendar.current.date(byAdding: dateComponent, to: currentDate)!)
        if(savingPeriodSegmentOutlet.selectedSegmentIndex == 0){
            if(Int(Int(days)*Int(savingMoney)) < Int(task)){
                days = days + 1
            }
        }else if(savingPeriodSegmentOutlet.selectedSegmentIndex == 1){
            if(Int(Int(days)/7*Int(savingMoney)) < Int(task)){
                days = days + 7
            }
        }else if(savingPeriodSegmentOutlet.selectedSegmentIndex == 2){
            if(Int(Int(days)/15*Int(savingMoney)) < Int(task)){
                days = days + 15
            }
        }else{
            if(Int(Int(days)/30*Int(savingMoney)) < Int(task)){
                days = days + 30
            }
        }
        //get local current date
        currentLocalizedDateString = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        //get local future date
        futureLocalizedDateString = DateFormatter.localizedString(from: futureDate, dateStyle: .medium, timeStyle: .none)
        let current = dateFormatter.date(from: currentLocalizedDateString)!
        dateComponent.day = Int(days)
        var future = dateFormatter.date(from: futureLocalizedDateString)!
        future = Calendar.current.date(byAdding: dateComponent, to: current)!
        futureDate = future
        finishedByDate.text = dateFormatter.string(from: future)
        
        periodTextOutlet.text = "/ " + savingPeriodSegmentOutlet.titleForSegment(at: savingPeriodSegmentOutlet.selectedSegmentIndex)!
        
        //get difference of dates
        dateComponent.day = 1
        future = Calendar.current.date(byAdding: dateComponent, to:future)!
        let requestedComponent: Set<Calendar.Component> = [.year, .month, .day]
        var timeDifference = userCalendar.dateComponents(requestedComponent, from: current, to: future)
        
        if (timeDifference.year! > 0){
            durationOutlet.text = "\(timeDifference.year!)Y \(timeDifference.month!)M \(timeDifference.day!)D"
        }else if(timeDifference.month! > 0){
            durationOutlet.text = "\(timeDifference.month!)M \(timeDifference.day!)D"
        }else{
            durationOutlet.text = "\(timeDifference.day!)D"
        }
    }
    
    //accept challenge
    @IBAction func acceptChallengeAction(_ sender: Any) {
        if(Int(contributionPersentageOutlet.text!) == nil){
            let alert = UIAlertController(title: "Oops!", message: "Please enter a vaild integer to the contribution!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }else{
            currentLocalizedDateString = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
            futureLocalizedDateString = DateFormatter.localizedString(from: futureDate, dateStyle: .medium, timeStyle: .none)
            let goals:Goals = NSEntityDescription.insertNewObject(forEntityName: "Goals", into: DatabaseController.getContext()) as! Goals
            goals.moneyPerPeriod = savingMoney
            goals.period = Int16(savingPeriodSegmentOutlet.selectedSegmentIndex)
            goals.finishedDate = dateFormatter.date(from: futureLocalizedDateString)! as NSDate
            goals.startDate = dateFormatter.date(from: currentLocalizedDateString)! as NSDate
            
            let managedContext: NSManagedObjectContext = DatabaseController.getContext()
            //fetch GoalInfo
            let request: NSFetchRequest<GoalInfo> = GoalInfo.fetchRequest()
            do{
                let resultsArray = try DatabaseController.getContext().fetch(request)
                goals.title = resultsArray[resultsArray.count-1].goalTitle
                goals.task = resultsArray[resultsArray.count-1].goalTask
                goals.totalAmount = resultsArray[resultsArray.count-1].goalAmount
                goals.saving = savingMoney
                //check categories
                goals.category = checkCategories(title: resultsArray[resultsArray.count-1].goalTitle!, Electronics: Electronics, Sport: Sport, Car: Car, House: House, Clothes: Clothes, Game: Game, Trip: Trip, College: College, Wedding: Wedding, Loans: Loans)
                
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
        
    }
    
    func checkCategories(title: String,Electronics:[String],Sport:[String],Car:[String],House:[String],Clothes:[String],Game:[String],Trip:[String],College:[String],Wedding:[String],Loans:[String]) -> String {
        for E in Electronics{
            if((title.range(of: E)) != nil){
                return "Electronics"
            }
        }
        
        for S in Sport{
            if((title.range(of: S)) != nil){
                return "Sport"
            }
        }
        
        for C in Car{
            if((title.range(of: C)) != nil){
                return "Car"
            }
        }
        for H in House{
            if((title.range(of: H)) != nil){
                return "House"
            }
        }
        for C in Clothes{
            if((title.range(of: C)) != nil){
                return "Clothes"
            }
        }
        for G in Game{
            if((title.range(of: G)) != nil){
                return "Game"
            }
        }
        for T in Trip{
            if((title.range(of: T)) != nil){
                return "Trip"
            }
        }
        for C in College{
            if((title.range(of: C)) != nil){
                return "College"
            }
        }
        for W in Wedding{
            if((title.range(of: W)) != nil){
                return "Wedding"
            }
        }
        for L in Loans{
            if((title.range(of: L)) != nil){
                return "Loans"
            }
        }
        return "Other"
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
