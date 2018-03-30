//
//  askForPlanViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 10/29/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
class askForPlanViewController: UIViewController,UITextFieldDelegate, GADBannerViewDelegate {
    @IBOutlet weak var netincomeOutlet: UILabel!
    @IBOutlet weak var nextButtonOutlet: UIButton!
    @IBOutlet weak var monthlyIncomeOutlet: UIButton!
    @IBOutlet weak var monthlyOutcomeOutlet: UIButton!
    @IBOutlet weak var myBanner: GADBannerView!
    var numberForSegue = 0
    var netincome = Int32()
    
    //segue
    
    @IBAction func monthlyIncomeAction(_ sender: Any) {
        numberForSegue = 1
    }
    
    @IBAction func MonthlyOutcomeAction(_ sender: Any) {
        numberForSegue = 2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        if(segue.destination is IOViewController){
            let ioController = segue.destination as! IOViewController
            ioController.segueIndex = numberForSegue
        }
    }
    
    @IBOutlet weak var addOutcomeOutlet: UIButton!
    @IBOutlet weak var addIncomeOutlet: UIButton!
    //income
    @IBOutlet weak var incomeTitleOutlet: UITextField!
    @IBOutlet weak var incomeAmountOutlet: UITextField!
    @IBOutlet weak var incomeTotalOutlet: UILabel!
    @IBAction func addIncomeAction(_ sender: Any) {
        if(incomeAmountOutlet.text != ""){
            if(Int(incomeAmountOutlet.text!) == nil){
                let alert = UIAlertController(title: "Oops!", message: "Please enter a vaild integer to the amount!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                present(alert, animated: true, completion: nil)
            }else{
                let income : Income = NSEntityDescription.insertNewObject(forEntityName: "Income", into: DatabaseController.getContext()) as! Income
                income.title = incomeTitleOutlet.text
                income.money = Int32(incomeAmountOutlet.text!)!
                DatabaseController.saveContext()
                incomeTitleOutlet.text = ""
                incomeAmountOutlet.text = ""
                updateData()
            }
        }else{
            let alert = UIAlertController(title: "Oops!", message: "Please enter your INCOME infomation.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }
        
    }
    //outcome
    @IBOutlet weak var outcomeTitleOutlet: UITextField!
    @IBOutlet weak var outcomeAmountOutlet: UITextField!
    @IBOutlet weak var outcomeTotalOutlet: UILabel!
    @IBAction func addOutcomeAction(_ sender: Any) {
        
        if(outcomeAmountOutlet.text != ""){
            if(Int(outcomeAmountOutlet.text!) == nil){
                let alert = UIAlertController(title: "Oops!", message: "Please enter a vaild integer to the amount!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                present(alert, animated: true, completion: nil)
            }else{
                let outcome : Outcome = NSEntityDescription.insertNewObject(forEntityName: "Outcome", into: DatabaseController.getContext()) as! Outcome
                outcome.title = outcomeTitleOutlet.text
                outcome.money = Int32(outcomeAmountOutlet.text!)!
                DatabaseController.saveContext()
                outcomeTitleOutlet.text = ""
                outcomeAmountOutlet.text = ""
                updateData()
            }
        }else{
            let alert = UIAlertController(title: "Oops!", message: "Please enter your OUTCOME infomation.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBOutlet weak var taskLabelOutlet: UILabel!
    @IBOutlet weak var goalTitleOutlet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateData()
        
        //create keyboard tool bar
        let toolBar  = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        incomeTitleOutlet.inputAccessoryView = toolBar
        incomeAmountOutlet.inputAccessoryView = toolBar
        outcomeTitleOutlet.inputAccessoryView = toolBar
        outcomeAmountOutlet.inputAccessoryView = toolBar
        
        addIncomeOutlet.layer.cornerRadius = 10
        addOutcomeOutlet.layer.cornerRadius = 10
        nextButtonOutlet.layer.cornerRadius = 10
        
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
    
    func updateData(){
        var taskLab = String()
        var incomeTotal: Int32 = 0
        var outcomeTotal: Int32 = 0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        //request of GoalInfo
        let request:NSFetchRequest<GoalInfo> = GoalInfo.fetchRequest()
        do{
            let resultsArray = try DatabaseController.getContext().fetch(request)
            
            let results = resultsArray as [GoalInfo]
            goalTitleOutlet.text = results[results.count-1].goalTitle!
            
            taskLabelOutlet.text = "$ " + numberFormatter.string(from: NSNumber(value: results[results.count-1].goalTask))!
            taskLab = (taskLabelOutlet.text?.replacingOccurrences(of: ",", with: ""))!
        }catch{
            print("ERROR")
        }
        //loading income total
        let incomeRequest:NSFetchRequest<Income> = Income.fetchRequest()
        do{
            let resultsArray = try DatabaseController.getContext().fetch(incomeRequest)
            for results in resultsArray as [Income]{
                incomeTotal = results.money + incomeTotal
            }
            incomeTotalOutlet.text = "$ " + numberFormatter.string(from: NSNumber(value: incomeTotal))!
        }catch{
            print("ERROR")
        }
        //loading outcome total
        let outcomeRequest:NSFetchRequest<Outcome> = Outcome.fetchRequest()
        do{
            let resultsArray = try DatabaseController.getContext().fetch(outcomeRequest)
            for results in resultsArray as [Outcome]{
                outcomeTotal = results.money + outcomeTotal
            }
            outcomeTotalOutlet.text = "$ " + numberFormatter.string(from: NSNumber(value: outcomeTotal))!
        }catch{
            print("ERROR")
        }
        netincome = incomeTotal - outcomeTotal
        netincomeOutlet.text = "$ " + numberFormatter.string(from: NSNumber(value:netincome))!
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func NextButtonAction(_ sender: Any) {
        if(netincome <= 0){
            let alert = UIAlertController(title: "Oops!", message: "Your net income must be positive.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true,completion: nil)
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
