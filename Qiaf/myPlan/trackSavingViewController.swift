//
//  trackSavingViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 11/2/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import UserNotifications
class trackSavingViewController: UIViewController,UITextFieldDelegate, GADBannerViewDelegate {

    var indexCell = Int()
    var EXBalance: Int32 = 0
    var completionPersentage = Double()
    @IBOutlet weak var completedPerstgOutlet: UILabel!
    @IBOutlet weak var completedNumOutlet: UILabel!
    @IBOutlet weak var CommonOutlet: UILabel!
    @IBOutlet weak var titleOutlet: UILabel!
    @IBOutlet weak var SavingPerPeroidOutlet: UILabel!
    @IBOutlet weak var nextDateOutlet: UILabel!
    @IBOutlet weak var remainingDateOutlet: UILabel!
    @IBOutlet weak var targetDateOutlet: UILabel!
    @IBOutlet weak var failedOutlet: UIButton!
    @IBOutlet weak var failButtonOutlet: UIButton!
    @IBOutlet weak var completedButtonOutlet: UIButton!
    @IBOutlet weak var historyButtonOutlet: UIButton!
    @IBOutlet weak var withdrawButtonOutlet: UIButton!
    @IBOutlet weak var contributeButtonOutlet: UIButton!
    @IBOutlet weak var completeImage: UIImageView!
    @IBOutlet weak var myBanner: GADBannerView!
    
    //failed
    @IBOutlet weak var WDandConText: UITextField!
    @IBAction func failedAction(_ sender: Any) {
        if(checkingAlert()){
            AlertOfAdding(str: "Failed")
        }
    }
    @IBOutlet weak var completedOutlet: UIButton!
    //completed
    @IBAction func completedAction(_ sender: Any) {
        if(checkingAlert()){
            saveToHistory(str: "Completed", num: self.saving,notes: "")
        }
    }
    
    //withdraw
    @IBOutlet weak var withdrawOutlet: UIButton!
    @IBAction func withdrawAction(_ sender: Any) {
        if(WDandConText.text != "" ){
            if(Int(WDandConText.text!) == nil){
                let alert = UIAlertController(title: "Oops!", message: "Please enter a vaild integer!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                present(alert, animated: true, completion: nil)
            }
            AlertOfAdding(str: "Withdraw")
        }
        
    }
    @IBOutlet weak var contributedOutlet: UIButton!
    @IBAction func contributedAction(_ sender: Any) {
        if(WDandConText.text != "" && completionPersentage < 100.0){
            if(Int(WDandConText.text!) == nil){
                let alert = UIAlertController(title: "Oops!", message: "Please enter a vaild integer!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                present(alert, animated: true, completion: nil)
            }
            AlertOfAdding(str: "Contributed")
        }
        
    }
    
    let savinghistory: SavingHistory = NSEntityDescription.insertNewObject(forEntityName: "SavingHistory", into: DatabaseController.getContext()) as! SavingHistory
    var goalsArray = [Goals]()
    var savingHistory = [SavingHistory]()
    var totalHis = Int32()
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    var evaluationScore = 1.0
    var currentDate = Date()
    let userCalendar = Calendar.current
    var datecomponent = DateComponents()
    var requestedComponent: Set<Calendar.Component> = [.year,.month,.day]
    var isPress = Bool()
    var futureDay = Date()
    var differeces = Int()
    var saving = Int32()
    var timeDifferences = DateComponents()
    let requestGoal:NSFetchRequest<Goals> = Goals.fetchRequest()
    var period = Int()
    var currentLocalizedDateString = String()
    var futureLocalizedDateString = String()
    
    //view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .medium
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        //get local current date
        currentLocalizedDateString = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        //get local future date
        futureLocalizedDateString = DateFormatter.localizedString(from: futureDay, dateStyle: .medium, timeStyle: .none)
        let current = dateFormatter.date(from: currentLocalizedDateString)!
        var future = dateFormatter.date(from: futureLocalizedDateString)!
        
        //edit button
        failButtonOutlet.layer.cornerRadius = 10
        completedButtonOutlet.layer.cornerRadius = 10
        historyButtonOutlet.layer.cornerRadius = 10
        withdrawButtonOutlet.layer.cornerRadius = 10
        contributeButtonOutlet.layer.cornerRadius = 10
        
        //fetch
        do{
            goalsArray = try DatabaseController.getContext().fetch(requestGoal) as [Goals]
        }catch{
            print("ERROR")
        }
        titleOutlet.text = goalsArray[indexCell].title
        period = Int(goalsArray[indexCell].period)
        if(period == 0){
            period = 1
        }else if(period == 1){
            period = 7
        }else if(period == 2){
            period = 15
        }else{
            period = 30
        }
        //targetDate
        targetDateOutlet.text = dateFormatter.string(from: goalsArray[indexCell].finishedDate! as Date)
        
        timeDifferences = userCalendar.dateComponents(requestedComponent, from: current , to: goalsArray[indexCell].finishedDate! as Date)
        if(timeDifferences.year! > 0){
            remainingDateOutlet.text = String("\(timeDifferences.year!)Y \(timeDifferences.month!)M \(timeDifferences.day!)D")
        }else if(timeDifferences.month! > 0){
            remainingDateOutlet.text = "\(timeDifferences.month!)M \(timeDifferences.day!)D"
        }else{
            remainingDateOutlet.text = "\(timeDifferences.day!)D"
        }
        
        //next
        future = goalsArray[indexCell].startDate! as Date
        
        datecomponent.day = period
        
        while future <= current  {
            future = Calendar.current.date(byAdding: self.datecomponent, to: future)!
        }
        nextDateOutlet.text = dateFormatter.string(from: future)
        
        //get days differences
        timeDifferences = userCalendar.dateComponents(requestedComponent, from: goalsArray[indexCell].startDate! as Date, to: current)
        differeces = timeDifferences.day!
        
        //saving
        checkingAlert()
        viewDidChange()
        
        //create keyboard tool bar
        let toolBar  = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        WDandConText.inputAccessoryView = toolBar
        
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
        /*
        //notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
        })
        let content  = UNMutableNotificationContent()
        content.title = titleOutlet.text!
        content.subtitle = "Period ends " + dateFormatter.string(from: future)
        content.body = "You still have an uncompleted task of " + SavingPerPeroidOutlet.text!
        content.badge = 0
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7, repeats: false)
        let Nrequest = UNNotificationRequest(identifier:"timerDone", content: content, trigger:trigger)
        UNUserNotificationCenter.current().add(Nrequest, withCompletionHandler: nil)
 */
    }
    
    //move view
    @objc func keyboardDidShow(notification: Notification)  {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardY = self.view.frame.size.height - keyboardSize.height
        let editingTextFieldY: CGFloat! = self.activeTextField?.frame.origin.y
        
        if (self.view.frame.origin.y >= 0 ){
            if(editingTextFieldY != nil){
                if(editingTextFieldY > keyboardY - 130){
                    UIView.animate(withDuration:0.25, delay: 0.0, options:UIViewAnimationOptions.curveEaseIn,animations:{
                        self.view.frame = CGRect(x:0,y:self.view.frame.origin.y - (editingTextFieldY! - (keyboardY - 130)),width:self.view.bounds.width,height:self.view.bounds.height)
                    },completion: nil)
                }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.destination is SHViewController){
            let hisController = segue.destination as! SHViewController
            hisController.index = indexCell
            hisController.expectedBalance = EXBalance
        }
    }
    func isDateBetween(Date checkDate:Date, Date startdate:Date, Date enddate:Date) -> Bool {
        if(checkDate >= startdate && checkDate < enddate){
            return true
        }else{
            return false
        }
    }
    
    func AlertOfAdding(str: String){
        
        if(str == "Failed"){
            let alert = UIAlertController(title: str, message: "I'm so sorry to hear that you can't complete the Current Task, but how much you have so far :(", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField(configurationHandler: { (textField) -> Void  in
                textField.placeholder = "Ex. 120"
                textField.keyboardType = UIKeyboardType.numberPad
            })
            alert.addTextField(configurationHandler: { (textField) -> Void  in
                textField.placeholder = "Notes."
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: { (action) in
                if(Int32(alert.textFields!.first!.text!)! < self.saving){
                    let failedAlert = UIAlertController(title: str, message: "You are now saving $" + alert.textFields!.first!.text! + " to your goal.", preferredStyle: UIAlertControllerStyle.alert)
                    failedAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    failedAlert.addAction(UIAlertAction(title: "Comfirm", style: UIAlertActionStyle.default, handler: { (action) in
                        self.saveToHistory(str: str, num: Int32(alert.textFields!.first!.text!)!,notes: alert.textFields!.last!.text!)
                    }))
                    self.present(failedAlert, animated: true,completion: nil)
                }else{
                    let failedAlert = UIAlertController(title: str, message: "Hi! $" + alert.textFields!.first!.text! + " is more enough to complete the current task. You should click COMPLETE or CONTRIBUTE ;)", preferredStyle: UIAlertControllerStyle.alert)
                    failedAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(failedAlert, animated: true,completion: nil)
                }
               
            }))
            self.present(alert, animated: true,completion: nil)
        }else if (str == "Withdraw"){
            let alert = UIAlertController(title: str, message: "You are now withdrawing $" + WDandConText.text! + " from your goal.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField(configurationHandler: { (textField) -> Void  in
                textField.placeholder = "Notes."
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Comfirm", style: UIAlertActionStyle.default, handler: { (action) in
                self.saveToHistory(str: str, num: Int32(self.WDandConText.text!)!,notes: alert.textFields!.first!.text!)
            }))
            self.present(alert, animated: true,completion: nil)
        }else{
            let alert = UIAlertController(title: str, message: "You are now saving $" + WDandConText.text! + " to your goal.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField(configurationHandler: { (textField) -> Void  in
                textField.placeholder = "Notes."
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Comfirm", style: UIAlertActionStyle.default, handler: { (action) in
                self.saveToHistory(str: str, num: Int32(self.WDandConText.text!)!,notes: alert.textFields!.first!.text!)
            }))
            self.present(alert, animated: true,completion: nil)
        }
        
    }
    //save to history
    func saveToHistory(str: String, num:Int32, notes: String){
        let current = dateFormatter.date(from: currentLocalizedDateString)!
        var future = dateFormatter.date(from: futureLocalizedDateString)!
        
        self.savinghistory.type = str
        if(str == "Withdraw"){
            self.savinghistory.money = 0 - num
        }else{
            self.savinghistory.money = num
        }
        self.savinghistory.date = current as NSDate
        self.savinghistory.note = notes
        self.goalsArray[self.indexCell].addToSavingHistory(self.savinghistory)
        if(str == "Withdraw"){
            self.saving = saving + num
        }else{
            self.saving = saving - num
        }
        DatabaseController.saveContext()
        self.viewDidChange()
        performSegue(withIdentifier: "SHSegue", sender: self)
    }
    
    //update data
    func viewDidChange(){
        totalHis = 0
        savingHistory = (goalsArray[indexCell].savingHistory?.allObjects)! as! [SavingHistory]
        for results in savingHistory{
            totalHis = totalHis + results.money
        }
        completedNumOutlet.text = "$"+String(totalHis) + " / $" + numberFormatter.string(from: NSNumber(value:goalsArray[indexCell].task))!
        
        completionPersentage = Double(totalHis)/Double(goalsArray[indexCell].task)*100
        completedPerstgOutlet.text = String(format: "%.2f", completionPersentage) + "%"
        
        WDandConText.text = ""
        
        //get scores
        if(differeces % period == 0){
            EXBalance = (Int32(differeces / period)+1)*goalsArray[indexCell].saving
            evaluationScore = Double(totalHis) / Double(EXBalance)
        }
        
        //get status
        if(evaluationScore > 1.3){
            CommonOutlet.text = "Status: Probably accomplish before scheduled O(∩_∩)O"
        }else if(evaluationScore >= 1.0){
            CommonOutlet.text = "Status: Will accomplish as scheduled (*^__^*) "
        }else if(evaluationScore >= 0.8){
            CommonOutlet.text = "Status: Work a little bit harder :)"
        }else if(evaluationScore >= 0.5){
            CommonOutlet.text = "Status: Need to work very hard :("
        }else{
            CommonOutlet.text = "Status: Far behind /(ㄒoㄒ)/"
        }
        
        if(completionPersentage >= 100.0){
            saving = 0
            withdrawOutlet.backgroundColor = UIColor.gray
            withdrawOutlet.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
            contributedOutlet.backgroundColor = UIColor.gray
            contributedOutlet.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
            CommonOutlet.text = "Status: Congrats!!! You have achinved your goal! O(∩_∩)O"
        }
        if(saving <= 0){
            SavingPerPeroidOutlet.text = "$ 0"
            SavingPerPeroidOutlet.isHidden = true
            completeImage.isHidden = false
        }else{
            SavingPerPeroidOutlet.text = "$ "+String(saving)
        }
        
        //button color
        if (SavingPerPeroidOutlet.text == "$ 0"){
            failedOutlet.backgroundColor = UIColor.gray
            completedOutlet.backgroundColor = UIColor.lightGray
        }else{
            failedOutlet.backgroundColor = UIColor(red: 10, green: 0, blue: 0, alpha: 0.5)
            completedOutlet.backgroundColor = UIColor(displayP3Red: 0, green: 100, blue: 0, alpha: 0.75)
        }
    }
    
    //checking to create alert
    func checkingAlert() -> Bool{
        let current = dateFormatter.date(from: currentLocalizedDateString)!
        var future = dateFormatter.date(from: futureLocalizedDateString)!
        var tempDate = goalsArray[indexCell].startDate! as Date
        var totalOfDate : Int32 = 0
        var periodPast = 0
        
        periodPast = timeDifferences.day!/datecomponent.day!
        if(timeDifferences.day!%datecomponent.day! > 0 ){
            periodPast = periodPast + 1
        }
        savingHistory = goalsArray[indexCell].savingHistory?.allObjects as! [SavingHistory]
        
        if(savingHistory.count > 0){
            for i in 0..<periodPast{
                if(isDateBetween(Date: current, Date: tempDate, Date: Calendar.current.date(byAdding: datecomponent, to: tempDate)!)){
                    break
                }else{
                    tempDate = Calendar.current.date(byAdding: datecomponent, to: tempDate)!
                }
            }
            
            for SavingHis in savingHistory{
                if(isDateBetween(Date: SavingHis.date! as Date, Date: tempDate, Date: Calendar.current.date(byAdding: datecomponent, to: tempDate)!)){
                    totalOfDate = totalOfDate + SavingHis.money
                }
            }
        }
        
        if(totalOfDate < goalsArray[indexCell].saving){
            saving = goalsArray[indexCell].saving - totalOfDate
            return true
        }else{
            saving = 0
            return false
        }
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
