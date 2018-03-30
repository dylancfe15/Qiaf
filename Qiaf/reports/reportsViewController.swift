//
//  reportsViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 12/5/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
class reportsViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var moreReports: UIButton!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var myBanner: GADBannerView!
    @IBOutlet weak var periodSegmentOutlet: UISegmentedControl!
    @IBOutlet weak var PickerOutlet: UIPickerView!
    @IBOutlet weak var exTable: UITableView!
    struct pickViewStruct {
        var dateValue: Date
        var amountValue:Double
    }
    struct tableViewStruct {
        var stringValue: String
        var amountValue:Double
    }
    var rotationAngle: CGFloat!
    var allExpenses = [Expenses]()
    var allExpensesTable = [tableViewStruct]()
    var pickerViewArray = [pickViewStruct]()
    let requestExpense:NSFetchRequest<Expenses> = Expenses.fetchRequest()
    var dateComponents = DateComponents()
    let calendar = Calendar.current
    let today = Date()
    var midLabel = [String]()
    var topLabel = [String]()
    var botLabel = [Double]()
    var monthDateFormatter = DateFormatter()
    var dateFormatter = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        
        rotationAngle = 90 * (.pi/180)
        PickerOutlet.transform = CGAffineTransform(rotationAngle: rotationAngle)
        PickerOutlet.frame = CGRect(x: 0, y: periodSegmentOutlet.frame.origin.y+36, width: view.frame.width, height: 120)
        updatePickerLabel()
        updateExpensesTable()
        
        moreReports.layer.cornerRadius = 10
        
        //Banner
        let adRequest = GADRequest()
        adRequest.testDevices = [kGADSimulatorID]
        myBanner.adUnitID = "ca-app-pub-6779325502552778/7579109991"
        myBanner.rootViewController = self
        myBanner.delegate = self as? GADBannerViewDelegate
        myBanner.load(adRequest)
    }
    
    //segment
    @IBAction func periodSegmentAction(_ sender: Any) {
        updatePickerLabel()
        updateExpensesTable()
    }
    
    func updatePickerLabel()  {
        do{
            allExpenses = try DatabaseController.getContext().fetch(requestExpense)
        }catch{
            print("ERROR")
        }
        if(allExpenses.count > 0){
            emptyLabel.isHidden = true
            PickerOutlet.isHidden = false
            exTable.isHidden = false
        }else{
            emptyLabel.isHidden = false
            PickerOutlet.isHidden = true
            exTable.isHidden = true
        }
        pickerViewArray = []
        for result in allExpenses{
            pickerViewArray += [pickViewStruct(dateValue:result.date! as Date,amountValue:result.amount)]
        }
        pickerViewArray = pickerViewArray.sorted(by: {$0.dateValue > $1.dateValue})
        midLabel = []
        topLabel = []
        botLabel = []
        for result in pickerViewArray{
            if(periodSegmentOutlet.selectedSegmentIndex == 0  ){
                monthDateFormatter.dateFormat = "LLL YY"
                topLabel += [monthDateFormatter.string(from: result.dateValue)]
                midLabel += [String(calendar.component(.day, from: result.dateValue))]
                
            }else if(periodSegmentOutlet.selectedSegmentIndex == 1){
                let firstDate = dateFormatter.date(from: "01/01/"+String(calendar.component(.year, from: result.dateValue)))
                topLabel += [String(calendar.component(.year, from: result.dateValue))]
                midLabel += ["W"+String(calendar.dateComponents([.day], from: firstDate!, to: result.dateValue).day!/7)]
                
            }else if(periodSegmentOutlet.selectedSegmentIndex == 2 ){
                topLabel += [String(calendar.component(.year, from: result.dateValue))]
                monthDateFormatter.dateFormat = "LLL"
                midLabel += [monthDateFormatter.string(from: result.dateValue)]
                
            }else{
                    topLabel += [String(calendar.component(.year, from: result.dateValue)/100+1)+"th"]
                    midLabel += [String(calendar.component(.year, from: result.dateValue)%100)]
            }
            botLabel += [result.amountValue]
        }
        removeDuplicated()
        PickerOutlet.reloadAllComponents()
    }
    
    func removeDuplicated(){
        var tempMidArr = [String]()
        var tempTopArr = [String]()
        var tempBotArr = [Double]()
        if(midLabel.count > 0){
            for i in 0...midLabel.count-1{
                if(tempMidArr.count > 0){
                    if(midLabel[i] != tempMidArr[tempMidArr.count-1]){
                        tempMidArr += [midLabel[i]]
                        tempTopArr += [topLabel[i]]
                        tempBotArr += [botLabel[i]]
                    }else if(topLabel[i] != tempTopArr[tempTopArr.count-1]){
                        tempMidArr += [midLabel[i]]
                        tempTopArr += [topLabel[i]]
                        tempBotArr += [botLabel[i]]
                    }else {
                        tempBotArr[tempBotArr.count-1] += botLabel[i]
                    }
                }else{
                    tempMidArr += [midLabel[i]]
                    tempTopArr += [topLabel[i]]
                    tempBotArr += [botLabel[i]]
                }
            }
        }else{
            tempMidArr = midLabel
            tempTopArr = topLabel
            tempBotArr = botLabel
        }
        midLabel = tempMidArr
        topLabel = tempTopArr
        botLabel = tempBotArr
    }
    
    func updateExpensesTable(){
        do{
            allExpenses = try DatabaseController.getContext().fetch(requestExpense)
        }catch{
            print("ERROR")
        }
        allExpensesTable = []
        for result in allExpenses{
            if(periodSegmentOutlet.selectedSegmentIndex == 0  ){
                monthDateFormatter.dateFormat = "LLL YY"
                if(monthDateFormatter.string(from: result.date! as Date) == topLabel[PickerOutlet.selectedRow(inComponent: 0)]){
                    if(String(calendar.component(.day, from: result.date! as Date)) == midLabel[PickerOutlet.selectedRow(inComponent: 0)]){
                        allExpensesTable += [tableViewStruct(stringValue:result.categry!,amountValue:result.amount)]
                    }
                }
            }else if(periodSegmentOutlet.selectedSegmentIndex == 1){
                let firstDate = dateFormatter.date(from: "01/01/"+String(calendar.component(.year, from: result.date! as Date)))
                
                if(String(calendar.component(.year, from: result.date! as Date)) == topLabel[PickerOutlet.selectedRow(inComponent: 0)]){
                    
                    if("W"+String(calendar.dateComponents([.day], from: firstDate!, to: result.date! as Date).day!/7) == midLabel[PickerOutlet.selectedRow(inComponent: 0)]){
                        allExpensesTable += [tableViewStruct(stringValue:result.categry!,amountValue:result.amount)]
                    }
                }
                
            }else if(periodSegmentOutlet.selectedSegmentIndex == 2 ){
                monthDateFormatter.dateFormat = "LLL"
                
                if(String(calendar.component(.year, from: result.date! as Date)) == topLabel[PickerOutlet.selectedRow(inComponent: 0)]){
                    
                    if(monthDateFormatter.string(from: result.date! as Date) == midLabel[PickerOutlet.selectedRow(inComponent: 0)]){
                        allExpensesTable += [tableViewStruct(stringValue:result.categry!,amountValue:result.amount)]
                    }
                }
                
            }else{
                
                if(String(calendar.component(.year, from: result.date! as Date)/100+1)+"th" == topLabel[PickerOutlet.selectedRow(inComponent: 0)]){
                    
                    if(String(calendar.component(.year, from: result.date! as Date)%100) == midLabel[PickerOutlet.selectedRow(inComponent: 0)]){
                        allExpensesTable += [tableViewStruct(stringValue:result.categry!,amountValue:result.amount)]
                    }
                }
            }
        }
        allExpensesTable = allExpensesTable.sorted(by: {$0.stringValue < $1.stringValue})
        var tempArray = [tableViewStruct]()
        for result in allExpensesTable{
            if(tempArray.count > 0){
                if(checkDuplicated(Str: result.stringValue, StrArr: tempArray)){
                    tempArray += [tableViewStruct(stringValue:result.stringValue,amountValue:result.amountValue)]
                }else{
                    tempArray[tempArray.count-1].amountValue += result.amountValue
                }
            }else{
                tempArray += [tableViewStruct(stringValue:result.stringValue,amountValue:result.amountValue)]
            }
        }
        allExpensesTable = tempArray
        allExpensesTable = allExpensesTable.sorted(by: {$0.amountValue > $1.amountValue})
        exTable.reloadData()
    }
    
    func checkDuplicated(Str:String,StrArr: [tableViewStruct]) ->Bool{
        
        for result in StrArr{
            if(Str == result.stringValue){
                return false
            }
        }
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return midLabel.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 120
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        let TLabel = UILabel(frame: CGRect(x: 0, y: 20, width: 150, height: 15))
        let MLabel = UILabel(frame: CGRect(x: 0, y: 30, width: 150, height: 50))
        let BLabel = UILabel(frame: CGRect(x: 0, y: 90, width: 150, height: 15))
        TLabel.text = topLabel[row]
        MLabel.text = midLabel[row]
        BLabel.text = "$ " + String(format:"%.2f",botLabel[row])
        TLabel.textColor = UIColor.white
        MLabel.textColor = UIColor.white
        BLabel.textColor = UIColor.white
        TLabel.textAlignment = .center
        MLabel.textAlignment = .center
        BLabel.textAlignment = .center
        MLabel.font = UIFont(name: "Noteworthy-Bold", size: 40)
        MLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(TLabel)
        view.addSubview(MLabel)
        view.addSubview(BLabel)
        view.transform = CGAffineTransform(rotationAngle: -rotationAngle)
        return view
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateExpensesTable()
        exTable.reloadData()
    }
    
    //table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allExpensesTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportExCell", for: indexPath) as! reportExpensesTableViewCell
        cell.cate.text = allExpensesTable[indexPath.row].stringValue
        cell.num.text = "$ "+String(format:"%.2f",allExpensesTable[indexPath.row].amountValue)
        cell.backgroundColor = UIColor.clear
        return cell
    }
}
