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
    
    let viewModel = FirebaseViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 110
        
        navigationItem.title = "내계정"

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let userId = viewModel.userId {
            accountButton.title = "로그아웃"
            accountTextLabel.text = userId
        } else {
            accountButton.title = "로그인"
            accountTextLabel.text = "로그인 된 계정이 없습니다"
        }
    }
    
    @IBAction func accountButton(_ sender: Any) {
        
        if viewModel.userId != nil {
            logOutAlert()
        } else {
            performSegue(withIdentifier: K.SegueIdentifier.loginView, sender: sender)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let sender = sender as? String else { return }
        
        switch sender {
        case K.Prepare.wishToWatchView:
            guard let destinationVC = segue.destination as? StorageViewController else {
                fatalError("Could not found segue destination")
            }
            destinationVC.navigationItemTitle = K.Prepare.wishToWatchView
        case K.Prepare.estimateView:
            guard let destinationVC = segue.destination as? StorageViewController else {
                fatalError("Could not found segue destination")
            }
            destinationVC.navigationItemTitle = K.Prepare.estimateView
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
        let alert = UIAlertController(title: "로그아웃 하시겠습니까?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] action in self?.logOut() })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    private func logOut() {
        viewModel.logOut { [weak self] error in
            guard error == nil else {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self, alertTitle: "로그아웃에 실패했습니다", message: error?.localizedDescription)
                }
                return
            }
            self?.accountTextLabel.text = "로그인 된 계정이 없습니다"
            self?.accountButton.title = "로그인"
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.accountCell, for: indexPath)
        
        cell.selectionStyle = .none
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = UIColor(red: 0.98, green: 0.07, blue: 0.34, alpha: 1.00)
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 19.0)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = K.Prepare.wishToWatchView
        case 1:
            cell.textLabel?.text = K.Prepare.estimateView
        case 2:
            cell.textLabel?.text = K.Prepare.userCommentView
        default:
            cell.textLabel?.text = K.Prepare.wishToWatchView
        }
        
        return cell
    }
}

//MARK: - Tableview delegate methods

extension AccountViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if viewModel.userId == nil {
            AlertService.shared.alert(viewController: self, alertTitle: "서비스를 이용하려면 로그인 하세요")
            return
        }
        
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: K.SegueIdentifier.storageView, sender: K.Prepare.wishToWatchView)
        case 1:
            performSegue(withIdentifier: K.SegueIdentifier.storageView, sender: K.Prepare.estimateView)
        case 2:
            // performSegue(withIdentifier: K.SegueIdentifier.movieInfoView, sender: K.Prepare.userCommentView)
            break
        default:
            break
        }
    }
}
