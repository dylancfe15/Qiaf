//
//  IOViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 10/30/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
class IOViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,GADBannerViewDelegate{
    
    @IBOutlet weak var myBanner: GADBannerView!
    @IBOutlet weak var addButtonOutlet: UIButton!

    @IBOutlet weak var IOTableView: UITableView!
    var IOItems = [NSManagedObject]()
    @IBOutlet weak var titleOfPage: UILabel!
    @IBOutlet weak var totalTitleOutlet: UILabel!
    @IBOutlet weak var totalAmountOutlet: UILabel!
    var segueIndex = 0
    let numberFormatter = NumberFormatter()
    
    //view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        IOTableView.backgroundColor = UIColor.clear
        var total: Int32 = 0
        
        if(segueIndex == 1){
            let request : NSFetchRequest<Income> = Income.fetchRequest()
            do{
                IOItems = try DatabaseController.getContext().fetch(request)
                for results in IOItems as! [Income]{
                    total = results.money + total
                }
            }catch{
                print("ERROR")
            }
        }else{
            let request : NSFetchRequest<Outcome> = Outcome.fetchRequest()
            do{
                IOItems = try DatabaseController.getContext().fetch(request)
                for results in IOItems as! [Outcome]{
                    total = results.money + total
                }
            }catch{
                print("ERROR")
            }
        }
        
        if(segueIndex == 1){
            titleOfPage.text = "Monthly incomes:"
            totalTitleOutlet.text = "Total incomes:"
            totalAmountOutlet.textColor = UIColor.green
        }else{
            titleOfPage.text = "Monthly outcomes:"
            totalTitleOutlet.text = "Total outcomes:"
            totalAmountOutlet.textColor = UIColor.red
        }
        totalAmountOutlet.text = "$ "+numberFormatter.string(from: NSNumber(value:total) )!
        //create keyboard tool bar
        let toolBar  = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        titleOfCellOutlet.inputAccessoryView = toolBar
        amountOfCellOutlet.inputAccessoryView = toolBar
        
        addButtonOutlet.layer.cornerRadius = 10
        
        //Banner
        let adRequest = GADRequest()
        adRequest.testDevices = [kGADSimulatorID]
        myBanner.adUnitID = "ca-app-pub-6779325502552778/7579109991"
        myBanner.rootViewController = self
        myBanner.delegate = self
        
        myBanner.load(adRequest)
    }
    
    @objc func doneClicked(){
        view.endEditing(true)
    }
    
    //add
    @IBOutlet weak var titleOfCellOutlet: UITextField!
    @IBOutlet weak var amountOfCellOutlet: UITextField!
    @IBAction func addToCellAction(_ sender: Any) {
        if(Int(amountOfCellOutlet.text!) == nil){
            let alert = UIAlertController(title: "Oops!", message: "Please enter a vaild integer into the amount!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }
        if(segueIndex == 1){
            if(titleOfCellOutlet.text != "" && amountOfCellOutlet.text != ""){
                let income : Income = NSEntityDescription.insertNewObject(forEntityName: "Income", into: DatabaseController.getContext()) as! Income
                income.title = titleOfCellOutlet.text
                income.money = Int32(amountOfCellOutlet.text!)!
                IOItems.append(income as NSManagedObject)
                DatabaseController.saveContext()
                titleOfCellOutlet.text = ""
                amountOfCellOutlet.text = ""
            }
        }else{
            if(titleOfCellOutlet.text != "" && amountOfCellOutlet.text != ""){
                let outcome : Outcome = NSEntityDescription.insertNewObject(forEntityName: "Outcome", into: DatabaseController.getContext()) as! Outcome
                outcome.title = titleOfCellOutlet.text
                outcome.money = Int32(amountOfCellOutlet.text!)!
                IOItems.append(outcome as NSManagedObject)
                DatabaseController.saveContext()
                titleOfCellOutlet.text = ""
                amountOfCellOutlet.text = ""
            }
        }
        loadView()
        viewDidLoad()
    }
    
    //cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IOItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IOCell") as! IOTableViewCell
        if(segueIndex == 1){
            let results = IOItems as! [Income]
            cell.title.text = results[indexPath.row].title
            cell.amount.text = "$ " + numberFormatter.string(from: NSNumber(value:results[indexPath.row].money))!
            cell.amount.textColor = UIColor.green
        }else{
            let results = IOItems as! [Outcome]
            cell.title.text = results[indexPath.row].title
            cell.amount.text = "$ " + numberFormatter.string(from: NSNumber(value:results[indexPath.row].money))!
            cell.amount.textColor = UIColor.red
        }
        //cell.backgroundImage.layer.cornerRadius = 10
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete){
            if(segueIndex == 1){
                let managedContext: NSManagedObjectContext = DatabaseController.getContext()
                let request:NSFetchRequest<Income> = Income.fetchRequest()
                
                do{
                    let results = try DatabaseController.getContext().fetch(request)
                    IOItems.remove(at: indexPath.row)
                    managedContext.delete(results[indexPath.row])
                    DatabaseController.saveContext()
                }catch {
                    print("ERROR")
                }
            }else{
                let managedContext: NSManagedObjectContext = DatabaseController.getContext()
                let request:NSFetchRequest<Outcome> = Outcome.fetchRequest()
                
                do{
                    let results = try DatabaseController.getContext().fetch(request)
                    IOItems.remove(at: indexPath.row)
                    managedContext.delete(results[indexPath.row])
                    DatabaseController.saveContext()
                }catch {
                    print("ERROR")
                }
            }
        }
        tableView.reloadData()
        viewDidLoad()
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
