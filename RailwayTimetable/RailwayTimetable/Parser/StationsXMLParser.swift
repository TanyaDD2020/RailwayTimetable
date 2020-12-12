//
//  StationsXMLParser.swift
//  RailwayTimetable
//
//  Created by Tanya Dimitrova on 8.12.20.
//

import Foundation

class StationsXMLParser: XMLTransformer {
    
    func parse() -> [Station]? {
        guard let root = try? super.transform() else {
            return nil
        }
        
        guard let stationNodesArray = root.children.first?.children else {
            return nil
        }
        
        var result = [Station]()
        
        var station: Station
        var tag: Tag
        var identifier: String?
        var code: String?
        var name: String?
        var alias: String?
        for aNode in stationNodesArray {
            for aTagInfo in aNode.children {
                tag = aTagInfo.tag
                switch tag {
                case .stationId:
                    identifier = aTagInfo.value
                case .stationCodeType2:
                    code = aTagInfo.value
                case .stationDesc:
                    name = aTagInfo.value
                case .stationAlias:
                    alias = aTagInfo.value
                default:
                    break
                }
            }
            
            if let stationId = identifier,
               let stationCode = code,
               let stationName = name {
                station = Station(identifier: stationId,
                                  code: stationCode,
                                  name: stationName,
                                  alias: alias)
                
                result.append(station)
            }
        }
        
        return result
    }
    
}
