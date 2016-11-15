//
//  LoginViewController.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/7/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//
//  Purpose: Shows the login screen. Lets the user submit login credentials, ask for a new passowrd, or sign up as a new user

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate {

    var user: User?
    
    let imagePickerController = UIImagePickerController()
    let cache = NSCache()
    let logHelper = LoggerHelper()
    let alertHelper = AlertHelper()
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var newUserLabel: UIButton!
    @IBOutlet weak var forgotPasswordLabel: UIButton!
    @IBOutlet weak var userImage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.username.delegate = self
        self.password.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //for now, mock out a new user
        if let currentUser = self.loadUser() {
            user = currentUser
        } else {
            user = User(username: "smithkb", password: "pass", isAuthenticated: false, userImage: UIImage(named: "fitness"), email: "smithkb@uchicago.edu", categoryLimits: [:])
        }
        
        logHelper.writeToLog("user launched the app and was unauthenticated so the login screen was called")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    /// Purpose: User can choose their user image. 
    /// Parameters: Button over the username textfield
    @IBAction func chooseImage(sender: UIButton) {
        
        print("user is trying to add a user photo")
        username.resignFirstResponder()
        password.resignFirstResponder()
        askTakeOrPicImage()
        self.logHelper.writeToLog("User has tried to update their user image")
    }
    
    /// Purpose: Let the user reset their password
    /// Slated for v1.1
    @IBAction func forgotPassword(sender: UIButton) {
        self.logHelper.writeToLog("User has tried to reset their password")
    }
    
    /// Purpose: Evaluates the text inputs to the username and password fields 
    /// Returns: Switches the user's auth variable to true if authenticated and dismisses the login to unwind to the Main Menu
    /// Else: Alert the user that either the username or password were invalid, turn off the activity indicator
    @IBAction func login(sender: AnyObject) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if isValidUser(self.username.text!, password: self.password.text!) {
            logHelper.writeToLog("User was authenticated")
            user?.isAuthenticated = true
            saveUserInfo()
            self.performSegueWithIdentifier("dismissLogin", sender: self)
        } else if self.username.text != user?.username{
            LoginError.WrongUsernamme
            self.logHelper.writeToLog("User submitted an incorrect username")
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        } else if self.password.text != user?.password{
            LoginError.WrongPassword
            self.logHelper.writeToLog("User submitted an incorrect password")
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        } else {
            self.logHelper.writeToLog("Uncaught log in error")
        }
    }
   
    /// Future state: Sign up a new user (create their user object in place of mocked data)
    @IBAction func signUpNewUser(sender: AnyObject) {
       logHelper.writeToLog("User tried to sign up")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Methods
    
    /// askTakeOrPickImage
    /// Parameters: None
    /// Returns: shows an alert that gives users two options : take picture or choose picture
    func askTakeOrPicImage() {
        
        self.logHelper.writeToLog("User was prompted to take or choose a picture")
        
        
        let alertController = UIAlertController(title:"Choose Image", message: "Would you like to take a picture or choose an image?", preferredStyle: .Alert)
        let takeImageAction = UIAlertAction(title: "Take Picture", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in print("user has decided to take their own picture")
            self.takeImage()
        })
        let chooseImageAction = UIAlertAction(title: "Choose Picture", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("user has decided to choose a picture")
            self.chooseImageFromGallery()
        })
        
        alertController.addAction(takeImageAction)
        alertController.addAction(chooseImageAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /// chooseImageFromGallery
    /// Parameters: None
    /// Returns: choose picture from camera roll
    func chooseImageFromGallery(){
        logHelper.writeToLog("User elected to choose image from gallery")
        imagePickerController.sourceType = .PhotoLibrary
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    /// isValidUserName
    /// Parameters: Takes two strings: username and password
    /// Returns: Bool letting the program know if the user has authenticated
    func isValidUser(username: String, password: String) -> Bool {
        if (username == user?.username) && (password == user?.password) {
            logHelper.writeToLog("User successfully signed in")
         return true
        } else if (username != user?.username) || (password != user?.password){
            alertHelper.showOKAlert("Try Agagin?", message: "Your username and/or password doesn't match our records.", log: "User did not successfully sign in and is getting another try.")
            return false
        } else {
            logHelper.writeToLog("Uncaught log in validation error")
            return false
        }
    }
    
    /// Get data from NSKeyedArchiver
    func loadUser() -> User? {
        return (NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? User)
    }
    
    /// Save data to NSKeyedArchiver
    func saveUserInfo() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(user!, toFile: User.ArchiveURL.path!)
        
        if !isSuccessfulSave {
            print ("Failed to save user")
        }
    }
    
    /// takeImage
    /// Parameters: None
    /// Returns: load the Camera so user can take a picture
    func takeImage(){
        self.logHelper.writeToLog("User elected to take image")
        imagePickerController.sourceType = .Camera
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    /// textFieldDidBeginEditing:
    /// - Note: Disable the save button while editing, clear out user text, make the password protected text
    func textFieldDidBeginEditing(textField: UITextField){
        loginButton.enabled = false
        textField.text = nil
        
        if (textField.restorationIdentifier == "password") {
            password.secureTextEntry = true
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        loginButton.enabled = true
    }

}

extension LoginViewController {
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        logHelper.writeToLog("user is selected a photo")
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        userImage.setImage(selectedImage, forState: .Normal)
        userImage.contentMode = .ScaleAspectFit
        user?.userImage = selectedImage
        
        self.logHelper.writeToLog("User saved a picture for their profile")
        
        saveUserInfo()
        
        //dismiss the picker
        dismissViewControllerAnimated(true, completion: nil)
    }
}
