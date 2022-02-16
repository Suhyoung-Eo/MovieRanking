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
    
    private let viewModel = FirebaseViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = nil
        passwordTextField.text = nil
    }
    
    @IBAction func loginButton(_ sender: Any) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            viewModel.logIn(email: email, password: password) { [weak self] error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        AlertService.shared.alert(viewController: self, alertTitle: "로그인에 실패 했습니다", message: error?.localizedDescription)
                    }
                    return
                }
                self?.alertService()
            }
        }
    }
    
    private func alertService() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "로그인에 성공 했습니다", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default) { action in self?.navigationController?.popViewController(animated: true) }
            alert.addAction(action)
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    deinit {
        print("deinit LoginViewController")
    }
}
