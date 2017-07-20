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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var currencyPickerView: UIPickerView?
    var visibilityPickerView: UIPickerView?
    var keyboardIsShown: Bool = false
    
    //Text Field Outlets
    @IBOutlet weak var otherDonationTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    //Button Outlets
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    //Segmented Control Outlets
    @IBOutlet weak var currencySegmentedControl: UISegmentedControl!
    @IBOutlet weak var visibilitySegmentedControl: UISegmentedControl!
    
    //Layout Constrains
    @IBOutlet weak var otherDonationTextFieldBottomConstraint: NSLayoutConstraint!
    
    var pickerData = [
        "currency" : ["֏", "₽", "$", "€"],
        "valuesAMD" : ["5000" , "10000", "20000", "50000", "100000", "Այլ"],
        "valuesRUB" : ["1000" , "2000", "5000", "10000", "50000", "Այլ"],
        "valuesUSD" : ["10" , "20", "50", "100", "500", "Այլ"],
        "valuesEUR" : ["10" , "20", "50", "100", "500", "Այլ"],
        "visibility" : ["Տեսանելի", "Գաղտնի"]
        ] {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    var currencySelected = "valuesAMD" {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Dismiss keyboard on tap
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        
        //Configure TextField Appearance
        let cornerRadius = CGFloat(5)
        let borderWidth = CGFloat(1)
        let borderColor = UIColor.lightGray.cgColor
        
        nameTextField.layer.cornerRadius = cornerRadius
        nameTextField.layer.borderWidth = borderWidth
        nameTextField.layer.borderColor = borderColor
        nameTextField.textRect(forBounds: CGRect(x: 5, y: 0, width: nameTextField.frame.width, height: nameTextField.frame.height))
        surnameTextField.layer.cornerRadius = cornerRadius
        surnameTextField.layer.borderWidth = borderWidth
        surnameTextField.layer.borderColor = borderColor
        emailTextField.layer.cornerRadius = cornerRadius
        emailTextField.layer.borderWidth = borderWidth
        emailTextField.layer.borderColor = borderColor
        donateButton.layer.cornerRadius = cornerRadius
        
        //Setup Pickers
        
        //Currency
        currencyPickerView = UIPickerView()
        currencyPickerView?.tag = 0
        let currencyPickerViewFrame = CGRect(x: 0, y: 0, width: 50, height: view.frame.size.width)
        currencyPickerView?.frame = currencyPickerViewFrame
        
        currencyPickerView?.transform = CGAffineTransform(rotationAngle: 3.14159/2)
        currencyPickerView?.frame.origin.x = 0
        currencyPickerView?.frame.origin.y = 20
        currencyPickerView?.delegate = self
        currencyPickerView?.dataSource = self
        //view.addSubview(currencyPickerView!)
        
        //Visibility
        visibilityPickerView = UIPickerView()
        visibilityPickerView?.tag = 2
        let visibilityPickerViewFrame = CGRect(x: 0, y: 0, width: 50, height: view.frame.size.width)
        visibilityPickerView?.frame = visibilityPickerViewFrame
        visibilityPickerView?.transform = CGAffineTransform(rotationAngle: 3.14159/2)
        visibilityPickerView?.frame.origin.x = 0
        visibilityPickerView?.frame.origin.y = (pickerView?.frame.origin.y)! + (pickerView?.frame.height)! + 10
        visibilityPickerView?.delegate = self
        visibilityPickerView?.dataSource = self
        //view.addSubview(visibilityPickerView!)
        
        //Value
        pickerView.tag = 1
        pickerView.frame.origin.x = 0
        pickerView.frame.origin.y = (currencyPickerView?.frame.origin.y)! + (currencyPickerView?.frame.height)! + 10
        pickerView.delegate = self
        pickerView.dataSource = self
        
        //Pick AMD for Default
        currencyPickerView?.selectRow(1, inComponent: 0, animated: false)
        pickerView.selectRow(2, inComponent: 0, animated: false)
        
        //Configure Segmented Controls
        let titleFont = UIFont(name: "WeblySleekUISemibold", size: 20)
        
        //Currency Segmented Control
        currencySegmentedControl.tintColor = UIColor.gray
        
        currencySegmentedControl.removeAllSegments()
        currencySegmentedControl.insertSegment(withTitle: "֏", at: 0, animated: false)
        currencySegmentedControl.insertSegment(withTitle: "$", at: 1, animated: false)
        currencySegmentedControl.insertSegment(withTitle: "₽", at: 2, animated: false)
        currencySegmentedControl.insertSegment(withTitle: "€", at: 3, animated: false)
        
        currencySegmentedControl.setTitleTextAttributes([NSFontAttributeName : titleFont!], for: .normal)
        
        currencySegmentedControl.addTarget(self, action: #selector(currencySegmentedControlValueChanged), for: .valueChanged)
        
        currencySegmentedControl.selectedSegmentIndex = 0
        
        //Visibility Segmented Control
        visibilitySegmentedControl.tintColor = UIColor.gray
        
        visibilitySegmentedControl.removeAllSegments()
        visibilitySegmentedControl.insertSegment(withTitle: "Տեսանելի", at: 0, animated: false)
        visibilitySegmentedControl.insertSegment(withTitle: "Գաղտնի", at: 1, animated: false)
        
        visibilitySegmentedControl.setTitleTextAttributes([NSFontAttributeName : titleFont!], for: .normal)
        
        visibilitySegmentedControl.addTarget(self, action: #selector(visibilitySegmentedControlValueChanged), for: .valueChanged)
        
        visibilitySegmentedControl.selectedSegmentIndex = 0
        
        //Configure Other Keyboard
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.items=[
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(numberPadDonePressed))
        ]
        otherDonationTextField.inputAccessoryView = toolBar
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
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView.tag {
        case 0:
            switch row {
            case 0: currencySelected = "valuesUSD"
            case 1: currencySelected = "valuesAMD"
            case 2: currencySelected = "valuesRUB"
            case 3: currencySelected = "valuesEUR"
            default: break
            }
        case 1:
            switch row {
            case 0...4:
                pickerView.isUserInteractionEnabled = true
                pickerView.view(forRow: 5, forComponent: 0)?.isHidden = false
                otherDonationTextField.isHidden = true
                otherDonationTextField.resignFirstResponder()
            case 5:
                if keyboardIsShown {
                    otherDonationTextFieldBottomConstraint.constant = -22
                } else {
                    otherDonationTextFieldBottomConstraint.constant = -90
                }
                pickerView.isUserInteractionEnabled = false
                pickerView.view(forRow: 5, forComponent: 0)?.isHidden = true
                otherDonationTextField.isHidden = false
                otherDonationTextField.becomeFirstResponder()
                
            default: break
            }
        default: break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        switch pickerView.tag {
        case 0: return 50
        case 1: return 50
        case 2: return self.view.frame.size.width / 2
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        switch pickerView.tag {
        case 0:
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
            
        case 1:
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: (self.view?.frame.size.width)!, height: 50))
            
            if let values = pickerData[currencySelected] {
                switch row {
                case 0: label.text = values[0]
                case 1: label.text = values[1]
                case 2: label.text = values[2]
                case 3: label.text = values[3]
                case 4: label.text = values[4]
                case 5: label.text = values[5]
                default: label.text = ""
                }
            }
            
            label.font = UIFont(name: "WeblySleekUISemibold", size: 30)
            label.textAlignment = .center
            return label
            
        case 2:
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: (self.view?.frame.size.width)! / 2, height: 50))
            label.transform = CGAffineTransform(rotationAngle: -3.14159/2)
            
            switch row {
            case 0: label.text = pickerData["visibility"]?[0]
            case 1: label.text = pickerData["visibility"]?[1]
            default: label.text = ""
            }
            
            label.font = UIFont(name: "WeblySleekUISemibold", size: 30)
            label.textAlignment = .center
            return label
        default: break
        }
        return UIView()
    }
    
    // MARK: Drop In Methods
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                self.donateButton.isHidden = false
            } else if result != nil {
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    // MARK: Segmented Control Selectors
    func currencySegmentedControlValueChanged () {
        switch currencySegmentedControl.selectedSegmentIndex {
        case 0: currencySelected = "valuesAMD"
        case 1: currencySelected = "valuesUSD"
        case 2: currencySelected = "valuesRUB"
        case 3: currencySelected = "valuesEUR"
        default: break
        }
    }
    
    func visibilitySegmentedControlValueChanged () {
        
    }
}

extension DonateViewController: UITextFieldDelegate {
    
    func numberPadDonePressed() {
        nameTextField.becomeFirstResponder()
    }
    
    func endEditing () {
        if keyboardIsShown {
        self.view.endEditing(true)
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        self.donateButton.isHidden = false
        pickerView.isUserInteractionEnabled = true
        keyboardIsShown = false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keyboardIsShown = true
        if textField.tag != 3 {
            pickerView.isUserInteractionEnabled = true
            otherDonationTextField.isHidden = true
            donateButton.isHidden = true
            scrollView.setContentOffset(CGPoint(x: 0, y: 135), animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("catchya")
        keyboardIsShown = false
        if textField.tag == 3 {
            if let input = textField.text {
                if !input.isEmpty {
                    switch currencySegmentedControl.selectedSegmentIndex {
                    case 0: pickerData["valuesAMD"]?[5] = input
                    case 1: pickerData["valuesUSD"]?[5] = input
                    case 2: pickerData["valuesRUB"]?[5] = input
                    case 3: pickerData["valuesEUR"]?[5] = input
                    default: break
                    }
                } else {
                    pickerData["valuesAMD"]?[5] = "Այլ"
                }
            }
            otherDonationTextField.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0: surnameTextField.becomeFirstResponder()
        case 1: emailTextField.becomeFirstResponder()
        case 2:
            emailTextField.resignFirstResponder()
            keyboardIsShown = false
            donate(donateButton)
        default: return false
        }
        return true
    }
}
