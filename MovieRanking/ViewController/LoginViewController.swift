//
//  LoginViewController.swift
//  MovingRanking
//
//  Created by Suhyoung Eo on 2022/02/08.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let viewModel = AccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.gotErrorStatus = { [weak self] in
            if let error = self?.viewModel.error {
                AlertService.shared.alert(viewController: self, alertTitle: "로그인에 실패했습니다", message: error.localizedDescription)
            } else {
                self?.alertService()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = nil
        passwordTextField.text = nil
    }
    
    @IBAction func loginButton(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            viewModel.logIn(email: email, password: password)
        }
    }
    
    private func alertService() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "로그인에 성공했습니다", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in self?.navigationController?.popViewController(animated: true)})
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    deinit {
        print("deinit LoginViewController")
    }
}
