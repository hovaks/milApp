//
//  FindViewController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/4/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit

class FindViewController: UIViewController {
    
    //Text Field Outlets
    @IBOutlet weak var EINtextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var SSNTextField: UITextField!
    
    //Button Outlets
    @IBOutlet weak var findButton: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
