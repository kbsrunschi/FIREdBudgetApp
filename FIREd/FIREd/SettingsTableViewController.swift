//
//  SettingsTableViewController.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/7/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//
// Purpose: General Settings for the user to set

import UIKit

class SettingsTableViewController: UITableViewController {
    
    var user: User?
    let logHelper = LoggerHelper()
    let alertHelper = AlertHelper()
    
    let sectionCounts = [0:1, 1:2, 2:2, 3:5]
    
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = loadUser() {
            user = currentUser
            emailLabel.text = user!.email
        } else {
            emailLabel.text = "default@uchicago.edu"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionCounts.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionCounts[section]!
    }
    
    /// Purpose: Configure the different rows programmatically, letting the user delete their account (future state), go to the settings app, or be directed to my person github page to log issues
    /// Attributions: http://stackoverflow.com/questions/37231463/tableviewcell-open-url-on-click-swift
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url: NSURL?
        
        switch indexPath.section {
        case 1:
            url = nil
            switch indexPath.row {
            case 1:
                alertHelper.showOKAlert("Coming soon!", message: "Soon you can be rid of us.", log: "User wants to delete their account")
            default:
                return
            }
        case 2:
            url = nil
            switch indexPath.row {
            case 1:
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
            default:
                return
            }
        case 3:
            switch indexPath.row {
            case 3:
                url = NSURL(string: "https://github.com/kbsrunschi/FIREdBudgetApp/issues")
            default:
                return
            }
        default:
            return
        }
        
        if url != nil {
            UIApplication.sharedApplication().openURL(url!)
        }
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: -Methods
    
    func loadUser() -> User? {
        return (NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? User)
    }

}
