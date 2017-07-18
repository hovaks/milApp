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
    
    var currencyPickerView: UIPickerView?
    
    var infoDictionary = [String : [String : String]]() {
        didSet {
            updateLabelValues(forCurrency: "AMD")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup Picker
        currencyPickerView = UIPickerView()
        let currencyPickerViewFrame = CGRect(x: view.frame.size.width / 2 - 25, y: -(view.frame.size.width / 2) + 60, width: 50, height: view.frame.size.width)
        currencyPickerView?.frame = currencyPickerViewFrame
        currencyPickerView?.transform = CGAffineTransform(rotationAngle: 3.14159/2)
        currencyPickerView?.delegate = self
        currencyPickerView?.dataSource = self
        view.addSubview(currencyPickerView!)
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
        
        //Pick AMD for Default
        currencyPickerView?.selectRow(1, inComponent: 0, animated: false)
        
        //Parse Info
        Parser.get1000PlusContent { (resultsDictionary, response, error) in
            self.infoDictionary = resultsDictionary
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabelValues (forCurrency currency: String) {
        //Set label Values
        if let totalFunds = infoDictionary["TotalFunds"] {
            totalFundsValueLabel.text = totalFunds[currency]
        }
        if let stampDuty = infoDictionary["StampDuty"] {
            stampDutyValueLabel.text = stampDuty[currency]
        }
        if let donations = infoDictionary["Donations"] {
            donationsValueLabel.text = donations[currency]
        }
        if let compensations = infoDictionary["Compensations"] {
            compensationsValueLabel.text = compensations[currency]
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

extension _000PlusViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0: updateLabelValues(forCurrency: "USD")
        case 1: updateLabelValues(forCurrency: "AMD")
        case 2: updateLabelValues(forCurrency: "RUB")
        case 3: updateLabelValues(forCurrency: "EUR")
        default: break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        label.transform = CGAffineTransform(rotationAngle: -3.14159/2)
        
        switch row {
        case 0: label.text = "$"
        case 1: label.text = "֏"
        case 2: label.text = "₽"
        case 3: label.text = "€"
        default: label.text = ""
        }
        
        label.font = UIFont(name: "WeblySleekUISemibold", size: 30)
        label.textAlignment = .center
        return label
    }
}
