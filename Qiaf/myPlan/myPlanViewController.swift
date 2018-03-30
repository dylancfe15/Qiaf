//
//  myPlanViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 11/2/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
class myPlanViewController: UIViewController , UITableViewDelegate,UITableViewDataSource, GADBannerViewDelegate,GADInterstitialDelegate{
    
    var goalArray = [Goals]()
    var savinghis = [SavingHistory]()
    //var completedPerstg = [Int]()
    var totalHistory: Int32 = 0
    let request: NSFetchRequest<Goals> = Goals.fetchRequest()
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    var evaluationScore = 1.0
    var currentDate = Date()
    let userCalendar = Calendar.current
    var datecomponent = DateComponents()
    var monthDateComponent = DateComponents()
    var requestedComponent: Set<Calendar.Component> = [.day]
    var fullScreenads : GADInterstitial!
    let today = Date()
    var futureDate = Date()
    var differentDay = DateComponents()
    let randomNum : Int = Int(arc4random_uniform(11))+2
    
    @IBOutlet weak var fromToday: UILabel!
    @IBOutlet weak var inMonths: UILabel!
    @IBOutlet weak var canHaveMoney: UILabel!
    @IBOutlet weak var moneyPerDay: UILabel!
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var myBan: GADBannerView!
    @IBOutlet weak var addButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        CreatAndLoadInterstitial()
        dateFormatter.dateStyle = .medium
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        addButton.layer.cornerRadius = 10
        MPTableView.backgroundColor = UIColor.clear
        topImage.layer.cornerRadius = 15
        
        //random number
        moneyPerDay.text = "$ "+String(Calendar.current.component(.day, from: today))
        inMonths.text = String(randomNum)
        monthDateComponent.month = randomNum
        futureDate = userCalendar.date(byAdding: monthDateComponent, to: today)!
        differentDay = userCalendar.dateComponents([.day], from: today, to: futureDate)
        canHaveMoney.text = "$ "+String(differentDay.day!*Calendar.current.component(.day, from: today))
        fromToday.text = dateFormatter.string(from: today)
        
        //fetch goals
        do{
            goalArray = try DatabaseController.getContext().fetch(request) as [Goals]
        }catch{
            print("ERROR")
        }
        if(goalArray.count < 1){
            MPTableView.isHidden = true
            introLabel.isHidden = false
        }
        
        //request
        let adRequest = GADRequest()
        adRequest.testDevices = [kGADSimulatorID]
        
        //set up ad
        myBan.adUnitID = "ca-app-pub-6779325502552778/7579109991"
        myBan.rootViewController = self
        myBan.delegate = self
        
        myBan.load(adRequest)
    }
    
    //Interstitial ads
    func CreatAndLoadInterstitial() -> GADInterstitial?{
        fullScreenads = GADInterstitial(adUnitID:"ca-app-pub-6779325502552778/7456192190")
        guard let fullScreenads = fullScreenads else{
            return nil
        }
        let requestInter = GADRequest()
        requestInter.testDevices = [kGADSimulatorID]
        fullScreenads.load(requestInter)
        fullScreenads.delegate = self
        return fullScreenads
    }
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goalArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        totalHistory = 0
        let cell = tableView.dequeueReusableCell(withIdentifier: "myPlanCell") as! myPlanTableViewCell
        let results = goalArray
        cell.title.text = results[indexPath.row].title
        cell.targetDate.text = "By:" + dateFormatter.string(from: results[indexPath.row].finishedDate! as Date)
        savinghis = results[indexPath.row].savingHistory?.allObjects as! [SavingHistory]
        if(savinghis.count > 0){
            for saving in savinghis{
                totalHistory = totalHistory + saving.money
            }
            cell.completed.text = String(format: "%.2f", Double(totalHistory) / Double(results[indexPath.row].task)*100)
        }else{
            cell.completed.text = "0.00"
        }
        cell.total.text = "$ "+String(totalHistory) + " / $ " + numberFormatter.string(from: NSNumber(value:results[indexPath.row].task))!
        var timeDifferences = userCalendar.dateComponents(requestedComponent, from: results[indexPath.row].startDate! as Date, to: currentDate)
        let differeces = timeDifferences.day!
        if(timeDifferences.day! > 1){
            if(results[indexPath.row].period == 0){
                if(timeDifferences.day! % 1 == 0){
                    evaluationScore = Double(totalHistory) / Double(Int32(differeces / 1)*results[indexPath.row].saving)
                }
            }else if(results[indexPath.row].period == 1){
                if(timeDifferences.day! % 7 == 0){
                    evaluationScore = Double(totalHistory) / Double(Int32(differeces / 7)*results[indexPath.row].saving)
                }
            }else if(results[indexPath.row].period == 2){
                if(timeDifferences.day! % 15 == 0){
                    evaluationScore = Double(totalHistory) / Double(Int32(differeces / 15)*results[indexPath.row].saving)
                }
            }else{
                if(timeDifferences.day! % 30 == 0){
                    evaluationScore = Double(totalHistory) / Double(Int32(differeces / 30)*results[indexPath.row].saving)
                }
            }
        }
        cell.backgroundImage.layer.cornerRadius = 10
        cell.backgroundColor = UIColor.clear
        if(UIImage(named:cell.title.text!) != nil){
            cell.TitleIcon.image = UIImage(named:cell.title.text!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)  {
        if(editingStyle == UITableViewCellEditingStyle.delete){
            let managedContext: NSManagedObjectContext = DatabaseController.getContext()
            managedContext.delete(goalArray[indexPath.row])
            DatabaseController.saveContext()
        }
        viewDidLoad()
        tableView.reloadData()
    }
    
    //segue
    @IBOutlet weak var MPTableView: UITableView!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is trackSavingViewController{
            let cell = sender as! UITableViewCell
            let indexP = MPTableView.indexPath(for: cell)
            let TSController = segue.destination as! trackSavingViewController
            TSController.indexCell = (indexP?.row)!
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
