//
//  LoginViewController.swift
//  MovingRanking
//
//  Created by Suhyoung Eo on 2022/02/08.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameStackView: UIStackView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var backwordButton: UIBarButtonItem!
    @IBOutlet weak var registerButton: UIBarButtonItem!
    
    private let viewModel = AccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.gotErrorStatus = { [weak self] in
            if self?.viewModel.error == nil {
                self?.setView()
            } else {
                AlertService.shared.alert(viewController: self,
                                          alertTitle: "로그인에 실패했습니다",
                                          message: "아이디 또는 비밀번호가 틀렸거나 가입되지 않은 회원일 수 있습니다")
            }
        }
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setView()
        emailTextField.text = nil
        passwordTextField.text = nil
    }
    
    @IBAction func loginButton(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            viewModel.logIn(email: email, password: password)
        }
    }
    
    @IBAction func backwordButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerDisplayNameButton(_ sender: Any) {
        if let displayName = displayNameTextField.text, Bool.isDisplayNameValid(displayName) {
            viewModel.createProfileChangeRequest(displayName: displayName)
        } else {
            AlertService.shared.alert(viewController: self, alertTitle: "닉네임은 한글 또는 알파벳, 숫자만 사용할 수 있습니다")
        }
    }
    
    private func alertService() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "로그인에 성공했습니다", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in self?.dismiss(animated: true, completion: nil)})
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func setView() {
        if viewModel.userId != nil {
            loginStackView.isHidden = true
            
            if viewModel.displayName == nil {
                backwordButton.isEnabled = false
                registerButton.isEnabled = false
                displayNameStackView.isHidden = false
            } else {
                alertService()
            }
        }
    }
    
    deinit {
        print("deinit LoginViewController")
    }
}
