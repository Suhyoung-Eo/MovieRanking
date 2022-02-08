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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func loginButton(_ sender: Any) {
      
    }
    
    deinit {
        print("deinit LoginViewController")
    }
}

