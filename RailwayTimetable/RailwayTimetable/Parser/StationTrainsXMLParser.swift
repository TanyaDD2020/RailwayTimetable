//
//  StationTrainsXMLParser.swift
//  RailwayTimetable
//
//  Created by Tanya Dimitrova on 7.12.20.
//

import Foundation

class StationTrainsXMLParser: XMLTransformer {
    
    func parse() -> [Train]? {
        guard let root = try? super.transform() else {
            return nil
        }
        
        guard let trainNodesArray = root.children.first?.children else {
            return nil
        }
        
        var result = [Train]()
        
        var train: Train
        var tag: Tag
        var code: String?
        var origin: String?
        var destination: String?
        var minutesLate: Int = 0
        for aNode in trainNodesArray {
            for aTagInfo in aNode.children {
                tag = aTagInfo.tag
                switch tag {
                case .trainCode:
                    code = aTagInfo.value
                case .origin:
                    origin = aTagInfo.value
                case .destination:
                    destination = aTagInfo.value
                case .late:
                    if let lateString = aTagInfo.value,
                       let late = Int(lateString) {
                        minutesLate = late
                    }
                default:
                    break
                }
            }
            
            if let tarinCode = code,
               let startStation = origin,
               let endStation = destination {
                train = Train(identifier: tarinCode,
                              origin: startStation,
                              desitination: endStation,
                              minutesLate: minutesLate)
                
                result.append(train)
            }
        }
        
        return result
    }
}
