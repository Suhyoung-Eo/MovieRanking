//
//  AlertService.swift
//  MovingMovie
//
//  Created by Suhyoung Eo on 2021/12/23.
//

import UIKit

class AlertService {
    
    static let shared = AlertService()
    
    func alert(viewController: UIViewController?,
               alertTitle: String,
               message: String? = nil,
               preferredStyle: UIAlertController.Style = .alert,
               actionTitle: String = "확인",
               style: UIAlertAction.Style = .default) {
        
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: actionTitle, style: style))
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    private init() {}
}
