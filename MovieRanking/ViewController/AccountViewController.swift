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
    @IBOutlet weak var wishListButton: UIButton!
    @IBOutlet weak var assessmentListButton: UIButton!
    
    let viewModel = FirebaseViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func accountButton(_ sender: Any) {
        
        if let _ = viewModel.userId {
            logOutAlert()
        } else {
            performSegue(withIdentifier: K.SegueIdentifier.loginView, sender: sender)
        }
        
    }
    
    private func logOutAlert() {
        let alert = UIAlertController(title: "로그아웃 하시겠습니까?", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            self?.logOut()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func logOut() {
        viewModel.logOut { [weak self] error in
            guard error == nil else {
                AlertService.shared.alert(viewController: self,
                                          alertTitle: "로그아웃에 실패했습니다",
                                          message: error?.localizedDescription,
                                          actionTitle: "확인")
                return
            }
            self?.accountTextLabel.text = "로그인 된 계정이 없습니다"
            self?.accountButton.title = "로그인"
        }
    }
    
    @IBAction func wishListButton(_ sender: Any) {
        
    }
    
    @IBAction func assessmentListButton(_ sender: Any) {
        
    }
}
