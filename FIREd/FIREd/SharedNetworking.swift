//
//  SharedNetworking.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/7/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//
// Purpose: Future state when server is wired up

import Foundation
import UIKit
import ImageIO

class SharedNetworking {
    // handle API requests
    
    static let sharedInstance = SharedNetworking()
    private init(){}
    let SCALE: CGFloat = 0.1
    
    enum WebService: String {
        case Post = "http://firedapp-140502.appspot.com/post/smithkb/"
        case Get = "http://firedapp-140502.appspot.com/user/smithkb/json/"
        case View = "http://firedapp-140502.appspot.com/user/smithkb/web/"
    }
}

extension SharedNetworking {
    // MARK : Connectivity Methods
    
    /// apiCallFailedAlert
    /// Parameters: None
    /// Returns: Alert the user that they are no connected to the internet
    func apiCallFailedAlert(){
        
        let alertController = UIAlertController(title: "Oh no!", message: "We were unable to complete your request. Please check your internet connection and try again", preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in print("User said they didn't want to try again")
        })
        
        alertController.addAction(OKAction)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /// isConnectedToInternet
    /// Parameters: none
    /// Returns: checks if the user is connected to the internet
    func isConnectedToInternet() -> Bool {
        let reachability: Reachability
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            return false
        }
        
        if reachability.isReachableViaWiFi() { return true}
        else if reachability.isReachableViaWWAN() { return true }
        else { return false }
    }
    
}