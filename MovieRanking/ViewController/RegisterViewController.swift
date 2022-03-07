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
    @IBOutlet weak var agreeSwitch: UISwitch!

    private let viewModel = AccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.gotErrorStatus = { [weak self] in
            if let error = self?.viewModel.error {
                AlertService.shared.alert(viewController: self,
                                          alertTitle: "회원 가입에 실패했습니다",
                                          message: error.localizedDescription)
            } else {
                self?.alertService()
            }
        }
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func registerButton(_ sender: Any) {
        if agreeSwitch.isOn {
            if let email = emailTextField.text, let password = passwordTextField.text {
                viewModel.register(email: email, password: password)
            }
        } else {
            AlertService.shared.alert(viewController: self,
                                      alertTitle: "이용 약관에 동의해주세요",
                                      message: "버튼을 클릭하여 이용약관에 동의할 수 있습니다")
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func alertService() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "회원 가입에 성공했습니다", message: "닉네임을 정해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in self?.dismiss(animated: true, completion: nil) })
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    deinit {
        print("deinit RegisterViewController")
    }
}
