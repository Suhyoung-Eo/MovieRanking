//
//  AccountViewController.swift
//  MovingRanking
//
//  Created by Suhyoung Eo on 2022/02/08.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var accountTextLabel: UILabel!
    @IBOutlet weak var accountButton: UIBarButtonItem!
    @IBOutlet weak var emptyView: UIView!
    
    let viewModel = AccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 110
        
        navigationItem.title = "내계정"
        
        viewModel.gotErrorStatus = { [weak self] in
            if let error = self?.viewModel.error {
                AlertService.shared.alert(viewController: self, alertTitle: "로그아웃에 실패했습니다", message: error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self?.emptyView.isHidden = false
                    self?.accountButton.title = "로그인"
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if let userId = viewModel.userId {
            emptyView.isHidden = true
            accountButton.title = "로그아웃"
            accountTextLabel.text = userId
        } else {
            emptyView.isHidden = false
            accountButton.title = "로그인"
        }
    }
    
    @IBAction func accountButton(_ sender: Any) {
        
        if viewModel.userId != nil {
            logOutAlert()
        } else {
            performSegue(withIdentifier: K.SegueId.loginView, sender: sender)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch sender as? String {
        case K.Prepare.wishToWatchListView:
            guard let destinationVC = segue.destination as? StorageViewController else {
                fatalError("Could not found StorageViewController")
            }
            destinationVC.navigationItemTitle = K.Prepare.wishToWatchListView
        case K.Prepare.gradeListView:
            guard let destinationVC = segue.destination as? StorageViewController else {
                fatalError("Could not found StorageViewController")
            }
            destinationVC.navigationItemTitle = K.Prepare.gradeListView
        case K.Prepare.userCommentView:
            break
        default:
            break
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
}

//MARK: - extension AccountViewController

extension AccountViewController {
    
    private func logOutAlert() {
        let alert = UIAlertController(title: "로그아웃하시겠습니까?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in self?.logOut() })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    private func logOut() {
        viewModel.logOut()
    }
}

//MARK: - TableView datasource methods

extension AccountViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.accountCell, for: indexPath)
        
        cell.selectionStyle = .none
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = UIColor(red: 0.98, green: 0.07, blue: 0.34, alpha: 1.00)
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 19.0)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = K.Prepare.wishToWatchListView
        case 1:
            cell.textLabel?.text = K.Prepare.gradeListView
        case 2:
            cell.textLabel?.text = K.Prepare.userCommentView
        default:
            break
        }
        
        return cell
    }
}

//MARK: - Tableview delegate methods

extension AccountViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if viewModel.userId == nil {
            AlertService.shared.alert(viewController: self, alertTitle: "서비스를 이용하려면 로그인하세요")
            return
        }
        
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: K.SegueId.storageView, sender: K.Prepare.wishToWatchListView)
        case 1:
            performSegue(withIdentifier: K.SegueId.storageView, sender: K.Prepare.gradeListView)
        case 2:
            performSegue(withIdentifier: K.SegueId.commentListView, sender: K.Prepare.userCommentView)
            break
        default:
            break
        }
    }
}
