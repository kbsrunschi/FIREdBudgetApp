//
//  MainMenuController.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/7/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//
// Purpose: Main collection view of places the user can go. Main menu of navigation options
//

import UIKit
import CoreData
import MessageUI
import CoreLocation

private let monthView = "monthView"
private let lookAhead = "lookAhead"
private let transactions = "transactions"
private let fireSimulator = "fireSimulator"
private let rewards = "rewards"
private let trends = "trends"

class MainMenuController: UICollectionViewController, UINavigationControllerDelegate,
    MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    //var isUserAuthenticated: Bool
    var user: User?
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var _fetchedResultsController: NSFetchedResultsController? = nil
    var didReturnFromBackground = false
    let logHelper = LoggerHelper()
    let alertHelper = AlertHelper()
    
    // MARK: -Location Services
    let locationManager = CLLocationManager()
    
    // MARK: -Properties
    @IBOutlet weak var monthViewLabel: UILabel!
    @IBOutlet weak var monthAheadLabel: UILabel!
    @IBOutlet weak var transactionsLabel: UILabel!
    @IBOutlet weak var fireSimlabel: UILabel!
    @IBOutlet weak var rewardsLabel: UILabel!
    @IBOutlet weak var trendsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSUserDefaults.standardUserDefaults().stringForKey("firstLaunch") == nil {
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "firstLaunch")
            NSUserDefaults.standardUserDefaults().synchronize()
        } else {
            logHelper.writeToLog(NSUserDefaults.standardUserDefaults().stringForKey("firstLaunch")!)
        }

        // Do any additional setup after loading the view.
        self.collectionView?.delegate = self
        locationManager.delegate = self
        registeringUserAlerts()
        checkLocationPermissions()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        self.showLoginView()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: -Methods
    
    /// Attributions: https://www.raywenderlich.com/92667/securing-ios-data-keychain-touch-id-1password
    func appWillResignActive(notification : NSNotification) {
        view.alpha = 0
        user?.isAuthenticated = false
        didReturnFromBackground = true
        saveUser()
    }
    
    func appDidBecomeActive(notification : NSNotification) {
        if didReturnFromBackground {
            user?.isAuthenticated = false
            saveUser()
            self.showLoginView()
        }
    }
    
    /// Purpose: load the user
    func checkAuthStatusAndLoad() {
        if let savedUser = loadUser() {
            logHelper.writeToLog("loading current user")
            user = savedUser
        } else {
            logHelper.writeToLog("first time user")
            //TODO Delete for security purposes, direct user to sign up
            user = User(username: "smithkb", password: "pass", isAuthenticated: false, userImage: UIImage(named: "fitness"), email: "smithkb@uchicago.edu", categoryLimits: [:])
        }
    }
    
    /// Purpose: Check the location permissions and prompt user if they have not set any
    func checkLocationPermissions() {
        logHelper.writeToLog("Checking user location preferences")
        //check permissions
        let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        logHelper.writeToLog("User has the current location preferences set: \(authStatus)")
        
        switch (authStatus) {
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        case .Denied, .Restricted:
            presentLocationServicesAlert("Location Services", message: "Help us better serve you! Turn on location services for when the app is in use to help us with analytics.")
            return
        case .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
            return
        default:
            locationManager.requestWhenInUseAuthorization()
            return
        }
    }
    
    /// Load user from NSKeyedArchiver
    func loadUser() -> User? {
        return (NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? User)
    }
    
    /// Present the Location Services Alert and register their choice for location tracking
    func presentLocationServicesAlert(title: String, message: String) {
        self.logHelper.writeToLog("Letting the user know they can change their location services settings")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "Open Settings", style: .Default) { (alertAction) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alertAction) -> Void in }
        
        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func registeringUserAlerts() {
        let notificationTypes: UIUserNotificationType = [.Alert, .Badge]
        let notificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    /// Save user to NSKeyedArchiver
    func saveUser() {
        logHelper.writeToLog("User saved their user settings")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(user!, toFile: User.ArchiveURL.path!)
        
        if !isSuccessfulSave {
            print ("Failed to save user...")
        }
    }
    
    /// Purpose: If the user is not authenticated, show the login screen, otherwise change the alpha back to 1.0 so that the main menu is full color
    func showLoginView() {
        logHelper.writeToLog("checking if we should show the login view")
        checkAuthStatusAndLoad()
        if !(user?.isAuthenticated)! {
            self.logHelper.writeToLog("User was unauthenticated so the login screen was shown")
            self.performSegueWithIdentifier("showLogin", sender: self)
        } else {
            view.alpha = 1.0
        }
    }
    
    // MARK: - Actions
    
    /// To be released after integration with a third party framework
    @IBAction func takePictureOfReceipt(sender: AnyObject) {
        alertHelper.showOKAlert("Receipt Imaging", message: "This feature is coming soon!", log: "User wants to use the photo feature")
    }
    
    // MARK: - Navigation
    
    /// Purpose: Come back from the login screen and make necessary adjustments
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        if segue.identifier == "dismissLogin" {
            logHelper.writeToLog("User is done signing in and authenticated")
            user?.isAuthenticated = true
            checkAuthStatusAndLoad()
            view.alpha = 1.0
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.collectionView?.backgroundColor = UIColor.whiteColor()
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        
        if (indexPath.item == 0) {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(monthView, forIndexPath: indexPath) as! MainViewCell
        } else if (indexPath.item == 1) {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(lookAhead, forIndexPath: indexPath)
        }  else if (indexPath.item == 2) {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(transactions, forIndexPath: indexPath)
        } else if (indexPath.item == 3) {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(fireSimulator, forIndexPath: indexPath)
        } else if (indexPath.item == 4) {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(rewards, forIndexPath: indexPath)
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(trends, forIndexPath: indexPath)
        }
        
        cell.layer.shadowOffset = CGSizeMake(0, 2.0)
        cell.layer.cornerRadius = 5.0
        cell.layer.shadowOpacity = 1.0
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}

extension MainMenuController {
    
    /// Attributions: https://www.raywenderlich.com/78551/beginning-ios-collection-views-swift-part-2
    /// Purpose: Gain access to the header and footer of the collection view, the footer is used for the email integration link
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "mainHeader", forIndexPath: indexPath) as! HeaderCollectionReusableView
            return headerView
            
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "mainFooter", forIndexPath: indexPath) as! FooterCollectionReusableView
            return footerView
        default:
            assert(false, "Unexpected kind")
        }
    }
}

extension MainMenuController {
    // PUSH NOTIFICATIONS  - Future state
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        logHelper.writeToLog("Registered for Push notifications with \(deviceToken)")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        logHelper.writeToLog("Push subscription failed: \(error)")
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if let notification: UILocalNotification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            logHelper.writeToLog("Launch from location notification: \(notification)")
        }
        return true
    }
}
