//
//  DonateViewController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/4/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree

class DonateViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    //Text Field Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    //Button Outlets
    @IBOutlet weak var donateButton: UIButton!
    
    let pickerData = [
        "currency" : ["֏", "₽", "$", "€"],
        "valuesAMD" : ["5000" , "10000", "20000", "50000", "100000", "Այլ"],
        "valuesRUB" : ["1000" , "2000", "5000", "10000", "50000", "Այլ"],
        "valuesUSD" : ["10" , "20", "50", "100", "500", "Այլ"],
        "valuesEUR" : ["10" , "20", "50", "100", "500", "Այլ"],
        "visibility" : ["Տեսանելի", "Գաղտնի"]
    ]
    
    var currencySelected = "valuesAMD" {
        didSet {
            pickerView.reloadComponent(1)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure TextField Appearance
        let cornerRadius = CGFloat(5)
        let borderWidth = CGFloat(1)
        let borderColor = UIColor.lightGray.cgColor
        
        nameTextField.layer.cornerRadius = cornerRadius
        nameTextField.layer.borderWidth = borderWidth
        nameTextField.layer.borderColor = borderColor
        surnameTextField.layer.cornerRadius = cornerRadius
        surnameTextField.layer.borderWidth = borderWidth
        surnameTextField.layer.borderColor = borderColor
        emailTextField.layer.cornerRadius = cornerRadius
        emailTextField.layer.borderWidth = borderWidth
        emailTextField.layer.borderColor = borderColor
        donateButton.layer.cornerRadius = cornerRadius
        
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //IBActions
    
    @IBAction func close(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func donate(_ sender: UIButton) {
        showDropIn(clientTokenOrTokenizationKey: "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJlMTZlMjFjYjAxMDY5MTU2ZWRkMmE3ZjEzYWRiYzcwODI1ZGRiZDhjNTE0MDJlNzQ3MmQzOGMzZWM1MjE0YTRifGNyZWF0ZWRfYXQ9MjAxNy0wNy0wNFQwODozODoxMS40MzM4ODkyODErMDAwMFx1MDAyNm1lcmNoYW50X2lkPTM0OHBrOWNnZjNiZ3l3MmJcdTAwMjZwdWJsaWNfa2V5PTJuMjQ3ZHY4OWJxOXZtcHIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzLzM0OHBrOWNnZjNiZ3l3MmIvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tLzM0OHBrOWNnZjNiZ3l3MmIifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJtZXJjaGFudEFjY291bnRJZCI6ImFjbWV3aWRnZXRzbHRkc2FuZGJveCIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJjb2luYmFzZUVuYWJsZWQiOmZhbHNlLCJtZXJjaGFudElkIjoiMzQ4cGs5Y2dmM2JneXcyYiIsInZlbm1vIjoib2ZmIn0=")
    }
    
    
    
    // MARK: - PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return (pickerData["currency"]?.count)!
        case 1:
            return (pickerData["valuesAMD"]?.count)!
        case 2:
            return (pickerData["visibility"]?.count)!
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch component {
        case 0:
            switch row {
            case 0: return pickerData["currency"]?[0]
            case 1: return pickerData["currency"]?[1]
            case 2: return pickerData["currency"]?[2]
            case 3: return pickerData["currency"]?[3]
            default: return ""
            }
        case 1:
            if let values = pickerData[currencySelected] {
                switch row {
                case 0: return values[0]
                case 1: return values[1]
                case 2: return values[2]
                case 3: return values[3]
                case 4: return values[4]
                case 5: return values[5]
                default: return ""
                }
            } else {
                return ""
            }
        case 2:
            switch row {
            case 0: return pickerData["visibility"]?[0]
            case 1: return pickerData["visibility"]?[1]
            default: return ""
            }
        default:
            return "none"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch component {
        case 0:
            switch row {
            case 0: currencySelected = "valuesAMD"
            case 1: currencySelected = "valuesRUB"
            case 2: currencySelected = "valuesUSD"
            case 3: currencySelected = "valuesEUR"
            default: break
            }
        default: break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0: return 50.0
        case 1: return 100.0
        case 2: return 218.0 - 25.0
        default: return 0.0
        }
    }
    
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        switch component {
//        case 0:
//            if let string = pickerData["currency"]?[row] {
//            let attributedString = NSAttributedString(string: string)
//            return attributedString
//            } else {
//                return NSAttributedString(string: "")
//            }
//        case 1:
//            if let string = pickerData[currencySelected]?[row] {
//                let attributedString = NSAttributedString(string: string)
//                return attributedString
//            } else {
//                return NSAttributedString(string: "")
//            }
//        case 2:
//            if let string = pickerData[currencySelected]?[row] {
//                let attributedString = NSMutableAttributedString(string: string)
//                return attributedString
//            } else {
//                return NSAttributedString(string: "")
//            }
//        default:
//            break
//        }
//        return NSAttributedString(string: "")
//    }
    
    // MARK: Drop In Methods
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}