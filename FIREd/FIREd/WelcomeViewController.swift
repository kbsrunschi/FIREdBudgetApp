//
//  WelcomeViewController.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/24/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var faqLabel: UITextView!
    
    let logHelper = LoggerHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logHelper.writeToLog("user launched the FAQ modal")
        
        faqLabel.layer.shadowOffset = CGSizeMake(0, 2.0)
        faqLabel.layer.cornerRadius = 5.0
        faqLabel.layer.shadowOpacity = 1.0
        faqLabel.layer.shadowColor = UIColor.blackColor().CGColor
        faqLabel.layer.shadowOffset = CGSizeZero
        faqLabel.layer.shadowRadius = 10

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
