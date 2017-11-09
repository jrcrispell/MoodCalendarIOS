//
//  AlertUtils.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 11/9/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import Foundation
import UIKit

class AlertUtils {
    static func makeSimpleAlert(title: String, message: String) -> UIAlertController {
        let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorAlert.addAction(okButton)
        return errorAlert
    }
}
