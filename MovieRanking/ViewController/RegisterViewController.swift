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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    @IBAction func registerButton(_ sender: Any) {
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit RegisterViewController")
    }
}
