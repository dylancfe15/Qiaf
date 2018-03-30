//
//  SHViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 11/11/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
class SHViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate,GADInterstitialDelegate{
    @IBOutlet weak var completedMoneyOutlet: UILabel!
    @IBOutlet weak var contributedMoneyOutlet: UILabel!
    @IBOutlet weak var failedMoneyOutlet: UILabel!
    @IBOutlet weak var withdrawMoneyOutlet: UILabel!
    @IBOutlet weak var SHTableView: UITableView!
    @IBOutlet weak var balanceOutlet: UILabel!
    @IBOutlet weak var myBanner: GADBannerView!
    
    var index = 0
    var goalsArray = [Goals]()
    var saingHisArray = [SavingHistory]()
    let goalsRequest:NSFetchRequest<Goals> = Goals.fetchRequest()
    let dateFormatter = DateFormatter()
    var completedTotal = Int32()
    var contributedTotal = Int32()
    var failedTotal = Int32()
    var withdrawTotal = Int32()
    var expectedBalance = Int32()
    var amount = Int32()
    var date = String()
    var note = String()
    var type = String()
    let managedContext: NSManagedObjectContext = DatabaseController.getContext()
    var fullScreenads : GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        summary()
        SHTableView.backgroundColor = UIColor.clear
        //Banner
        let adRequest = GADRequest()
        adRequest.testDevices = [kGADSimulatorID]
        myBanner.adUnitID = "ca-app-pub-6779325502552778/7579109991"
        myBanner.rootViewController = self
        myBanner.delegate = self
        
        myBanner.load(adRequest)
        
        //CreatAndLoadInterstitial()
    }
    /*
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
        print("Ads loaded")
        ad.present(fromRootViewController: self)
    }
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("Ads failed")
    }
    */
    func summary(){
        completedTotal = 0
        contributedTotal = 0
        failedTotal = 0
        withdrawTotal = 0
        
        do{
            goalsArray = try DatabaseController.getContext().fetch(goalsRequest)
            saingHisArray = goalsArray[index].savingHistory?.allObjects as! [SavingHistory]
        }catch{
            
        }
        saingHisArray.sort { (saingHisArray1, saingHisArray2) -> Bool in
            return (saingHisArray1.date! as Date) < (saingHisArray2.date! as Date)
        }
        
        for savingHis in saingHisArray{
            if(savingHis.type == "Completed"){
                completedTotal = completedTotal + savingHis.money
            }else if(savingHis.type == "Contributed"){
                contributedTotal = contributedTotal + savingHis.money
            }else if(savingHis.type == "Failed"){
                failedTotal = failedTotal + savingHis.money
            }else{
                withdrawTotal = withdrawTotal + savingHis.money
            }
        }
        
        completedMoneyOutlet.text = "$ "+String(completedTotal)
        contributedMoneyOutlet.text = "$ "+String(contributedTotal)
        failedMoneyOutlet.text = "$ "+String(failedTotal)
        withdrawMoneyOutlet.text = "$ "+String(withdrawTotal)
        balanceOutlet.text = "$ " + String(completedTotal+contributedTotal+failedTotal+withdrawTotal)+"/($ "+String(expectedBalance)+")"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return saingHisArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SHCell") as! SHTableViewCell
        cell.date.text = dateFormatter.string(from: saingHisArray[indexPath.row].date! as Date)
        cell.money.text = "$ " + String(saingHisArray[indexPath.row].money)
        cell.type.text = saingHisArray[indexPath.row].type
        cell.notes.text = saingHisArray[indexPath.row].note
        if(saingHisArray[indexPath.row].type == "Failed"){
            cell.type.textColor = UIColor.orange
        }else if(saingHisArray[indexPath.row].type == "Withdraw"){
            cell.type.textColor = UIColor.red
        }else{
            cell.type.textColor = UIColor.green
        }
        //cell.backgroundImage.layer.cornerRadius = 10
        cell.backgroundColor = UIColor.clear
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)  {
        if(editingStyle == UITableViewCellEditingStyle.delete){
            managedContext.delete(saingHisArray[indexPath.row])
            saingHisArray.remove(at: indexPath.row)
            DatabaseController.saveContext()
        }
        tableView.reloadData()
        summary()
    }
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        date = dateFormatter.string(from: saingHisArray[indexPath.row].date! as Date)
        type = saingHisArray[indexPath.row].type!
        amount = saingHisArray[indexPath.row].money
        note = saingHisArray[indexPath.row].note!
        managedContext.delete(saingHisArray[indexPath.row])
        DatabaseController.saveContext()
        performSegue(withIdentifier: "EditeCell", sender: self)
    }
    */
    
    //segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination  is trackSavingViewController{
            let TSController = segue.destination as! trackSavingViewController
            TSController.indexCell = index
        }else if segue.destination is SHEditingCellViewController{
            let SHController = segue.destination as! SHEditingCellViewController
            SHController.amount = amount
            SHController.date = date
            SHController.note = note
            SHController.type = type
            SHController.index = index
            SHController.expectBal = expectedBalance
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
