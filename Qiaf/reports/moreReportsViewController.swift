//
//  moreReportsViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 12/6/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
class moreReportsViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    
    var rotationAngle:CGFloat!
    let goalsRequest:NSFetchRequest<Goals> = Goals.fetchRequest()
    let expenseRequest:NSFetchRequest<Expenses> = Expenses.fetchRequest()
    var goalsArr = [Goals]()
    var allExpenses = [Expenses]()
    var dateFormatter = DateFormatter()
    struct tableStruct {
        var amount = Double()
        var dateEarlier = Int()
        var categries = String()
        var items = Int()
    }
    struct ExStruct {
        var date = Date()
        var amount = Double()
        var categries = String()
    }
    var ExStructArray = [ExStruct]()
    var tableStructArray = [tableStruct]()
    var currentGoal = Goals()
    var dateComponents = DateComponents()
    let today = Date()
    
    @IBOutlet weak var myGoalsLabel: UILabel!
    @IBOutlet weak var goalsPickerOutler: UIPickerView!
    @IBOutlet weak var myBanner: GADBannerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateComponents.day = -30
        
        rotationAngle = 90 * (.pi/180)
        goalsPickerOutler.transform = CGAffineTransform(rotationAngle: rotationAngle)
        goalsPickerOutler.frame = CGRect(x: 0, y: myGoalsLabel.frame.origin.y+29, width: view.frame.width, height: 120)
        
        //Banner
        let adRequest = GADRequest()
        adRequest.testDevices = [kGADSimulatorID]
        myBanner.adUnitID = "ca-app-pub-6779325502552778/7579109991"
        myBanner.rootViewController = self
        myBanner.delegate = self as? GADBannerViewDelegate
        myBanner.load(adRequest)
        
        //fetch
        do{
            goalsArr = try DatabaseController.getContext().fetch(goalsRequest)
            allExpenses = try DatabaseController.getContext().fetch(expenseRequest)
        }catch{
            
        }
        
        for result in allExpenses{
            if(result.date! as Date > Calendar.current.date(byAdding: dateComponents, to: today)!){
                ExStructArray += [ExStruct(date:result.date! as Date,amount:result.amount,categries:result.categry!)]
            }
        }
    }

    //update table
    func updateTable(){
        ExStructArray = ExStructArray.sorted(by:{$0.categries > $1.categries})
        
        
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
        return goalsArr.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 120
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var tempNum:Int32 = 0
        var SHArray = [SavingHistory]()
        SHArray = goalsArr[row].savingHistory?.allObjects as! [SavingHistory]
        let view = UIView(frame: CGRect(x: 10, y: 0, width: 120, height: 120))
        let Tlabel = UILabel(frame: CGRect(x: 10, y: 15, width: 100, height: 20))
        let Mlabel = UILabel(frame: CGRect(x: 10, y: 30, width: 100, height: 50))
        let Blabel = UILabel(frame: CGRect(x: 10, y: 90, width: 100, height: 15))
        Tlabel.text = "By:"+dateFormatter.string(from: goalsArr[row].finishedDate! as Date)
        Mlabel.text = goalsArr[row].title
        for result in SHArray{
            tempNum += result.money
        }
        Blabel.text = String(format: "%.2f",Double(tempNum)/Double(goalsArr[row].task))+"%"
        Tlabel.textColor = UIColor.white
        Mlabel.textColor = UIColor.white
        Blabel.textColor = UIColor.white
        Tlabel.textAlignment = .center
        Mlabel.textAlignment = .center
        Blabel.textAlignment = .center
        Mlabel.font = UIFont(name: "Noteworthy-Bold", size: 40)
        Tlabel.adjustsFontSizeToFitWidth = true
        Mlabel.adjustsFontSizeToFitWidth = true
        Blabel.adjustsFontSizeToFitWidth = true
        view.addSubview(Tlabel)
        view.addSubview(Mlabel)
        view.addSubview(Blabel)
        view.transform = CGAffineTransform(rotationAngle: -rotationAngle)
        return view
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentGoal = goalsArr[row]
    }
    
}
