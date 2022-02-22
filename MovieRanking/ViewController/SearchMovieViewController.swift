//
//  SearchMovieViewController.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/05.
//

import UIKit

class SearchMovieViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let searchController = UISearchController()
    
    private let viewModel = MovieInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.CellId.searchMovieCell, bundle: nil), forCellReuseIdentifier: K.CellId.searchMovieCell)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        navigationItem.title = "영화검색"
        navigationItem.searchController = searchController
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "영화 콘텐츠를 검색해 보세요"
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        
        viewModel.onUpdated = { [weak self] in
            if let error = self?.viewModel.error {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self, alertTitle: "Error", message: error.localizedDescription)
                    self?.activityIndicator.stopAnimating()
                }
                return
            }
            
            DispatchQueue.main.async {
                if self?.viewModel.movieInfoList == nil {
                    self?.tableView.separatorStyle = .none
                } else if self?.viewModel.isMovieInfoModelEmpty ?? true {
                    AlertService.shared.alert(viewController: self, alertTitle: "검색 된 영화가 없습니다", message: "다른 콘텐츠를 검색해 보세요")
                    self?.activityIndicator.stopAnimating()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? MovieInfoViewController else {
            fatalError("Could not found MovieInfoViewController")
        }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.movieInfo = viewModel.movieInfoList.movieInfoModel(indexPath.row)
        }
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.searchMovieCell, for: indexPath) as? SearchMovieCell else {
            fatalError("Could not found ViewCell")
        }

        let movieInfo = viewModel.movieInfoList.movieInfoModel(indexPath.row)
        
        cell.selectionStyle = .none
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
        if !viewModel.movieInfoList.movieInfoModel(0).DOCID.isEmpty {
            performSegue(withIdentifier: K.SegueId.movieInfoView, sender: nil)
        }
    }
}

//MARK: - Searchbar delegate methods

extension SearchMovieViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        backgroundImageView.isHidden = true
        
        if let movieName = searchBar.text {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            viewModel.fetchMovieInfo(title: movieName)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        backgroundImageView.isHidden = false
        viewModel.clearMovieInfoList()
    }
}
