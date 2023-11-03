//
//  CornerRadiusExtensions.swift
//  Indi
//
//  Created by Alexander Sivko on 30.10.23.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}
