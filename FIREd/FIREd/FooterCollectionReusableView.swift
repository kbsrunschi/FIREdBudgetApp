//
//  FooterCollectionReusableView.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/27/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//

import UIKit
import MessageUI

class FooterCollectionReusableView: UICollectionReusableView, MFMailComposeViewControllerDelegate {
    
    let logHelper = LoggerHelper()
    
    // MARK: -Actions
    
    @IBOutlet weak var helpButton: UIButton!
    
    @IBAction func emailForHelp(sender: UIButton) {
        //email KBS to set up consult appt
        logHelper.writeToLog("User is attempting to email KBS for help")
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    // MARK: - Email Functions
    /// Attributions: https://www.andrewcbancroft.com/2014/08/25/send-email-in-app-using-mfmailcomposeviewcontroller-with-swift/#send-button-tapped
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["firedbudget@gmail.com"])
        //switch to be dynamic user name
        mailComposerVC.setSubject("User would like to set up a consulting session.")
        mailComposerVC.setMessageBody("Hello!", isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showSendMailErrorAlert() {
        logHelper.writeToLog("There was an error generating the consulting session email")
        let alertController = UIAlertController(title: "Uh oh!", message: "Your email failed to send. Please check your email configuration", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: {(alert: UIAlertAction!) -> Void in print("user did not have email set up")})
        alertController.addAction(OKAction)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
   
    
}
