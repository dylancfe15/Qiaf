//
//  expensesViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 11/28/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
class expensesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate{
    
    @IBOutlet weak var myBanner: GADBannerView!
    @IBOutlet weak var monthOutlet: UILabel!
    @IBOutlet weak var monthMoneyOutlet: UILabel!
    @IBOutlet weak var lastMonthMoneyOutlet: UILabel!
    @IBOutlet weak var nextMonthMoneyOutlet: UILabel!
    @IBOutlet weak var DayOutlet: UILabel!
    @IBOutlet weak var dayMoneyOutlet: UILabel!
    @IBOutlet weak var lastDayMoneyOutlet: UILabel!
    @IBOutlet weak var nextDayMoneyOutlet: UILabel!
    @IBOutlet weak var EXTableview: UITableView!
    @IBOutlet weak var totalOutlet: UILabel!
    @IBAction func fresh(_ sender: Any) {
        today = Date()
        updateData()
        EXTableview.reloadData()
    }
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var noExpensesOutlet: UILabel!
    
    var expensesToday = [Expenses]()
    var expensesLastDay = [Expenses]()
    var expensesNextDay = [Expenses]()
    var expensesThisMonth = [Expenses]()
    var expensesLastMonth = [Expenses]()
    var expensesNextMonth = [Expenses]()
    var allExpense = [Expenses]()
    let requestExpense:NSFetchRequest<Expenses> = Expenses.fetchRequest()
    var today = Date()
    var todayLocalizedDateString = String()
    var dateFormatter = DateFormatter()
    var displayDateFormatter = DateFormatter()
    var monthDateComponents = DateComponents()
    var dayDateComponents = DateComponents()
    let calendar = Calendar.current
    
    
    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = DateFormatter.Style.short
        displayDateFormatter.dateFormat = "MMMM YY"
        EXTableview.backgroundColor = UIColor.clear
        addButton.layer.cornerRadius = 10
        
        //fetch
        do{
            allExpense = try DatabaseController.getContext().fetch(requestExpense)
        }catch{
            print("ERROR")
        }
        if(allExpense.count > 0){
            today = allExpense[allExpense.count-1].date! as Date
        }
        updateData()
        
        //Banner
        let adRequest = GADRequest()
        adRequest.testDevices = [kGADSimulatorID]
        myBanner.adUnitID = "ca-app-pub-6779325502552778/7579109991"
        myBanner.rootViewController = self
        myBanner.delegate = self
        
        myBanner.load(adRequest)
    }
    
    func updateData(){
        expensesToday = []
        expensesLastDay = []
        expensesNextDay = []
        expensesThisMonth = []
        expensesLastMonth = []
        expensesNextMonth = []
        do{
            allExpense = try DatabaseController.getContext().fetch(requestExpense)
        }catch{
            print("ERROR")
        }
        todayLocalizedDateString = DateFormatter.localizedString(from: today, dateStyle: .short, timeStyle: .none)
        let current = dateFormatter.date(from: todayLocalizedDateString)!
        
        if(allExpense.count > 0){
            EXTableview.isHidden = false
            noExpensesOutlet.isHidden = true
            
            for result in allExpense{
                //today
                if(dateFormatter.string(from: result.date! as Date) == dateFormatter.string(from: current)){
                    expensesToday += [result]
                }
                //lastDay
                dayDateComponents.day = -1
                if(dateFormatter.string(from: result.date! as Date) == dateFormatter.string(from: calendar.date(byAdding: dayDateComponents, to: current)!)){
                    expensesLastDay += [result]
                }
                //nextDay
                dayDateComponents.day = 1
                if(dateFormatter.string(from: result.date! as Date) == dateFormatter.string(from: calendar.date(byAdding: dayDateComponents, to: current)!)){
                    expensesNextDay += [result]
                }
                //month
                if(displayDateFormatter.string(from: result.date! as Date) == displayDateFormatter.string(from: current)){
                    expensesThisMonth += [result]
                }
                monthDateComponents.month = -1
                if(displayDateFormatter.string(from: result.date! as Date) == displayDateFormatter.string(from: calendar.date(byAdding: monthDateComponents, to: current)!)){
                    expensesLastMonth += [result]
                }
                monthDateComponents.month = 1
                if(displayDateFormatter.string(from: result.date! as Date) == displayDateFormatter.string(from: calendar.date(byAdding: monthDateComponents, to: current)!)){
                    expensesNextMonth += [result]
                }
            }
        }else{
            EXTableview.isHidden = true
            noExpensesOutlet.isHidden = false
        }
        
        //display
        var tempNum = Double()
        monthOutlet.text = displayDateFormatter.string(from: current)
        DayOutlet.text = String(calendar.component(.day, from: current))
        //todaymoney
        for result in expensesToday{
            tempNum += result.amount
        }
        dayMoneyOutlet.text = "$"+String(format: "%.2f",tempNum)
        totalOutlet.text = dayMoneyOutlet.text
        //lastday money
        tempNum = 0
        for result in expensesLastDay{
            tempNum += result.amount
        }
        lastDayMoneyOutlet.text = "$"+String(format: "%.2f",tempNum)
        //next day money
        tempNum = 0
        for result in expensesNextDay{
            tempNum += result.amount
        }
        nextDayMoneyOutlet.text = "$"+String(format: "%.2f",tempNum)
        //this month money
        tempNum = 0
        for result in expensesThisMonth{
            tempNum += result.amount
        }
        monthMoneyOutlet.text = "$"+String(format: "%.2f",tempNum)
        //last month money
        tempNum = 0
        for result in expensesLastMonth{
            tempNum += result.amount
        }
        lastMonthMoneyOutlet.text = "$"+String(format: "%.2f",tempNum)
        //next month money
        tempNum = 0
        for result in expensesNextMonth{
            tempNum += result.amount
        }
        nextMonthMoneyOutlet.text = "$"+String(format: "%.2f",tempNum)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expensesToday.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        let cell = tableView.dequeueReusableCell(withIdentifier: "exTableCell", for: indexPath) as! exTableViewCell
        cell.amount.text = "$ "+String(format:"%.2f",expensesToday[indexPath.row].amount)
        cell.note.text = expensesToday[indexPath.row].title
        cell.time.text = timeFormatter.string(from: expensesToday[indexPath.row].date! as Date)
        cell.Categries.text = expensesToday[indexPath.row].categry
        cell.backgroundColor = UIColor.clear
        cell.backgroundImage.layer.cornerRadius = 10
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    //Buttons
    @IBAction func addMonthAction(_ sender: Any) {
        monthDateComponents.month = 1
        let current = dateFormatter.date(from: todayLocalizedDateString)!
        today = calendar.date(byAdding: monthDateComponents, to: current)!
        updateData()
        EXTableview.reloadData()
    }
    @IBAction func addDayAction(_ sender: Any) {
        dayDateComponents.day = 1
        let current = dateFormatter.date(from: todayLocalizedDateString)!
        today = calendar.date(byAdding: dayDateComponents, to: current)!
        updateData()
        EXTableview.reloadData()
    }
    @IBAction func subtractMonthAction(_ sender: Any) {
        monthDateComponents.month = -1
        let current = dateFormatter.date(from: todayLocalizedDateString)!
        today = calendar.date(byAdding: monthDateComponents, to: current)!
        updateData()
        EXTableview.reloadData()
    }
    @IBAction func subtractDayAction(_ sender: Any) {
        dayDateComponents.day = -1
        let current = dateFormatter.date(from: todayLocalizedDateString)!
        today = calendar.date(byAdding: dayDateComponents, to: current)!
        updateData()
        EXTableview.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.destination is addExpensesViewController){
            let addExController = segue.destination as! addExpensesViewController
            addExController.today = today
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)  {
        if(editingStyle == UITableViewCellEditingStyle.delete){
            let managedContext: NSManagedObjectContext = DatabaseController.getContext()
            managedContext.delete(expensesToday[indexPath.row])
            DatabaseController.saveContext()
        }
        updateData()
        EXTableview.reloadData()
    }
}
