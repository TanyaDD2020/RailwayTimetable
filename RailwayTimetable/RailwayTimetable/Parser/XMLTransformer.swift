//
//  XMLTransformer.swift
//  RailwayTimetable
//
//  Created by Tanya Dimitrova on 6.12.20.
//

import Foundation

class XMLTransformer: NSObject {
    
    private let parser: XMLParser
    
    private var currentValue: String = String()
    private var currentElement: Node?
    private var currentParent: Node?
    private var rootNode: Node?
    
    var parserError: Error?
    
    init(data: Data) {
        parser = XMLParser(data: data)
        super.init()
        parser.delegate = self
        
        // create the root node
        let rootTag = Tag(rawValue: "Root")
        rootNode = Node(tag: rootTag!, value: String(), attributes: [String:String]())
        
        currentParent = rootNode
    }
    
    func transform() throws -> Node? {
        
        parser.parse()
        if let e = parser.parserError {
            throw e
        }
        
        return rootNode
    }
}

extension XMLTransformer {
    
    enum Tag: String {
        case root = "Root"
        case stationsArray = "ArrayOfObjStation"
        case trainsArray = "ArrayOfObjStationData"
        case stopsArray = "ArrayOfObjTrainMovements"
        case trainInfo = "objStationData"
        case stationInfo = "objStation"
        case stopInfo = "objTrainMovements"
        case serverTime = "Servertime"
        case trainCode = "Traincode"
        case stationFullName = "Stationfullname"
        case stationCode = "Stationcode"
        case queryTime = "Querytime"
        case traindate = "Traindate"
        case origin = "Origin"
        case destination = "Destination"
        case originTime = "Origintime"
        case destinationTime = "Destinationtime"
        case status = "Status"
        case lastLocation = "Lastlocation"
        case duein = "Duein"
        case late = "Late"
        case expectedArrival = "Exparrival"
        case expectedDeparture = "Expdepart"
        case scheduledArrival = "Scharrival"
        case scheduledDeparture = "Schdepart"
        case direction = "Direction"
        case trainType = "Traintype"
        case locationType = "Locationtype"
        case stationDesc = "StationDesc"
        case stationAlias = "StationAlias"
        case stationLatitude = "StationLatitude"
        case stationLongitude = "StationLongitude"
        case stationCodeType2 = "StationCode"
        case stationId = "StationId"
        case trainCodeType2 = "TrainCode"
        case trainDateType2 = "TrainDate"
        case locationCode = "LocationCode"
        case locationFullName = "LocationFullName"
        case locationOrder = "LocationOrder"
        case locationTypeType2 = "LocationType"
        case trainOrigin = "TrainOrigin"
        case trainDestination = "TrainDestination"
        case scheduledArrivalType2 = "ScheduledArrival"
        case scheduledDepartureType2 = "ScheduledDeparture"
        case expectedArrivalType2 = "ExpectedArrival"
        case ExpectedDepartureType2 = "ExpectedDeparture"
        case arrival = "Arrival"
        case departure = "Departure"
        case autoArrival = "AutoArrival"
        case autoDepart = "AutoDepart"
        case stopType = "StopType"
    }
}

extension XMLTransformer: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        guard let tag = Tag(rawValue: elementName) else {
            return
        }
        
        currentValue = String()
        let element = Node(tag: tag, value: String(), attributes: attributeDict)
        currentParent?.addChild(element)
        
        currentElement = element
        currentParent = currentElement
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue.append(string)
        currentElement?.value = currentValue.isEmpty ? nil : currentValue
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        // trim whitespaces and new lines
        currentElement?.value = currentElement?.value?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        currentParent = currentParent?.parent
        currentElement = nil
        
    }
}

extension XMLTransformer {
    
    class Node {
        
        let tag: Tag
        var value: String?
        let attributes: [String : String]
        var children: [Node]
        weak var parent: Node?
        
        init(tag: Tag, value: String, attributes: [String : String]) {
            self.tag = tag
            self.value =  value
            self.attributes = attributes
            self.children = [Node]()
        }
        
        func addChild(_ node: Node) {
            children.append(node)
            node.parent = self
        }
    }
}
