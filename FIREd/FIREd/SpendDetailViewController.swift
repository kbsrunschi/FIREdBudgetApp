//
//  SpendDetailViewController.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/28/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//

import UIKit

class SpendDetailViewController: UIViewController {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    var category: Category?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let category = category {
            categoryLabel.text = category.name
            amountLabel.text = category.amount
            image.image = category.image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "saveCategories" {
            print("saving cateogry data")
        }
     
    }
    

}
