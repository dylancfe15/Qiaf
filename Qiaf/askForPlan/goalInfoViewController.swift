//
//  goalInfoViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 10/24/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
class goalInfoViewController: UIViewController, UITextFieldDelegate,GADBannerViewDelegate,GADInterstitialDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var titlesCollectionView: UICollectionView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var savings: UITextField!
    @IBOutlet weak var myBanner: GADBannerView!
    
    let titles = ["House","Car","Computer","Cell Phone","Bike","Credit Card","Gift","Trip","Tuition","Clothes","Camera","Jewelry"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //titlesCollectionView.backgroundColor = UIColor.clear
        let request:NSFetchRequest<GoalInfo> = GoalInfo.fetchRequest()
        do{
            let results = try DatabaseController.getContext().fetch(request)
          
            let resultsArray = results as [GoalInfo]
            if(resultsArray.count>0){
                titleText.text = resultsArray[resultsArray.count-1].goalTitle
                amount.text = String(resultsArray[resultsArray.count-1].goalAmount)
                savings.text = String(resultsArray[resultsArray.count-1].goalSavings)
            }
        }catch{
            print("ERROR")
        }
        
        //create a tool bar
        let toolBar  = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        titleText.inputAccessoryView = toolBar
        amount.inputAccessoryView = toolBar
        savings.inputAccessoryView = toolBar
        
        NextButtonOutlet.layer.cornerRadius = 10
        
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
    
    @IBOutlet weak var NextButtonOutlet: UIButton!
    @IBAction func askForPlanAction(_ sender: Any) {
        if(savings.text == ""){
            savings.text = "0"
        }
        if(titleText.text == "" || amount.text == ""){
            let alert = UIAlertController(title: "Oops!", message: "Required information CAN'T be empty!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }else if(Int(amount.text!) == nil){
            let alert = UIAlertController(title: "Oops!", message: "Please enter a vaild integer to the amount!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }else if(Int(savings.text!) == nil){
            let alert = UIAlertController(title: "Oops!", message: "Please enter a vaild integer to 'How much you have?'!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }else{
            save()
        }
    }
    
    //press save
    func save() {
        
        let amountNum = Int32(amount.text!)
        let savingsNum = Int32(savings.text!)
        
        let goalinfo : GoalInfo = NSEntityDescription.insertNewObject(forEntityName: "GoalInfo", into: DatabaseController.getContext()) as! GoalInfo
        
        goalinfo.goalTitle = titleText.text
        goalinfo.goalAmount = amountNum!
        goalinfo.goalSavings = savingsNum!
        goalinfo.goalTask = amountNum! - savingsNum!
        
        DatabaseController.saveContext()
        
    }
    
    //collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "SFCell", for: indexPath) as! titlesCollectionViewCell
        cell.image.image = UIImage(named: titles[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        titleText.text = titles[indexPath.row]
    }
}
