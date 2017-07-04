//
//  DonateViewController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/4/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit

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
    
    @IBAction func close(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    // MARK: -PickerView
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
