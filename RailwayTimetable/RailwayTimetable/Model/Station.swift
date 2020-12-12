//
//  Station.swift
//  RailwayTimetable
//
//  Created by Tanya Dimitrova on 6.12.20.
//

import Foundation

struct Station {
    public let identifier: String
    public let code: String
    public let name: String
    public let alias: String?
    
    init(identifier: String, code: String, name: String, alias: String?) {
        self.identifier = identifier
        self.code = code
        self.name = name
        self.alias = alias
    }
}

