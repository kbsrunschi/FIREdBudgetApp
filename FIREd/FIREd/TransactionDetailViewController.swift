//
//  TransactionDetailViewController.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/7/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//

import UIKit

class TransactionDetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    // MARK: -Properties
    
    @IBOutlet weak var dateTextField: UITextField! { didSet { dateTextField.delegate = self } }
    @IBOutlet weak var amountTextField: UITextField! { didSet { amountTextField.delegate = self } }
    @IBOutlet weak var acctTextField: UITextField! { didSet { acctTextField.delegate = self } }
    @IBOutlet weak var merchantTextField: UITextField! { didSet { merchantTextField.delegate = self } }
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryTextField: UITextField! { didSet { categoryTextField.delegate = self } }
    @IBOutlet weak var transCategoryPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var categoryData:[AnyObject] = []
    var transaction: Transaction?
    
    let logHelper = LoggerHelper()
    let alertHelper = AlertHelper()
    
    let formatter = NSNumberFormatter()
    let dateFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.enabled = false
        
        // Do any additional setup after loading the view.
        self.transCategoryPicker.dataSource = self
        self.transCategoryPicker.delegate = self
        
        formatter.numberStyle = .CurrencyStyle
        dateFormatter.dateFormat = "yyyy-MM-dd"
        amountTextField.tag = 1
        dateTextField.tag = 2
        
        let infoDictionary = NSBundle.mainBundle().infoDictionary!
        categoryData = infoDictionary["categoryData"] as! [AnyObject]
        
        if let transaction = transaction {
            dateTextField.text = dateFormatter.stringFromDate(transaction.date)
            amountTextField.text = formatter.stringFromNumber(transaction.amount)
            acctTextField.text = "...12345"
            merchantTextField.text = transaction.merchant
            categoryTextField.text = transaction.category
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARk: -Actions
    @IBAction func splitTransaction(sender: UIButton) {
        //FUTURE: Split transactions (paid version?)
        alertHelper.showPremiumAlert("Cool huh?", message: "That's a premium feature. Please upgrade to the full version to get access to that feature.", log: "User wants the premium feature!")
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        logHelper.writeToLog("User did not save the changes")
        let isPresentingInAddTransactionMode = presentingViewController is UINavigationController
        
        if isPresentingInAddTransactionMode {
            dismissViewControllerAnimated(true, completion: nil)
        }else{
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // MARK: -Methods
    
    /// Purpose: Again, prohibit user from entering non numberic values to keep the app from crashing
    func checkValidNumber(newNumber: String) -> Bool {
        let checkNumber = formatter.numberFromString(newNumber)
        return checkNumber != nil
    }
    
    /// Purpose: Integrity check - make sure the user has input important values when adding a new transaction or updating an existing one
    func checkValidTransaction() {
        logHelper.writeToLog("Is the user creating a valid transaction entry?")
        
        if checkValidNumber(amountTextField.text!) {
            let amtText = amountTextField.text ?? ""
            let merchantText = merchantTextField.text ?? ""
            let categoryText = categoryTextField.text ?? ""
            saveButton.enabled = (!amtText.isEmpty && !merchantText.isEmpty && !categoryText.isEmpty)
        } else {
            alertHelper.showVCAlert("0-9 only!", message: "Please enter a valid number using numbers only.", fromController: self, log: "User attempted to use non numberic values in a spend category")
            saveButton.enabled = false
        }
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if self.saveButton === sender {
            logHelper.writeToLog("User is saving a new transaction")
            
            if dateTextField.text == "Date" {
                alertHelper.showVCAlert("Woah there!", message: "Please enter a valid date", fromController: self, log: "User is attempting to leave the date field blank")
            } else {
                let date = dateTextField.text ?? NSDate()
                let amount = amountTextField.text
                let merchant = merchantTextField.text ?? ""
                let category = categoryTextField.text ?? ""
                
                transaction = Transaction(username: "default", merchant: merchant, category: category, amount: formatter.numberFromString(amount!)!, date: dateFormatter.dateFromString(date as! String)!)
            }
        }
    }
    
    
    // MARK: -TextField 
    
    func textFieldDidBeginEditing(textField: UITextField){
        switch (textField.text!) {
            case "Amount":
                textField.text = "$"
                break
            case "Category":
                textField.text = ""
                break
            case "Merchant":
                textField.text = ""
                break
            case "Date":
                textField.text = dateFormatter.stringFromDate(NSDate())
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 1 { checkValidTransaction() }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: - PickerView
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryData.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryData[row] as? String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = categoryData[row] as? String
    }

}
