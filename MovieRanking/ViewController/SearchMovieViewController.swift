//
//  SearchMovieViewController.swift
//  MovingMovie
//
//  Created by Suhyoung Eo on 2022/02/05.
//

import UIKit

class SearchMovieViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let searchController = UISearchController()
    
    private let viewModel = SearchMovieViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "MovieInfoCell", bundle: nil), forCellReuseIdentifier: K.CellIdentifier.searchMovieCell)
        tableView.separatorStyle = .none
        
        navigationItem.title = "영화검색"
        navigationItem.searchController = searchController
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "영화 콘텐츠를 검색해보세요"
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        
        viewModel.onUpdated = { [weak self] in
            DispatchQueue.main.async {
                if self?.viewModel.numberOfRowsInSection == 0 {
                    self?.tableView.separatorStyle = .none
                } else {
                    self?.tableView.separatorStyle = .singleLine
                    self?.activityIndicator.stopAnimating()
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

}

//MARK: - TableView Datasource Methods

extension SearchMovieViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.searchMovieCell, for: indexPath) as! SearchMovieCell

        let movieInfo = viewModel.movieInfoList.movieInfoModel(indexPath.row)
        // cell 속성
        cell.selectionStyle = .none
        cell.movieNameLabel.font = .systemFont(ofSize: 18)
        cell.movieNameENLabel.font = .systemFont(ofSize: 13)
        cell.movieNameENLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        cell.dicrectorLabel.font = .systemFont(ofSize: 13)
        cell.dicrectorLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        cell.ratingLabel.font = .systemFont(ofSize: 13)
        cell.ratingLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        
        // cell value
        cell.thumbnailImageView.setImage(from: movieInfo.thumbNailLinks[0])
        cell.movieNameLabel.text = movieInfo.movieName
        cell.movieNameENLabel.text = movieInfo.movieNameOrg
        cell.dicrectorLabel.text = "\(movieInfo.prodYear) \(movieInfo.directors[0].directorNm ?? "")"
        cell.ratingLabel.text = movieInfo.rating
        
        return cell
    }
    
}

//MARK: - TableView delegate methods

extension SearchMovieViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

//MARK: - Searchbar delegate methods

extension SearchMovieViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        backgroundImageView.isHidden = true
        
        if let movieName = searchBar.text {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            viewModel.fetchMovieInfo(title: movieName) { [weak self] error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        AlertService.shared.alert(viewController: self,
                                                  alertTitle: "네트워크 장애",
                                                  message: error?.localizedDescription,
                                                  actionTitle: "다시 검색 해보세요")
                    }
                    return
                }
                
                if self?.viewModel.movieInfoList == nil {
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        AlertService.shared.alert(viewController: self,
                                                  alertTitle: "검색 된 영화가 없습니다",
                                                  message: "다른 컨탠츠를 검색 해보세요",
                                                  actionTitle: "확인")
                    }
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        backgroundImageView.isHidden = false
        viewModel.clearMovieInfoList()
    }
}
