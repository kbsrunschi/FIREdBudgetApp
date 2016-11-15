//
//  Themes.swift
//  DuckDuckGo
//
//  Created by Kathryn Smith on 7/26/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//
// Attribution: https://www.raywenderlich.com/108766/uiappearance-tutorial

import UIKit

let SelectedThemeKey = "SelectedKey"

enum Theme: Int {
    case Default, Dark, Light
    
    var barStyle: UIBarStyle {
        switch self {
        case .Default:
            return .Default
        case .Dark:
            return .Black
        case .Light:
            return .BlackTranslucent
        }
    }
    
    var mainColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red: 21.0/255.0, green: 177.0/255.0, blue: 230.0/255.0, alpha: 1.0)
            
        case .Dark:
            return UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        case .Light:
            return UIColor(red: 87.0/255.0, green: 188.0/255.0, blue: 95.0/255.0, alpha: 1.0)
        }
    }
    
    var tabBarBackgroundImage: UIImage? {
        return self == .Light ? UIImage(named: "tabBarBackground") : nil
    }
    
}

struct ThemeManager {
    static func currentTheme() -> Theme {
        if let storedTheme = NSUserDefaults.standardUserDefaults().valueForKey(SelectedThemeKey)?.integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .Default
        }
    }
    
    static func applyTheme(theme: Theme) {
        NSUserDefaults.standardUserDefaults().setValue(theme.rawValue, forKey: SelectedThemeKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let sharedApplication = UIApplication.sharedApplication()
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
    }
}

