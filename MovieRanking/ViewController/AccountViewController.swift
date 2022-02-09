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
            viewModel.logOut { [weak self] logOutError in
                guard logOutError == nil else {
                    AlertService.shared.alert(viewController: self,
                                              alertTitle: "로그아웃에 실패했습니다",
                                              message: logOutError,
                                              actionTitle: "확인")
                    return
                }
                self?.accountTextLabel.text = "로그인 된 계정이 없습니다"
                self?.accountButton.title = "로그인"
            }
        } else {
            performSegue(withIdentifier: K.SegueIdentifier.loginView, sender: sender)
        }
        
    }
    
    @IBAction func wishListButton(_ sender: Any) {
        
    }
    
    @IBAction func assessmentListButton(_ sender: Any) {
        
    }
}
