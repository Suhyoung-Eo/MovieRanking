//
//  AccountViewController.swift
//  MovingRanking
//
//  Created by Suhyoung Eo on 2022/02/08.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var accountTextLabel: UILabel!
    @IBOutlet weak var accountButton: UIBarButtonItem!
    @IBOutlet weak var goToWishListButton: UIButton!
    @IBOutlet weak var goToGradeListButton: UIButton!
    @IBOutlet weak var goToCommentListButton: UIButton!
    @IBOutlet weak var emptyView: UIView!
    
    let viewModel = AccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goToWishListButton.layer.cornerRadius = goToWishListButton.frame.width / 40
        goToGradeListButton.layer.cornerRadius = goToGradeListButton.frame.width / 40
        goToCommentListButton.layer.cornerRadius = goToCommentListButton.frame.width / 40

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
    
    @IBAction func goToWishListButton(_ sender: Any) {
        if viewModel.userId == nil {
            AlertService.shared.alert(viewController: self, alertTitle: "서비스를 이용하려면 로그인하세요")
            return
        }
        
        performSegue(withIdentifier: K.SegueId.storageView, sender: K.Prepare.wishToWatchListView)
        print("goToWishListButton")
    }
    
    @IBAction func goToGradeListButton(_ sender: Any) {
        if viewModel.userId == nil {
            AlertService.shared.alert(viewController: self, alertTitle: "서비스를 이용하려면 로그인하세요")
            return
        }
        
        performSegue(withIdentifier: K.SegueId.storageView, sender: K.Prepare.gradeListView)
        print("goToGradeListButton")
    }
    
    @IBAction func goToCommentListButton(_ sender: Any) {
        if viewModel.userId == nil {
            AlertService.shared.alert(viewController: self, alertTitle: "서비스를 이용하려면 로그인하세요")
            return
        }
        
        performSegue(withIdentifier: K.SegueId.commentListView, sender: K.Prepare.userCommentView)
        print("goToCommentListButton")
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
    
    private func logOutAlert() {
        let alert = UIAlertController(title: "로그아웃하시겠습니까?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in self?.viewModel.logOut() })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
}
