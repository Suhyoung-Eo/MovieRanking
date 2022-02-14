//
//  ImageViewController.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/06.
//

import UIKit

class ImageViewController: UIViewController {
    
    var imageLinks: [String] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var currentPage = 0   // 사진 저장시 사용할 인덱스
    private var viewTranslation = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePopView)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        tabBarController?.tabBar.isHidden = true
        navigationItem.title = "1 / \(imageLinks.count)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
        tabBarController?.tabBar.isHidden = false
        navigationItem.title = ""
    }
    
    @IBAction func pressedLeftBarButton(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func pressedRightButton(_ sender: Any) {
        DownloadImage.shared.download(from: imageLinks[currentPage]) { image in
            if let image = image {
                UIImageWriteToSavedPhotosAlbum(image,
                                               self,
                                               #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)),
                                               nil)
            }
        }
    }
    
    deinit {
        print("deinit ImageViewController")
    }
}

//MARK: - extension ImageViewController

extension ImageViewController {
    
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            AlertService.shared.alert(viewController: self,
                                      alertTitle: "사진 저장에 실패했습니다",
                                      message: error.localizedDescription,
                                      actionTitle: "확인")
        } else {
            AlertService.shared.alert(viewController: self,
                                      alertTitle: "사진이 저장되었습니다",
                                      message: nil,
                                      actionTitle: "확인")
        }
    }
    
    @objc private func handlePopView (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut,
                           animations: {
                self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
            })
        case .ended:
            if viewTranslation.y < 150, viewTranslation.y > -150 {
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 1,
                               options: .curveEaseOut,
                               animations: {
                    self.view.transform = .identity
                })
            } else {
                let transition = CATransition()
                transition.duration = 0.4
                transition.type = CATransitionType.fade
                navigationController?.view.layer.add(transition, forKey: kCATransition)
                navigationController?.popViewController(animated: false)
            }
        default:
            return
        }
    }
}

//MARK: - UICollectionView datasource methods

extension ImageViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageLinks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CellIdentifier.imageCollectionViewCell, for: indexPath) as? ImageCollectionViewCell else {
            fatalError("Could not found ViewCell")
        }
        cell.imageView.setImage(from: imageLinks[indexPath.row])
        return cell
    }
}

//MARK: - UICollectionView delegate methods

extension ImageViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        
        DispatchQueue.main.async {
            self.navigationItem.title = "\(self.currentPage + 1) / \(self.imageLinks.count)"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width  , height:  collectionView.frame.height)
    }
}
