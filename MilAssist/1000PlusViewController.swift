//
//  1000PlusViewController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/4/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit

class _000PlusViewController: UIViewController, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    //Label Outlets
    @IBOutlet weak var totalFundsValueLabel: UILabel!
    @IBOutlet weak var stampDutyValueLabel: UILabel!
    @IBOutlet weak var donationsValueLabel: UILabel!
    @IBOutlet weak var compensationsValueLabel: UILabel!
    
    //View Outlets
    @IBOutlet weak var totalFundsView: UIView!
    @IBOutlet weak var stampDutyView: UIView!
    @IBOutlet weak var donationsView: UIView!
    @IBOutlet weak var compensationsView: UIView!
    
    //Button Outlets
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var findYourDonationButton: UIButton!
    
    
    var infoDictionary = [String : [String : String]]() {
        didSet {
            updateLabelValues()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Hide Navigations Bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        //Setup View Looks
        let cornerRadius = CGFloat(5)
        let borderWidth = CGFloat(1)
        let borderColor = UIColor.gray.cgColor
        
        totalFundsView.layer.cornerRadius = cornerRadius
        totalFundsView.layer.borderWidth = borderWidth
        totalFundsView.layer.borderColor = borderColor
        stampDutyView.layer.cornerRadius = cornerRadius
        stampDutyView.layer.borderWidth = borderWidth
        stampDutyView.layer.borderColor = borderColor
        donationsView.layer.cornerRadius = cornerRadius
        donationsView.layer.borderWidth = borderWidth
        donationsView.layer.borderColor = borderColor
        compensationsView.layer.cornerRadius = cornerRadius
        compensationsView.layer.borderWidth = borderWidth
        compensationsView.layer.borderColor = borderColor
        donateButton.layer.cornerRadius = cornerRadius
        findYourDonationButton.layer.cornerRadius = cornerRadius
        
        //Parse Info
        Parser.get1000PlusContent { (resultsDictionary, response, error) in
            self.infoDictionary = resultsDictionary
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabelValues () {
        //Set label Values
        if let totalFunds = infoDictionary["TotalFunds"] {
            totalFundsValueLabel.text = totalFunds["AMD"]
        }
        if let stampDuty = infoDictionary["StampDuty"] {
            stampDutyValueLabel.text = stampDuty["AMD"]
        }
        if let donations = infoDictionary["Donations"] {
            donationsValueLabel.text = donations["AMD"]
        }
        if let compensations = infoDictionary["Compensations"] {
            compensationsValueLabel.text = compensations["AMD"]
        }
    }
    
    

     // MARK: - Navigation
    
    let customPresentAnimationController = CustomPresentAnimationController()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAction" {
            let toViewController = segue.destination as? DonateViewController
            toViewController?.transitioningDelegate = self
        }
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = CustomPresentAnimationController()
        return animationController
    }
}
