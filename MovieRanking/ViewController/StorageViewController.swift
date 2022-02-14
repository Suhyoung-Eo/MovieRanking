//
//  StorageViewController.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import UIKit

class StorageViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let FBviewModel = FirebaseViewModel()
    private let viewModel = MovieInfoViewModel()
    
    var navigationItemTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationItem.title = navigationItemTitle
        
        loadCurrentUserCommentList()
        loadWishToWatchList()
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
    
    private func loadCurrentUserCommentList() {
        FBviewModel.loadCurrentUserCommentList { [weak self] error in
            guard error == nil else { self?.loadAlert(); return }
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func loadWishToWatchList() {
        FBviewModel.loadWishToWatchList { [weak self] error in
            guard error == nil else { self?.loadAlert(); return }
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func loadAlert() {
        DispatchQueue.main.async {
            AlertService.shared.alert(viewController: self,
                                      alertTitle: "정보를 불러 오지 못 했습니다",
                                      message: "",
                                      actionTitle: "확인")
        }
    }
}

//MARK: - collectionView datasource methods

extension StorageViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch navigationItemTitle {
        case K.Prepare.wishToWatchView:
            return FBviewModel.wishToWatchListCount
        case K.Prepare.estimateView:
            return FBviewModel.currentUserCommentCount
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CellIdentifier.storageCell, for: indexPath) as? StorageCell else {
            fatalError("StorageCell is not founded")
        }
        
        if navigationItemTitle == K.Prepare.wishToWatchView {
            let cellItem = FBviewModel.wishToWatchListModel.wishToWatchListModel(indexPath.row)
            cell.imageView.setImage(from: cellItem.thumbNailLink)
            cell.movieNameLabel.text = cellItem.movieName
            cell.gradeLabel.text = cellItem.gradeAverage == 0 ? "평점이 없습니다" : "평균 ★ \(String(format: "%.1f", cellItem.gradeAverage))"
            cell.gradeLabel.textColor = .darkGray
        } else {
            let cellItem = FBviewModel.currentUserCommentListModel.currentUserCommentModel(indexPath.row)
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
        
        let movieInfo = FBviewModel.setMovieInfo(by: navigationItemTitle, index: indexPath.row)
        let movieId = movieInfo.0
        let movieSeq = movieInfo.1
        
        viewModel.fetchMovieInfo(Id: movieId, Seq: movieSeq) { [weak self] error in
            guard error == nil else {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self,
                                              alertTitle: "네트워크 장애",
                                              message: error?.localizedDescription,
                                              actionTitle: "다시 검색 해보세요")
                }
                return
            }
            
            if self?.viewModel.movieInfoModel == nil {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self,
                                              alertTitle: "검색 된 영화가 없습니다",
                                              message: "다른 컨탠츠를 검색 해보세요",
                                              actionTitle: "확인")
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: K.SegueIdentifier.movieInfoView, sender: nil)
            }
        }
    }
}
