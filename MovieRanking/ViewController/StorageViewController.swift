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
        viewModel.storageVMDelegate = self
        fetchList()
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
    
    private func fetchList() {
        if navigationItemTitle == K.Prepare.wishToWatchListView {
            emptyImage.isHidden = true
            viewModel.loadWishToWatchList()
        } else {
            emptyImage.isHidden = true
            viewModel.loadGradeList()
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
        
        if navigationItemTitle == K.Prepare.wishToWatchListView {
            let cellItem = viewModel.wishToWatchListModel.wishToWatchModel(indexPath.row)
            cell.imageView.setImage(from: cellItem.thumbNailLink)
            cell.movieNameLabel.text = cellItem.movieName
            cell.gradeLabel.text = viewModel.gradeAverageList[indexPath.row]
            cell.gradeLabel.textColor = .darkGray
        } else {
            let cellItem = viewModel.gradeListModel.gradeModel(indexPath.row)
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
        viewModel.fetchMovieInfo(by: navigationItemTitle, index: indexPath.row)
    }
}

//MARK: - ViewModel delegate methods

extension StorageViewController: StorageViewModelDelegate {
    
    func didUpdate() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if self.viewModel.isExistItems(by: self.navigationItemTitle) {
                self.emptyImage.isHidden = true
            } else {
                self.emptyImage.isHidden = false
            }
            self.collectionView.reloadData()
        }
    }
    
    func didUpdateMovieInfo() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.viewModel.isMovieInfoModelEmpty {
                AlertService.shared.alert(viewController: self, alertTitle: "영화 정보를 불러올 수 없습니다")
            } else {
                self.performSegue(withIdentifier: K.SegueId.movieInfoView, sender: nil)
            }
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            AlertService.shared.alert(viewController: self, alertTitle: "Error", message: error.localizedDescription)
        }
    }
}
