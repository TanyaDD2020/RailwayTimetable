//
//  RailwayManager.swift
//  RailwayTimeline
//
//  Created by Tanya Dimitrova on 6.12.20.
//

import Foundation

enum RailwayManagerError: Error {
    case clientError
    case serverError
    case xmlParsingError
}


protocol RailwayManagerDelegate: class {
    func railwayManagerDidDownloadTimelines(_: RailwayManager, timelines: [TrainTimeline]?)
    
    func railwayManagerDidDownloadStations(_: RailwayManager, stations: [Station]?)
    
    func railwayManagerDownloadDidFinish(_: RailwayManager, error: Error)
}


struct TrainDownload {
    let train: Train
    weak var task: URLSessionTask?
}

struct TimelineDownloadState {
    // the trains which stops are being downloaded
    var activeTrains: [TrainDownload] = [TrainDownload]()
    
    // the timelines that are already downloaded
    var timelines: [TrainTimeline] = [TrainTimeline]()
    
    /// Saves the given timeline
    mutating func timelineDidDownload(_ timeline: TrainTimeline) {
        timelines.append(timeline)
    }
    
    /// Handles the completion of the download of the train stops
    mutating func trainDidDownload(_ train: TrainDownload) {
        activeTrains.removeAll { (aTrainDownload) -> Bool in
            aTrainDownload.train.identifier == train.train.identifier
        }
    }
    
    /// resets the state and cancels all tasks that are not needed any more
    mutating func reset() {
        for anActiveTrain in activeTrains {
            anActiveTrain.task?.cancel()
        }
        
        activeTrains.removeAll()
        timelines.removeAll()
    }
}

class RailwayManager {
    weak var delegate: RailwayManagerDelegate?
    
    private var getAllStationsTask: URLSessionTask?
    private var getTrainsFromStationTask: URLSessionTask?
    
    private var downloadState = TimelineDownloadState()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "dd MM yyyy"
        
        return formatter
    }()
    
    /// Gets all the available stations
    func getAllStations() {
        getAllStationsTask?.cancel()
        
        let encodedUrl = "http://api.irishrail.ie/realtime/realtime.asmx/getAllStationsXML".urlEncodedString
        
        let url = URL(string: encodedUrl!)!
        getAllStationsTask = URLSession.shared.dataTask(with: url )  { data, response, error in
            if let error = error {
                self.handleClientError(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                self.handleServerError(response)
                return
            }
            if let data = data,
               data.count > 0 {
                let parser = StationsXMLParser(data: data)
                _ = parser.parse()
            }
        }
        getAllStationsTask!.resume()
    }
    
    /// Seaches for trains that first stop at `fromStation` and then stop at `toStation`
    func getAllTrains(form fromStation: String, to toStation: String)  {
        resetDownloadState()
        getTrainsFromStationTask?.cancel()
        
        let encodedUrl = "http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByNameXML?StationDesc=\(fromStation)".urlEncodedString
        let url = URL(string: encodedUrl!)!
        getTrainsFromStationTask = URLSession.shared.dataTask(with: url )  { data, response, error in
            if let error = error {
                self.handleClientError(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                self.handleServerError(response)
                return
            }
            if let data = data,
               data.count > 0 {
                
                let parser = StationTrainsXMLParser(data: data)
                if let trains = parser.parse(), trains.count > 0 {
                    self.downloadTimelines(trains: trains, startStation: fromStation, endStation: toStation)
                }
                else {
                    self.notifyDelegateThatDownloadFinished(timelines: nil)
                }
            }
        }
        getTrainsFromStationTask!.resume()
    }
    
    /// Download the stops for the given train and returns a timeline object if train stops first at `startStation` and then at `endStation`
    private func getTrainStops(train download: TrainDownload, date: Date, startStation: String, endStation: String) -> URLSessionTask {
        let trainCode = download.train.identifier
        
        let dateString = dateFormatter.string(from: date)
        
        let encodedUrl = "http://api.irishrail.ie/realtime/realtime.asmx/getTrainMovementsXML?TrainId=\(trainCode)&TrainDate=\(dateString)".urlEncodedString
        
        let url = URL(string: encodedUrl!)!
        let task = URLSession.shared.dataTask(with: url )  { data, response, error in
            if let error = error {
                self.handleClientError(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                self.handleServerError(response)
                return
            }
            if let data = data,
               data.count > 0 {
                
                let parser = TrainStopsXMLParser(data: data)
                
                var timeline: TrainTimeline?
                if let trainStops = parser.parse(), trainStops.count > 0{
                    timeline = self.getTimeline(train: download.train, trainStops: trainStops, startStation: startStation, endStation: endStation)
                }
                self.handleTimelineDidDownload(timeline, train: download)
            }
        }
        
        return task
    }
    
    /// Creates a timeline object if the given train stops first at `startStation` and then at `endStation`
    func getTimeline(train: Train, trainStops: [TrainStop], startStation: String, endStation: String) -> TrainTimeline? {
        let startStationString = startStation.uppercased()
        let endStationString = endStation.uppercased()
        
        var startTrainStop: TrainStop? = nil
        var endTrainStop: TrainStop? = nil
        
        for aStop in trainStops {
            if aStop.stationName.uppercased() == endStationString {
                // we found the stops
                if startTrainStop != nil {
                    endTrainStop = aStop
                    break
                }
                // there are no stops matching
                else {
                    break
                }
            }
            
            if aStop.stationName.uppercased() == startStationString {
                startTrainStop = aStop
            }
        }
        
        guard startTrainStop != nil && endTrainStop != nil else {
            return nil
        }
        
        return TrainTimeline(train: train,
                             startStop: startTrainStop,
                             endStop: endTrainStop)
    }
    
    /// Handles client error and notifies the delegate
    func handleClientError(_ error: Error) {
        
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.railwayManagerDownloadDidFinish(strongSelf,  error:RailwayManagerError.clientError)
            }
        }
    }
    
    /// Handles server error and notifies the delegate
    func handleServerError(_ response: URLResponse?) {
        
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.railwayManagerDownloadDidFinish(strongSelf,  error:RailwayManagerError.serverError)
            }
        }
    }
    
    /// Resets the download state
    func resetDownloadState() {
        objc_sync_enter(self)
        downloadState.reset()
        objc_sync_exit(self)
    }
    
    /// Initiates the download of the timelines for each train that stops at `startStation` and then at `endStation`
    func downloadTimelines(trains: [Train], startStation: String, endStation: String) {
        objc_sync_enter(self)
        
        for aTrain in trains {
            var trainDownload = TrainDownload(train: aTrain)
            let task = getTrainStops(train: trainDownload, date: Date(), startStation: startStation, endStation: endStation)
            trainDownload.task = task
            downloadState.activeTrains.append(trainDownload)
            task.resume()
        }
        
        objc_sync_exit(self)
    }
    
    /// Handles the download of the timeline for the given train
    func handleTimelineDidDownload(_ timeline: TrainTimeline?, train: TrainDownload) {
        objc_sync_enter(self)
        
        // add the timeline to the already downloaded timelines
        if let timeline = timeline {
            downloadState.timelineDidDownload(timeline)
        }
        
        // remove the train download from the active downloads
        downloadState.trainDidDownload(train)
        
        // the timeline of each train is downloaded
        if downloadState.activeTrains.count == 0 {
            // notify here
            
            let timelines = downloadState.timelines
            notifyDelegateThatDownloadFinished(timelines: timelines)
        }
        
        objc_sync_exit(self)
    }
    
    
    /// notifies the delegate that the download of timelines for all trains have finished
    private func notifyDelegateThatDownloadFinished(timelines: [TrainTimeline]?) {
        
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.railwayManagerDidDownloadTimelines(strongSelf, timelines: timelines)
                
                strongSelf.resetDownloadState()
            }
        }
    }
}
