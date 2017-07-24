//
//  BanakTabBarController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/24/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit

class BanakTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override var shouldAutorotate: Bool {
        return (selectedViewController?.shouldAutorotate)!
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
