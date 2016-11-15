//
//  SpendCategoriesController.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/21/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//
// Purpose: View where the user can edit the spend limits for commonly used spending categories.

import UIKit

class SpendCategoriesController: UITableViewController, UITextFieldDelegate {

    var mainCategoryLabels = [String]()
    var categoryImages = [String: UIImage]()
    var categories = [Category]()
    var delimiter = "-"
    var user: User?
    let formatter = NSNumberFormatter()
    
    let logHelper = LoggerHelper()
    let alertHelper = AlertHelper()
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logHelper.writeToLog("User is loading the saved category settings view")
        formatter.numberStyle = .CurrencyStyle

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        logHelper.writeToLog("Loading user and setting up the categories")
        if let savedUser = loadUser() {
            user = savedUser
        } else {
            user = User(username: "smithkb", password: "pass", isAuthenticated: false, userImage: UIImage(named: "fitness"), email: "smithkb@uchicago.edu", categoryLimits: [:])
        }
        
        let infoDictionary = NSBundle.mainBundle().infoDictionary!
        createMainCategories(infoDictionary["categoryData"] as! [String])
    }
    
    /// Purpose: Input the specific category strings and roll them up to high level categories for ease of calculations 
    /// Parameters: Array of strings of categories
    func createMainCategories(categoryData: [String]) {
        logHelper.writeToLog("Set up high level main categories for the user")
        for i in 0..<categoryData.count {
            let mainCategory = categoryData[i].componentsSeparatedByString(delimiter)
            
            if mainCategoryLabels.isEmpty {
                mainCategoryLabels.append(mainCategory[0])
            } else if !mainCategoryLabels.contains(mainCategory[0]) {
                mainCategoryLabels.append(mainCategory[0])
            }
            
            if user?.categoryLimits![mainCategory[0]] ==  nil {
                user?.categoryLimits![mainCategory[0]] = 0.00
            }
        }
        setUpCategoryImages()
        saveUser()
    }
    
    /// Link the categories with images to make for a better UIUX. Future state is to edit and pick their own images
    func setUpCategoryImages() {
        for i in 0..<mainCategoryLabels.count {
            categoryImages[mainCategoryLabels[i]] = getCategoryImage(mainCategoryLabels[i])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainCategoryLabels.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("categories", forIndexPath: indexPath) as! CategoryTableViewCell
        let category = mainCategoryLabels[indexPath.row]

        cell.categoryLimit.delegate = self
        
        cell.imageView?.image = categoryImages[category]
        cell.categoryLabel.text = category
        cell.categoryLimit.text = formatter.stringFromNumber((user?.categoryLimits![category])!)
        
        cell.categoryLimit.tag = indexPath.row
        cell.categoryLabel.tag = indexPath.row
        
        //update user profile if they change it
        if formatter.numberFromString(cell.categoryLimit.text!) != user?.categoryLimits![category] {
            user?.categoryLimits![category] = Double(formatter.numberFromString(cell.categoryLimit.text!)!)
        }
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            mainCategoryLabels.removeAtIndex(indexPath.row)
            //future: remove from plist
            user?.categoryLimits?.removeValueForKey(mainCategoryLabels[indexPath.row])
            saveUser()
            tableView.reloadData()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // MARK: -Action
    
    @IBAction func openCategoryDetail(sender: AnyObject) {
        alertHelper.showPremiumTCAlert("Cool huh?", message: "To edit categories, please upgrade!", fromController: self, log: "user is trying to open the category detail")
    }
    
    // Purpose: Go back to the main view
    @IBAction func cancelCategories(sender: UIBarButtonItem) {
        let isPresentingInAddTransactionMode = presentingViewController is UINavigationController
        
        if isPresentingInAddTransactionMode {
            dismissViewControllerAnimated(true, completion: nil)
        }else{
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // MARK: -Methods
    
    /// Purpsoe: The bottom text fields are hidden by the keyboard so this will move the view up so that users can type in the textfields
    /// Paramters: Bool whether to move up or down the view, CGFloat of the amount to move the view
    /// Attributions: http://www.jogendra.com/2015/01/uitextfield-move-up-when-keyboard.html
    func animateViewMoving(up: Bool, moveValue: CGFloat) {
        logHelper.writeToLog("Move the view up so that the textfield is not obscured by keyboard")
        let movementDuration: NSTimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue: moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
    }
    
    /// Purpose: Dont let users enter non-numeric values 
    /// Parameters: Textfield string
    /// Return: bool if its a valid number
    func checkValidNumber(newNumber: String) -> Bool {
        let checkNumber = formatter.numberFromString(newNumber)
        return checkNumber != nil
    }
    
    /// Purpose: Switch the category and get the matching image from the asset category
    /// Parameters: String category from the users stored plist
    /// Returns: UIImage from asset category
    func getCategoryImage(category: String) -> UIImage {
        switch (category.lowercaseString){
            case "housing":
                return UIImage(named: "housing")!
            case "utilities":
                return UIImage(named: "utilities")!
            case "food":
                return UIImage(named: "food")!
            case "debt":
                return UIImage(named: "debt")!
            case "savings":
                return UIImage(named: "savings")!
            case "transportation":
                return UIImage(named: "transportation")!
            case "gifts":
                return UIImage(named: "gift")!
            case "travel":
                return UIImage(named: "travel")!
            case "entertainment":
                return UIImage(named: "entertainment")!
            case "clothing/shoes":
                return UIImage(named: "clothing")!
            case "furniture":
                return UIImage(named: "furniture")!
            case "general merchandise":
                return UIImage(named: "general")!
            case "taxes":
                return UIImage(named: "taxes")!
            case "services":
                return UIImage(named: "services")!
            case "retirement savings":
                return UIImage(named: "investment")!
            case "education":
                return UIImage(named: "education")!
            case "hobbies":
                return UIImage(named: "hobbies")!
            case "atm/cash":
                return UIImage(named: "atm")!
            case "charitable giving":
                return UIImage(named: "donation")!
            case "child/dependent":
                return UIImage(named: "child")!
            case "insurance":
                return UIImage(named: "housing")!
            case "personal care":
                return UIImage(named: "personal")!
            case "pet care":
                return UIImage(named: "pet")!
            case "investment income":
                return UIImage(named: "investment")!
            case "paychecks/income":
                return UIImage(named: "income")!
        default:
            return UIImage(named: "bankcard")!
        }
    }
    
    func loadUser() -> User? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? User
    }
    
    func saveUser() {
        logHelper.writeToLog("User saved their user settings")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(user!, toFile: User.ArchiveURL.path!)
        
        if !isSuccessfulSave {
            logHelper.writeToLog("Failed to save user...")
        }
        
        print("Printing user limits after save: \(user?.categoryLimits)")
    }
    
    // MARK: - Navigation

    /// Either save the users profile and spend category limits or show the detail of a spend category, depending on what was clicked
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if self.saveButton === sender {
            logHelper.writeToLog("user is saving their changes in the Spend Categories view")
            
            let username = user?.username
            let password = user?.password
            let isAuthenticated = user?.isAuthenticated
            let email = user?.email
            let categoryLimits = user?.categoryLimits
            let userImage = user?.userImage
            
            user = User(username: username, password: password, isAuthenticated: isAuthenticated!, userImage: userImage, email: email, categoryLimits: categoryLimits)
            saveUser()
            
        } else if segue.identifier == "showCategoryDetail" {
//            logHelper.writeToLog("User is loading the category details view")
//            let cellController = (segue.destinationViewController as! UINavigationController).topViewController as! SpendDetailViewController
//            if let selectedSpendCategoryCell = sender as? CategoryTableViewCell {
//                let indexPath = tableView.indexPathForCell(selectedSpendCategoryCell)
//                let selectedCategory = categories[indexPath!.row]
//                cellController.category = selectedCategory
//            }
            logHelper.writeToLog("feature coming soon!")
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag >= (mainCategoryLabels.count - 4) {
            animateViewMoving(true, moveValue: 200)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        
        if textField.tag >= (mainCategoryLabels.count - 4) {
            animateViewMoving(false, moveValue: 200)
        }
        
        if checkValidNumber(textField.text!) {
            user?.categoryLimits![mainCategoryLabels[textField.tag]] = formatter.numberFromString(textField.text!)!
        } else {
            alertHelper.showAlert("0-9 only!", message: "Please enter a valid number using numbers only.", fromController: self, log: "User attempted to use non numberic values in a spend category")
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
