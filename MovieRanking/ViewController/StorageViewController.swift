//
//  StorageViewController.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import UIKit

class StorageViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyImage: UIImageView!
    
    private let viewModel = AccountViewModel()
    
    var navigationItemTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        emptyImage.isHidden = false
        
        navigationItem.title = navigationItemTitle
        
        viewModel.loadEstimateList { [weak self] error in self?.showAlert(by: error) }
        viewModel.loadWishToWatchList { [weak self] error in self?.showAlert(by: error) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? MovieInfoViewController else {
            fatalError("Could not found MovieInfoViewController")
        }
        
        destinationVC.movieInfo = viewModel.movieInfoModel

        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    deinit {
        print("deinit StorageViewController")
    }
}

//MARK: - extension StorageViewController

extension StorageViewController {
    
    private func showAlert(by error: Error?) {
        activityIndicator.stopAnimating()
        if let error = error {
            DispatchQueue.main.async {
                AlertService.shared.alert(viewController: self, alertTitle: "정보를 불러오지 못했습니다", message: error.localizedDescription)
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                if self?.viewModel.storageNumberOfItems(by: self?.navigationItemTitle ?? "") == 0 {
                    self?.emptyImage.isHidden = false
                } else {
                    self?.emptyImage.isHidden = true
                }
                self?.collectionView.reloadData()
            }
        }
    }
}

//MARK: - collectionView datasource methods

extension StorageViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.storageNumberOfItems(by: navigationItemTitle)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CellId.storageCell, for: indexPath) as? StorageCell else {
            fatalError("Could not found StorageCell")
        }
        
        if navigationItemTitle == K.Prepare.wishToWatchView {
            let cellItem = viewModel.wishToWatchListModel.wishToWatchListModel(indexPath.row)
            cell.imageView.setImage(from: cellItem.thumbNailLink)
            cell.movieNameLabel.text = cellItem.movieName
            cell.gradeLabel.text = cellItem.gradeAverage == 0 ? "평점이 없습니다" : "평균 ★ \(String(format: "%.1f", cellItem.gradeAverage))"
            cell.gradeLabel.textColor = .darkGray
        } else {
            let cellItem = viewModel.estimateListModel.estimateModel(indexPath.row)
            cell.imageView.setImage(from: cellItem.thumbNailLink)
            cell.movieNameLabel.text = cellItem.movieName
            cell.gradeLabel.text = "평가함 ★ \(cellItem.grade)"
        }
        
        return cell
    }
}

//MARK: - colletionView delegate methods

extension StorageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        viewModel.loadMovieInfo(by: navigationItemTitle, index: indexPath.row) { [weak self] error in
            if error != nil || self?.viewModel.movieInfoModel == nil {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self,
                                              alertTitle: "영화 정보를 불러올 수 없습니다",
                                              message: error?.localizedDescription)
                }
            } else {
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: K.SegueId.movieInfoView, sender: nil)
                }
            }
        }
    }
}
