//
//  TabBarViewController.swift
//  Qiaf
//
//  Created by Difeng Chen on 12/4/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    @IBOutlet weak var tabBarOutlet: UITabBar!
    var tabBarIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = tabBarIndex
        
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
