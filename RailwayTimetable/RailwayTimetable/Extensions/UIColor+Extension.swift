//
//  UIColor+Extension.swift
//  RailwayTimetable
//
//  Created by Tanya Dimitrova on 5.12.20.
//

import Foundation
import UIKit

extension UIColor {
    
    enum Text {
        static let headlineColor: UIColor = UIColor.black
        static let subheadlineColor: UIColor = UIColor(red: 49.0/255.0,
                                                       green: 67.0/255.0,
                                                       blue: 81.0/255.0,
                                                       alpha: 1.0)
        static let bodyColor: UIColor = UIColor(red: 121.0/255.0,
                                                green: 136.0/255.0,
                                                blue: 147.0/255.0,
                                                alpha: 1.0)
    }
    
    enum Contrast {
        static let red: UIColor = UIColor.red
        static let green: UIColor = UIColor.green
        static let yellow: UIColor = UIColor.blue
    }
    
}
