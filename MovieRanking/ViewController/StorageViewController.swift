//
//  StorageViewController.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import UIKit

class StorageViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let FBViewModel = FirebaseViewModel()
    private let viewModel = MovieInfoViewModel()
    
    var navigationItemTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationItem.title = navigationItemTitle
        
        FBViewModel.loadEstimateList { [weak self] error in self?.showAlert(by: error) }
        FBViewModel.loadWishToWatchList { [weak self] error in self?.showAlert(by: error) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? MovieInfoViewController else {
            fatalError("Could not found segue destination")
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
        guard error == nil else {
            DispatchQueue.main.async {
                AlertService.shared.alert(viewController: self, alertTitle: "정보를 불러 오지 못 했습니다")
            }
            return
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

//MARK: - collectionView datasource methods

extension StorageViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FBViewModel.storageNumberOfItems(by: navigationItemTitle)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CellId.storageCell, for: indexPath) as? StorageCell else {
            fatalError("StorageCell is not founded")
        }
        
        if navigationItemTitle == K.Prepare.wishToWatchView {
            let cellItem = FBViewModel.wishToWatchListModel.wishToWatchListModel(indexPath.row)
            cell.imageView.setImage(from: cellItem.thumbNailLink)
            cell.movieNameLabel.text = cellItem.movieName
            cell.gradeLabel.text = cellItem.gradeAverage == 0 ? "평점이 없습니다" : "평균 ★ \(String(format: "%.1f", cellItem.gradeAverage))"
            cell.gradeLabel.textColor = .darkGray
        } else {
            let cellItem = FBViewModel.estimateListModel.estimateModel(indexPath.row)
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
        
        let movieInfo = FBViewModel.setMovieInfo(by: navigationItemTitle, index: indexPath.row)
        
        viewModel.fetchMovieInfo(Id: movieInfo.0, Seq: movieInfo.1) { [weak self] error in
            guard error == nil else {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self, alertTitle: "네트워크 장애", message: error?.localizedDescription)
                }
                return
            }
            
            if self?.viewModel.movieInfoModel == nil {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self, alertTitle: "해당 영화 정보가 없습니다")
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: K.SegueId.movieInfoView, sender: nil)
            }
        }
    }
}
