//
//  OptionTableViewController.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2021/12/29.
//

import UIKit

protocol OptionTableViewControllerDelegate: AnyObject {
    func didSelectType(selectedType: Int, controller: UIViewController)
}

class OptionTableViewController: UITableViewController {
    
    private let viewModel = BoxOfficeViewModel()
    
    weak var delegate: OptionTableViewControllerDelegate?
    var boxOfficeType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.setBoxOfficeType(by: boxOfficeType)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseCell", for: indexPath)
        
        // cell 속성
        cell.selectionStyle = .none
        cell.tintColor = UIColor(red: 0.98, green: 0.07, blue: 0.34, alpha: 1.00)
        
        // cell value
        cell.textLabel?.text = viewModel.boxOfficeTypes[indexPath.row]
        cell.accessoryType =  viewModel.checkBoxOfficeType[indexPath.row] ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectType(selectedType: indexPath.row, controller: self)
    }
    
    deinit {
        print("deinit OptionTableViewController")
    }
}
