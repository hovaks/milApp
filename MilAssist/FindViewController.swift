//
//  FindViewController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/4/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit

class FindViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //Label Outlets
    @IBOutlet weak var statusLabel: UILabel!
    
    //Text Field Outlets
    @IBOutlet weak var EINtextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var SSNTextField: UITextField!
    
    //Button Outlets
    @IBOutlet weak var findButton: UIButton!
    
    //Layout Constraints
    @IBOutlet weak var emailTextFieldHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var EINTextFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var SSNTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelConstraint: NSLayoutConstraint!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure Segmented Control
        segmentedControl.removeAllSegments()
        segmentedControl.tintColor = UIColor.gray
        segmentedControl.insertSegment(withTitle: "Նվիրաբերություններ", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Պարտադիր վճարներ", at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        segmentedControl.selectedSegmentIndex = 0
        
        //Configure TextField Appearance
        let cornerRadius = CGFloat(5)
        let borderWidth = CGFloat(1)
        let borderColor = UIColor.lightGray.cgColor
        
        EINtextField.layer.cornerRadius = cornerRadius
        EINtextField.layer.borderWidth = borderWidth
        EINtextField.layer.borderColor = borderColor
        emailTextField.layer.cornerRadius = cornerRadius
        emailTextField.layer.borderWidth = borderWidth
        emailTextField.layer.borderColor = borderColor
        SSNTextField.layer.cornerRadius = cornerRadius
        SSNTextField.layer.borderWidth = borderWidth
        SSNTextField.layer.borderColor = borderColor
        findButton.layer.cornerRadius = cornerRadius
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    // Mark: - Segmented Control
    
    func segmentedControlValueChanged() {
        statusLabel.text = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        switch segmentedControl.selectedSegmentIndex {
        case 0: emailTextField.isHidden = false
        case 1: emailTextField.isHidden = true
        default: break
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

extension FindViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        statusLabelConstraint.constant = 0
        descriptionLabelConstraint.constant = 0
        EINTextFieldTopConstraint.constant = 10
        SSNTextFieldBottomConstraint.constant = 57 + 46 + 20 + 8
    }
}
