//
//  RegisterViewController.swift
//  MovingRankig
//
//  Created by Suhyoung Eo on 2022/02/08.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let viewModel = FirebaseViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    @IBAction func registerButton(_ sender: Any) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            viewModel.register(email: email, password: password) { [weak self] error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        AlertService.shared.alert(viewController: self, alertTitle: "회원 가입에 실패했습니다", message: error?.localizedDescription)
                    }
                    return
                }
                self?.alertService()
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func alertService() {
        let alert = UIAlertController(title: "회원 가입에 성공했습니다", message: "로그인 해 주세요", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            self?.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    deinit {
        print("deinit RegisterViewController")
    }
}
