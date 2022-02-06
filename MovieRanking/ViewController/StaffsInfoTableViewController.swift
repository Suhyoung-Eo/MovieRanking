//
//  StaffsInfoTableViewController.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/06.
//

import UIKit

class StaffsInfoTableViewController: UITableViewController {
    
    var staffs = [Staff]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 60.0
        navigationItem.title = "출연/제작"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, for:.default)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
    }
    
    deinit {
        print("deinit StaffsInfoTableViewController")
    }
}

// MARK: - TableView data source

extension StaffsInfoTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staffs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseCell", for: indexPath)
        let staffs = staffs[indexPath.row]
        
        cell.selectionStyle = .none
        cell.textLabel?.text = "\(staffs.staffRoleGroup ?? ""): \(staffs.staffNm ?? "")"
        
        return cell
    }
}
