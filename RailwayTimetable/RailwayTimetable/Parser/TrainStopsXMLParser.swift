//
//  TrainStopsXMLParser.swift
//  RailwayTimetable
//
//  Created by Tanya Dimitrova on 8.12.20.
//

import Foundation

class TrainStopsXMLParser: XMLTransformer {
    
    private lazy var dateFormetter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return formatter
    }()
    
    func parse() -> [TrainStop]? {
        guard let root = try? super.transform() else {
            return nil
        }
        
        guard let stopNodesArray = root.children.first?.children else {
            return nil
        }
        
        var result = [TrainStop]()
        
        var trainStop: TrainStop
        var tag: Tag
        var trainDate: String?
        var trainCode: String?
        var stationCode: String?
        var stationName: String?
        var stopOrder: Int = 0
        var stopType: TrainStopType = .stop
        var schedArrival: String?
        var schedDeparture: String?
        var arrival: String?
        var departure: String?
        for aNode in stopNodesArray {
            stopOrder = 0
            stopType = .timingPoint
            
            for aTagInfo in aNode.children {
                
                tag = aTagInfo.tag
                switch tag {
                case .trainDateType2:
                    trainDate = aTagInfo.value
                case .trainCodeType2:
                    trainCode = aTagInfo.value
                case .locationCode:
                    stationCode = aTagInfo.value
                case .locationFullName:
                    stationName = aTagInfo.value
                case .locationOrder:
                    if let stopOrderString = aTagInfo.value,
                       let theStopOrder = Int(stopOrderString) {
                        stopOrder = theStopOrder
                    }
                case .locationTypeType2:
                    if let stopTypeValue = aTagInfo.value,
                       let theStopType = TrainStopType(rawValue: stopTypeValue){
                        stopType = theStopType
                    }
                case .scheduledArrivalType2:
                    schedArrival = aTagInfo.value
                case .scheduledDepartureType2:
                    schedDeparture = aTagInfo.value
                case .arrival:
                    arrival = aTagInfo.value
                case .departure:
                    departure = aTagInfo.value
                default:
                    break
                }
            }
            
            if stopOrder > 0,
               stopType != .timingPoint ,
               let trainDate = trainDate,
               let trainCode = trainCode,
               let stationCode = stationCode,
               let stationName = stationName,
               let scheduledArrival = schedArrival,
               let scheduledDeparture = schedDeparture,
               let dateSchedArrival = dateFormetter.date(from: "\(trainDate) \(scheduledArrival)"),
               let dateSchedDeparture = dateFormetter.date(from: "\(trainDate) \(scheduledDeparture)")
            {
                
                
                var dateArrival: Date? = nil
                if let arrival = arrival {
                    dateArrival = dateFormetter.date(from: "\(trainDate) \(arrival)")
                }
                
                var dateDeparture: Date? = nil
                if let departure = departure {
                    dateDeparture = dateFormetter.date(from: "\(trainDate) \(departure)")
                }
                
                trainStop = TrainStop(trainCode: trainCode,
                                      stationCode: stationCode,
                                      stationName: stationName,
                                      stopOrder: stopOrder,
                                      scheduledArrival: dateSchedArrival,
                                      scheduledDeparture: dateSchedDeparture,
                                      arrival: dateArrival,
                                      departure: dateDeparture,
                                      stopType: stopType
                )
                
                result.append(trainStop)
            }
        }
        
        result.sort { (trainStop1, trainStop2) -> Bool in
            trainStop1.stopOrder < trainStop2.stopOrder
        }
        
        return result
    }
}
