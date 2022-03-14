//
//  BoxOfficeViewController.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2021/11/15.
//

import UIKit

class BoxOfficeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let viewModel = BoxOfficeViewModel()
    
    // 0: 주간/ 1: 주말/ 2: 일별 박스오피스
    private var boxOfficeType = 0 {
        didSet {
            fetchBoxOffice()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.CellId.boxOfficeCell, bundle: nil), forCellReuseIdentifier: K.CellId.boxOfficeCell)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        navigationItem.title = "박스오피스 순위"
        button.contentHorizontalAlignment = .left
        
        viewModel.delegate = self
        fetchBoxOffice()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // 회원가입만 하고 닉네임을 정하지 않은 경우 닉네임 저장 뷰를 띄운다.
        if viewModel.isEmptyDisplayName {
            guard let navigationVC = self.storyboard?.instantiateViewController(withIdentifier: K.SegueId.loginView) as? LoginViewController else {
                fatalError("Could not found LoginViewController")
            }
            
            navigationVC.modalTransitionStyle = .coverVertical
            navigationVC.modalPresentationStyle = .fullScreen
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let sender = sender as? String, sender == K.Prepare.movieInfoView {
            guard let destinationVC = segue.destination as? MovieInfoViewController else {
                fatalError("Could not found MovieInfoViewController")
            }
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.movieInfo = viewModel.movieInfoList.movieInfoModel(indexPath.row)
            }
        } else {
            guard let navigationVC = segue.destination as? UINavigationController,
                  let destinationVC = navigationVC.viewControllers.first as? OptionTableViewController else {
                      fatalError("Could not found OptionTableViewController")
                  }
            
            // custom segue 설정
            navigationVC.transitioningDelegate = self
            navigationVC.modalPresentationStyle = .custom
            navigationVC.view.layer.cornerRadius = 10
            navigationVC.view.clipsToBounds = true
            navigationVC.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            destinationVC.delegate = self
            destinationVC.boxOfficeType = boxOfficeType
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
}

//MARK: - extension BoxOfficeViewController

extension BoxOfficeViewController {
    
    private func fetchBoxOffice() {
        button.isEnabled = false    // 박스오피스 정보 다운로드 완료전까지 선택 버튼 비활성화
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        viewModel.fetchBoxOffice(by: boxOfficeType)
    }
    
    private func retry(error: Error?) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "네트워크 장애", message: error?.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "재시도", style: .default) { [weak self] _ in self?.fetchBoxOffice() })
            self?.present(alert, animated: true, completion: nil)
            self?.activityIndicator.stopAnimating()
        }
    }
}

//MARK: - TableView Datasource Methods

extension BoxOfficeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection
    }    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.boxOfficeCell, for: indexPath) as? BoxOfficeCell else {
            fatalError("Could not found BoxOfficeCell")
        }
        
        let boxOfficeInfo = viewModel.boxOfficeInfo(index: indexPath.row)   // return (String, BoxOfficeModel)
        
        cell.selectionStyle = .none
        cell.thumbnailImageView.setImage(from: boxOfficeInfo.thumbNailLink)
        cell.titleLabel.text = boxOfficeInfo.boxOfficeModel.movieName
        cell.rankLabel.text = boxOfficeInfo.boxOfficeModel.movieRank
        cell.openDateLabel.text = "개봉일: \(boxOfficeInfo.boxOfficeModel.openDate)"
        cell.audiAccLabel.text = "누적: \(boxOfficeInfo.boxOfficeModel.audiAcc)"
        if boxOfficeInfo.boxOfficeModel.rankOldAndNew == "NEW" {
            cell.newImageView.image = UIImage(named: "new")
        }
        
        return cell
    }
    
}

//MARK: - TableView delegate methods

extension BoxOfficeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.movieInfoList.movieInfoModel(indexPath.row).DOCID.isEmpty {
            AlertService.shared.alert(viewController: self, alertTitle: "해당 영화의 상세 정보를 검색할 수 없습니다")
            return
        }
        performSegue(withIdentifier: K.SegueId.movieInfoView, sender: K.Prepare.movieInfoView)
    }
}

//MARK: - UIViewControllerTransitioning delegate method

extension BoxOfficeViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presentingViewController)
    }
}

//MARK: - delegate method

extension BoxOfficeViewController:  BoxOfficeViewModelDelegate, OptionTableViewControllerDelegate {
    
    func didSelectType(selectedType: Int) {
        if boxOfficeType != selectedType {
            boxOfficeType = selectedType
        }
    }
    
    func didUpdateBoxOffice() {
        
        button.setTitle(viewModel.buttonTitle, for: .normal)
        
        if viewModel.numberOfRowsInSection == 0 {
            tableView.separatorStyle = .none  // fetchBoxOffice 동작 하는 동안 화면 클리어
        } else {
            tableView.separatorStyle = .singleLine
            activityIndicator.stopAnimating()
            button.isEnabled = true
        }
        tableView.reloadData()
    }
    
    func didFailWithError(error: Error) {
        retry(error: error)
    }
}
