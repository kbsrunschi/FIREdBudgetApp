//
//  EnumService.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/7/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//

import Foundation

enum DataError: ErrorType {
    case NoData, NoInternet, BadString, BadJSON
}

enum LoginError: ErrorType {
    case WrongUsernamme, WrongPassword, UserImageFailure, SignUpFailure
}