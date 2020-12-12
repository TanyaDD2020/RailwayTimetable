//
//  OptionsListViewController.swift
//  RailwayTimetable
//
//  Created by Tanya Dimitrova on 12.12.20.
//

import Foundation
import UIKit

protocol OptionsListItemProtocol {
    associatedtype T: Equatable
    var key: T { get }
    var displayText: String { get }
}

struct OptionListItem<A: Equatable>: OptionsListItemProtocol {
    typealias T = A
    
    var key: A
    var displayText: String
}

protocol OptionsListViewControllerDelegate: class {
    func optionsListViewController<T:Equatable>(_: OptionsListViewController<T>, didSelect item: T)
}

class OptionsListViewController<B:Equatable>: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: OptionsListViewControllerDelegate?
    
    var options: [OptionListItem<B>]? {
        didSet {
            if isViewLoaded {
                populateTableView()
            }
        }
    }
    
    var selectedItem: B?{
        get {
            if let indexPath = tableView.indexPathForSelectedRow {
                return options?[indexPath.row].key
            }
            
            return nil
        }
        
        set {
            guard let index = options?.firstIndex(where: { (aListItem) -> Bool in
                return aListItem.key == newValue
            }) else {
                return
            }
            
            selectedOption = newValue
            
            if isViewLoaded {
                tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }
    
    private var selectedOption: B?
    
    private func populateTableView() {
        
    }
}
