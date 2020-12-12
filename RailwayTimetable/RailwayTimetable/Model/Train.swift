//
//  Train.swift
//  RailwayTimetable
//
//  Created by Tanya Dimitrova on 6.12.20.
//

import Foundation


enum TrainStopType: String {
    case origin = "O"
    case stop = "S"
    case destination = "D"
    case timingPoint = "T"
}


struct Train {
    let identifier: String
    
    let origin: String
    let desitination: String
    
    let minutesLate: Int
    
    init(identifier: String, origin: String, desitination: String, minutesLate: Int = 0) {
        self.identifier = identifier
        self.origin = origin
        self.desitination = desitination
        self.minutesLate = minutesLate
    }
}

struct TrainStop {
    let trainCode: String
    
    let stationCode: String
    let stationName: String
    
    let stopType: TrainStopType
    let stopOrder: Int
    
    let scheduledArrival: Date
    let scheduledDeparture: Date

    let actualArrival: Date?
    let actualDeparture: Date?
    
    init(trainCode: String, stationCode: String, stationName: String, stopOrder: Int, scheduledArrival: Date, scheduledDeparture: Date, arrival: Date?, departure: Date?, stopType: TrainStopType = .stop) {
        self.trainCode = trainCode
        self.stationCode = stationCode
        self.stationName = stationName
        self.stopOrder = stopOrder
        self.scheduledArrival = scheduledArrival
        self.scheduledDeparture = scheduledDeparture
        self.actualArrival = arrival
        self.actualDeparture = departure
        self.stopType = stopType
    }
}

struct TrainTimeline {
    let train: Train
    let startStop: TrainStop?
    let endStop: TrainStop?
}

