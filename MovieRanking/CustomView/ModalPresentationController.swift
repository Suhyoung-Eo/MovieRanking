//
//  ModalPresentationController.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/04.
//

import UIKit

//MARK: - OptionTableViewController 커스텀 Presentation 설정
class ModalPresentationController: UIPresentationController {
    
    let blurEffectView: UIVisualEffectView!
    var tapGestureRecognizer = UITapGestureRecognizer()
    var check = false
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        super.init(presentedViewController: presentedViewController, presenting: presentedViewController)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.isUserInteractionEnabled = true
        blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(x: 0, y: containerView.frame.height * (7.3 / 10.0), width: containerView.frame.width, height: containerView.frame.height * (2.7 / 10.0))
    }
    
    // 모달 올라갈 때 뒷 배경 처리
    override func presentationTransitionWillBegin() {
        blurEffectView.alpha = 0
        containerView!.addSubview(blurEffectView)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.blurEffectView.alpha = 0.6 }, completion: nil)
    }
    
    // 모달 사라질 때 뒷 배경 처리
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.blurEffectView.alpha = 0
        }, completion: { [weak self] _ in
            self?.blurEffectView.removeFromSuperview()
        })
    }
    
    // 모달의 크기가 조절됐을 때 호출되는 함수
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        blurEffectView.frame = containerView!.bounds
    }
    
    @objc func dismissController() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit ModalPresentationController")
    }
}
