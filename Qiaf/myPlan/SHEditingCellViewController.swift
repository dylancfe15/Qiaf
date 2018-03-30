//
//  SHEditingCellViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 11/15/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
class SHEditingCellViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {

    var date = String()
    var type = String()
    var amount = Int32()
    var note = String()
    var expectBal = Int32()
    var index = Int()
    var dateFormatter = DateFormatter()
    var dateComponent = DateComponents()
    let currentDate = Date()
    var typeArray = [String]()
    var dateArray = [String]()
    var pickerArray = [String]()
    var pressType = Bool()
    var pressDate = Bool()
    var savingHis : SavingHistory = NSEntityDescription.insertNewObject(forEntityName: "SavingHistory", into: DatabaseController.getContext()) as! SavingHistory
    var goalsArray = [Goals]()
    let goalsRequest:NSFetchRequest<Goals> = Goals.fetchRequest()
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var dateText: UITextField!
    @IBAction func dateButton(_ sender: Any) {
        pressDate = true
        pressType = false
        pickerArray = dateArray
        picker.reloadAllComponents()
        picker.isHidden = false
    }
    @IBOutlet weak var typeText: UITextField!
    @IBAction func tyepButton(_ sender: Any) {
        pressType = true
        pressDate = false
        pickerArray = typeArray
        picker.reloadAllComponents()
        picker.isHidden = false
    }
    @IBOutlet weak var amountOutlet: UITextField!
    @IBOutlet weak var noteOutlet: UITextField!
    @IBAction func saveButton(_ sender: Any) {
        savingHis.date = dateFormatter.date(from: dateText.text!)! as NSDate
        savingHis.money = Int32(amountOutlet.text!)!
        savingHis.type = typeText.text
        savingHis.note = noteOutlet.text
        goalsArray[index].addToSavingHistory(savingHis)
        DatabaseController.saveContext()
        performSegue(withIdentifier: "toSH", sender: self)
    }
    @IBAction func cancelButton(_ sender: Any) {
        savingHis.date = dateFormatter.date(from: date)! as NSDate
        savingHis.money = amount
        savingHis.type = type
        savingHis.note = note
        goalsArray[index].addToSavingHistory(savingHis)
        DatabaseController.saveContext()
        performSegue(withIdentifier: "toSH", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .medium
        
        typeArray = ["Completed","Failed","Withdrew","Contributed"]
        for i in 0...365{
            dateComponent.day = -i
            dateArray.append(dateFormatter.string(from: Calendar.current.date(byAdding: dateComponent, to: currentDate)!))
        }
        
        dateText.text = date
        typeText.text = type
        amountOutlet.text = String(amount)
        noteOutlet.text = note
        
        do{
            goalsArray = try DatabaseController.getContext().fetch(goalsRequest)
        }catch{
            
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let SHController = segue.destination as! SHViewController
        SHController.expectedBalance = expectBal
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pressType){
            typeText.text = typeArray[row]
        }
        if(pressDate){
            dateText.text = dateArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerArray[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        picker.isHidden = true
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
