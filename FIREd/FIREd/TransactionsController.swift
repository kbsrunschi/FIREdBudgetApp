//
//  TransactionsController.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/7/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//
// Purpose: Let the user view and add transactions
//

import UIKit

class TransactionsController: UITableViewController, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var transactionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    var transactions = [Transaction]()
    var categoryLimits = [String: NSNumber]()
    var categoryPercentLimits = [String: Double]()
    var user: User?
    var delimiter = "-"
    let INCOME_LABEL = "Paychecks/Income"
    
    //Helpers
    let formatter = NSNumberFormatter()
    let pctFormatter = NSNumberFormatter()
    let dateFormatter = NSDateFormatter()
    let logHelper = LoggerHelper()
    let alertHelper = AlertHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logHelper.writeToLog("user is viewing the Transaction Table")
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        formatter.numberStyle = .CurrencyStyle
        pctFormatter.numberStyle = .PercentStyle
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let savedTransactions = loadTransactions(){
            transactions += savedTransactions
        } else{
            loadSampleTransactions()
        }
        
        // get common categories from the plist, future state: only get what is in user's spend categories profile
        let infoDictionary = NSBundle.mainBundle().infoDictionary!
        var categoryData = infoDictionary["categoryData"] as! [String]
        
        //set up current user limits
        if let currentUser = loadUser() {
            user = currentUser
            categoryLimits = (user!.categoryLimits)!
        } else  {
            print("new user")
            //new user - defaults $100
            for i in 0..<categoryData.count {
                let mainCategory = categoryData[i].componentsSeparatedByString(delimiter)
                categoryLimits[mainCategory[0]] = formatter.numberFromString("100.00")
            }
        }
        
        alertUserCloseOrOverLimit()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - TV DataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        
        let totalIncome = getTotals("income")
        let totalSpend = getTotals("spend")
        
        //format as numbers
        let currIncome = formatter.stringFromNumber(totalIncome)
        let currSpend = formatter.stringFromNumber(totalSpend)

        //total income
        let incomeLabel = UILabel(frame: CGRectMake(10, 10, 200, 20))
        incomeLabel.text = "Income: \(currIncome!)"
        incomeLabel.font = UIFont(name: "AmericanTypewriter-Bold", size: 18)
        
        //total spend
        let spendLabel = UILabel(frame: CGRectMake(210, 10, 200, 20))
        spendLabel.text = "Spent: \(currSpend!)"
        spendLabel.font = UIFont(name: "AmericanTypewriter-Bold", size: 18)
        
        vw.addSubview(incomeLabel)
        vw.addSubview(spendLabel)
        return vw
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("transactions", forIndexPath: indexPath) as! TransactionTableViewCell
        //Fetches appropriate transaction from data source layout
        
        let transaction = transactions[indexPath.row]
        let category = getMainSpendCategory(transaction.category)
        //prevent INF, hopefully a very large number will alert the user to setting a value that isn't 0
        let categoryLimit = categoryLimits[category]?.doubleValue != 0.0 ? categoryLimits[category]?.doubleValue : 1.0
        let amount = Double(transaction.amount)
        
        cell.amountLabel.text = formatter.stringFromNumber(transaction.amount)
        cell.categoryLabel.text = transaction.category
        cell.transactionLabel.text = transaction.merchant
        
        cell.percentLabel.text = categoryLimit != nil ? pctFormatter.stringFromNumber(amount/categoryLimit!): "0%"
        
        //add percent to the percent array for tracking
        if categoryLimit != nil {
            addAmountToRunningTotal(category, amount: (amount/categoryLimit!))
        }

        return cell
    }
 

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            transactions.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            saveTransactions()
            tableView.reloadData()
        } else if editingStyle == .Insert {
            //we let them insert a new transaction below
        }    
    }
    
    // MARK: -Methods
    
    /// Update running total of percents given new transactions
    /// Paramters: String category so the app knows which category to add the new transaction to, and Double amount so it knows how much to increement it by
    func addAmountToRunningTotal(category: String, amount: Double){
        var temp:Double = categoryPercentLimits[category]!
        temp += amount
        categoryPercentLimits[category] = temp
    }
    
    /// Checks the categoryPercentLimits dictionary to see if the user is near or over their limits and sends them an alert.
    /// Future state: push notification.
    /// Checks the cum sum of the percents and when the amount goes over the limits, an alert is shown
    func alertUserCloseOrOverLimit() {
        logHelper.writeToLog("Checking if the user is over their limit")
        
        //get days left for alerts
        let daysRemaining = getDaysRemainingInMonth()
        
        for i in 0..<transactions.count {
            let categoryKey = getMainSpendCategory(transactions[i].category)
            let temp = categoryPercentLimits[categoryKey]!
            if temp >= 0.75 && temp < 1.00 {
                
                alertHelper.showOKAlert("Getting close!", message: "Careful! You are almost at your limit for \(categoryKey). Remember you still have \(daysRemaining) left", log: "User is above 75% spending in \(categoryKey) but less than 100%")
                
            } else if temp >= 1.00 {
                
                alertHelper.showOKAlert("OH NO!", message: "You're at your limit for \(categoryKey)! You still have \(daysRemaining) days left in the month, so go easy on the spending or checkout the Spend Categories to transfer funds", log: "User hit their max in category \(categoryKey)")
            
            }
        }
    }
    
    /// Helper function to get the number of days remaining in the month
    func getDaysRemainingInMonth() -> Int {
        //(today: Int, end: Int)
        let today = NSDate()
        let userCalendar = NSCalendar.currentCalendar()
        let todaysDay = userCalendar.component(.Day, fromDate: today)
        
        let fullEndOfMonth = NSDate().endOfMonth()
        let endOfMonthDay = userCalendar.component(.Day, fromDate: fullEndOfMonth!)
        
        return endOfMonthDay - todaysDay
    }
    
    /// Takes a string and gets the rolled up category (eg Housing - Rent will return Housing)
    func getMainSpendCategory(categoryData: String) -> String {
        let catKey = categoryData.componentsSeparatedByString(delimiter)[0]
        categoryPercentLimits[catKey] = 0.0
        return catKey
    }
    
    /// Updates the running totals at the top of the view with the new transaction
    /// Paramters: Type will be Income or Spend
    func getTotals(type: String) -> Double {
        var total = 0.0
        
        for i in 0..<transactions.count {
            if type == "income" {
                if transactions[i].category == INCOME_LABEL {
                    total += (transactions[i].amount).doubleValue
                }
            } else {
                if transactions[i].category != INCOME_LABEL {
                    total += (transactions[i].amount).doubleValue
                }
            }
        }
        return total
    }
    
    func loadSampleTransactions(){
        logHelper.writeToLog("Loading sample transactions")
        let tempDate = NSDate()
        
        let trans1 = Transaction(username: "default", merchant: "Trader Joes", category: "Food - Groceries", amount: 100.00, date: tempDate)
        let trans2 = Transaction(username: "default", merchant: "Chicago Housing", category: "Housing - Mortgage/Rent", amount: 700.00, date: tempDate)
        let trans3 = Transaction(username: "default", merchant: "Starbucks", category: "Food -  Coffee Shops", amount: 5.00, date: tempDate)
        
        transactions += [trans1!, trans2!, trans3!]
    }
    
    func loadUser() -> User? {
        return (NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? User)
    }
    
    func loadTransactions() -> [Transaction]? {
        logHelper.writeToLog("User loaded transactions")
        return (NSKeyedUnarchiver.unarchiveObjectWithFile(Transaction.ArchiveURL.path!) as? [Transaction])
    }
    
    func saveTransactions() {
        logHelper.writeToLog("User saved their transactions")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(transactions, toFile: Transaction.ArchiveURL.path!)
        
        if !isSuccessfulSave {
            logHelper.writeToLog("Failed to save transactions...")
        }
        alertUserCloseOrOverLimit()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        logHelper.writeToLog("segueing to the transaction detail view")
        
        if segue.identifier == "showTransactionDetail" {
            logHelper.writeToLog("user is viewing a saved transaction")
            let cellController = (segue.destinationViewController as! UINavigationController).topViewController as! TransactionDetailViewController
            if let selectedTransactionCell = sender as? TransactionTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedTransactionCell)
                let selectedTrans = transactions[indexPath!.row]
                cellController.transaction = selectedTrans
            }
            
        } else if segue.identifier == "addTransaction" {
            logHelper.writeToLog("Adding a new transaction")
        }
    }
    
    @IBAction func unwindToTransaction(sender: UIStoryboardSegue){
        logHelper.writeToLog("unwinding from the detail view")
        
        if let sourceViewController = sender.sourceViewController as? TransactionDetailViewController, transaction = sourceViewController.transaction {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                //update existing transactions
                transactions[selectedIndexPath.row] = transaction
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .Fade)
            }
            else {
                // Add a new transaction
                let newIndexPath = NSIndexPath(forRow: transactions.count, inSection: 0)
                transactions.insert(transaction, atIndex: 0)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Top)
            }
            
            saveTransactions()
            tableView.reloadData()
        }
    }

}

/// Attributions: http://stackoverflow.com/questions/33605816/first-and-last-day-of-the-current-month-in-swift
extension NSDate {
    func startOfMonth() -> NSDate? {
        guard
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = cal.components([.Year, .Month], fromDate: self) else { return nil }
        comp.to12pm()
        return cal.dateFromComponents(comp)!
    }
    
    func endOfMonth() -> NSDate? {
        guard
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = NSDateComponents() else { return nil }
        comp.month = 1
        comp.day -= 1
        comp.to12pm()
        return cal.dateByAddingComponents(comp, toDate: self.startOfMonth()!, options: [])!
    }
}

internal extension NSDateComponents {
    func to12pm() {
        self.hour = 12
        self.minute = 0
        self.second = 0
    }
}
