//
//  addExpensesViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 11/27/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
class addExpensesViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,GADBannerViewDelegate,UITextFieldDelegate{
    
    @IBOutlet weak var myBanner: GADBannerView!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var exTitle: UITextField!
    @IBOutlet weak var categries: UITextField!
    @IBOutlet weak var exDate: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var dateFormatter = DateFormatter()
    var numberFormatter = NumberFormatter()
    var today = Date()
    var categriesArray : [String] = ["Breakfast","Lunch","Dinner","Transportation","Drinks","Snacks","Insurances","Clothes","Games","Cosmetics","Credit Cards","Rent","Mobile fees","Electronic devices","Medications"]
    @IBAction func addButton(_ sender: Any) {
        if(Double(amount.text!) == nil ){
            let alert = UIAlertController(title: "Oops!", message: "Please enter a vaild number into the amount.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }else if(categries.text == ""){
            let alert = UIAlertController(title: "Oops!", message: "Please enter a category or select from below.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }else{
            let expenses : Expenses = NSEntityDescription.insertNewObject(forEntityName: "Expenses", into: DatabaseController.getContext()) as! Expenses
            expenses.title = exTitle.text
            expenses.amount = Double(amount.text!)!
            expenses.date = today as NSDate
            expenses.categry = categries.text
            DatabaseController.saveContext()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        exDate.text = dateFormatter.string(from: today)
        addButton.layer.cornerRadius = 10
        
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
        
        //create keyboard tool bar
        let toolBar  = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        exTitle.inputAccessoryView = toolBar
        amount.inputAccessoryView = toolBar
        categries.inputAccessoryView = toolBar
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
    
    //toolbar
    @objc func doneClicked(){
    view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categriesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exCell", for: indexPath) as! exCollectionViewCell
        cell.image.image = UIImage(named: categriesArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        categries.text = categriesArray[indexPath.row]
    }
    
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let TBController = segue.destination as! TabBarViewController
        TBController.tabBarIndex = 1
    }

}
