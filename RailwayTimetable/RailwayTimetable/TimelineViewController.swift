//
//  TimelineViewController.swift
//  RailwayTimetable
//
//  Created by Tanya Dimitrova on 6.12.20.
//

import UIKit

class TimelineViewController: UIViewController {
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatior: UIActivityIndicatorView!
    
    let railwayManager = RailwayManager()
    var timelines: [TrainTimeline]?
    
    lazy var hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // toolbarView
        toolbarView.layer.borderWidth = 1.0
        toolbarView.layer.borderColor = UIColor.lightGray.cgColor
        
        // tableView
        let cellNib = UINib(nibName: TimelineTableCell.nibName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TimelineTableCell.reuseIdentifier)
        
        tableView.rowHeight = 170
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        // activityIndicatior
        activityIndicatior.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatior.centerHorizontally()
        activityIndicatior.centerVertically()
        activityIndicatior.setWidth(44.0)
        activityIndicatior.setHeight(44.0)
        
        railwayManager.delegate = self
    }
    
    /// Swap the star and end station
    @IBAction func swapButtonPressed(_ sender: UIButton) {
        let tmpFromStration = fromTextField.text
        fromTextField.text = toTextField.text
        toTextField.text = tmpFromStration
    }
    
    /// Searches for trains that stops at `fromStation` and then at `endStation`
    @IBAction func serachButtonPressed(_ sender: UIButton) {
        guard let formStation = fromTextField.text,
              let toStation = toTextField.text else {
            activityIndicatior.stopAnimating()
            // present alert
            
            return
        }
        
        timelines = nil
        tableView.reloadData()
        
        activityIndicatior.startAnimating()
        
        DispatchQueue.global().async {[weak self] in
            self?.railwayManager.getAllTrains(form: formStation, to: toStation)
        }
    }
}

extension TimelineViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelines?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        
        guard let timelines = timelines,
              timelines.count > index else {
            return UITableViewCell()
        }
            
        let timeline = timelines[index]
        
        guard let timelineCell = tableView.dequeueReusableCell(withIdentifier: TimelineTableCell.reuseIdentifier,
                                                               for: indexPath) as? TimelineTableCell else {
            return UITableViewCell()
        }
        
        guard let startStop = timeline.startStop,
              let endStop = timeline.endStop else {
            return UITableViewCell()
        }
        
        let startDate = startStop.scheduledDeparture
        let endDate = endStop.scheduledArrival
        
        let startHour = hourFormatter.string(from: startDate)
        let endHour = hourFormatter.string(from: endDate)
        
        // The hour that the train departures from `fromStation`
        let titleOne = "\(startHour) \(startStop.stationName)"
        
        // The hour that the train arrives at `toStation`
        let titleTwo = "\(endHour) \(endStop.stationName)"
        
        // The train code and its origin and destination
        let train = timeline.train
        let rightArrow = "\u{2192}"
        let subtitle = "\(train.identifier) \(train.origin) \(rightArrow) \(train.desitination)"
        
        // The duration form start station to end station
        var leftInfoString = ""
        if let minutes = Calendar.current.dateComponents([.minute],
                                                         from: startDate,
                                                         to: endDate).minute {
            let hours: Int = minutes / 60
            let minutesLeft = minutes - (hours * 60)
            let minutesString = minutesLeft > 9 ? "\(minutesLeft)" : "0\(minutesLeft)"
            leftInfoString = "\(hours):\(minutesString)"
        }
        
        // the minutes late
        let minutesLate = train.minutesLate
        let rightInfoString = minutesLate > 0 ? "+\(minutesLate)min" : ""
        
        timelineCell.configure(titleOne: titleOne,
                               titleTwo: titleTwo,
                               subtitle: subtitle,
                               leftInfoString: leftInfoString,
                               rightInfoString: rightInfoString)
        
        timelineCell.selectionStyle = .none
        
        return timelineCell
    }
}


extension TimelineViewController: RailwayManagerDelegate {
    func railwayManagerDidDownloadTimelines(_: RailwayManager, timelines: [TrainTimeline]?) {
        self.timelines = timelines
        activityIndicatior.stopAnimating()
        tableView.reloadData()
    }
    
    func railwayManagerDidDownloadStations(_: RailwayManager, stations: [Station]?) {
    }
    
    func railwayManagerDownloadDidFinish(_: RailwayManager, error: Error) {
        timelines = nil
        activityIndicatior.stopAnimating()
        tableView.reloadData()
    }
}

