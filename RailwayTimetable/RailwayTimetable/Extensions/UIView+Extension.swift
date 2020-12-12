//
//  NSLayoutConstraint+Extension.swift
//  RailwayTimetable
//
//  Created by Tanya Dimitrova on 12.12.20.
//

import Foundation
import UIKit

extension UIView {
    
    func setWidth(_ width: CGFloat, multiplier: CGFloat = 1, priority: UILayoutPriority = .required) {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .width,
                                            multiplier: multiplier,
                                            constant: width)
        constraint.priority = priority
        
        superview?.addConstraint(constraint)
    }
    
    func setHeight(_ height: CGFloat, multiplier: CGFloat = 1, priority: UILayoutPriority = .required) {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .width,
                                            multiplier: multiplier,
                                            constant: height)
        constraint.priority = priority
        
        superview?.addConstraint(constraint)
    }
    
    func centerHorizontally(constant: CGFloat = 0, multiplier: CGFloat = 1, priority: UILayoutPriority = .required) {
        let constraint = NSLayoutConstraint(item: self,
                                           attribute: .centerX,
                                           relatedBy: .equal,
                                           toItem: superview,
                                           attribute: .centerX,
                                           multiplier: multiplier,
                                           constant: constant)
        constraint.priority = priority
        
        superview?.addConstraint(constraint)
    }
    
    func centerVertically(constant: CGFloat = 0, multiplier: CGFloat = 1, priority: UILayoutPriority = .required) {
        let constraint = NSLayoutConstraint(item: self,
                                           attribute: .centerY,
                                           relatedBy: .equal,
                                           toItem: superview,
                                           attribute: .centerY,
                                           multiplier: multiplier,
                                           constant: constant)
        constraint.priority = priority
        
        superview?.addConstraint(constraint)
    }
}
