//
//  TimelineTableCell.swift
//  RailwayTimeline
//
//  Created by Tanya Dimitrova on 5.12.20.
//

import UIKit

class TimelineTableCell: UITableViewCell {
    
    static let nibName = String(describing: TimelineTableCell.self)
    static let reuseIdentifier = "TrainInfoCell"
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var typeIconImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleOneLabel: UILabel!
    @IBOutlet weak var titleTwoLabel: UILabel!
    @IBOutlet weak var rightInfoLabel: UILabel!
    @IBOutlet weak var leftInfoLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupSubviews()
        setupStyles()
    }
    
    private func setupSubviews() {
        // setup border view
        borderView.layer.cornerRadius = 12.0
        borderView.layer.borderWidth = 1.0
        borderView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setupStyles() {
        // colors
        backgroundView = UIView(frame: self.bounds)
        backgroundView?.backgroundColor = UIColor.white
        
        titleOneLabel.textColor = UIColor.Text.headlineColor
        titleTwoLabel.textColor = UIColor.Text.headlineColor
        subtitleLabel.textColor = UIColor.Text.subheadlineColor
        leftInfoLabel.textColor = UIColor.Text.bodyColor
        rightInfoLabel.textColor = UIColor.Contrast.red
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// Setups the title, subtitle and body of the cell
    func configure(titleOne: String?, titleTwo: String?, subtitle: String?, leftInfoString: String?, rightInfoString: String? = nil) {
        titleOneLabel.text = titleOne
        titleTwoLabel.text = titleTwo
        subtitleLabel.text = subtitle
        leftInfoLabel.text = leftInfoString
        rightInfoLabel.text = rightInfoString
    }
}
