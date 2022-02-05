//
//  BoxOfficeViewController.swift
//  MovingMovie
//
//  Created by Suhyoung Eo on 2021/11/15.
//

import UIKit

class BoxOfficeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var button: UIButton!
    
    private let viewModel = BoxOfficeViewModel()
    
    // boxOfficeType - 0: 주간/ 1: 주말/ 2: 일별 박스오피스
    private var boxOfficeType = 0 {
        didSet {
            fetchBoxOffice()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "BoxOfficeCell", bundle: nil), forCellReuseIdentifier: K.CellIdentifier.boxOfficeCell)
        tableView.separatorStyle = .none
        
        navigationItem.title = "박스오피스 순위"
        button.contentHorizontalAlignment = .left
        
        viewModel.onUpdated = { [weak self] in
            DispatchQueue.main.async {
                if self?.viewModel.numberOfRowsInSection == 0 {
                    self?.tableView.separatorStyle = .none
                } else {
                    self?.tableView.separatorStyle = .singleLine
                }
                self?.tableView.reloadData()
                self?.button.isEnabled = true
            }
        }
        
        fetchBoxOffice()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationVC = segue.destination as? UINavigationController,
              let destinationVC = navigationVC.viewControllers.first as? OptionTableViewController else {
            fatalError("Could not found segue destination")
        }
        
        // custom segue 설정
        navigationVC.transitioningDelegate = self
        navigationVC.modalPresentationStyle = .custom
        navigationVC.view.layer.cornerRadius = 10
        navigationVC.view.clipsToBounds = true
        navigationVC.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        destinationVC.delegate = self
        destinationVC.boxOfficeType = boxOfficeType
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
    }
    
    private func fetchBoxOffice() {
        button.isEnabled = false    // 박스오피스 정보 다운로드 완료전까지 선택 버튼 비활성화
        
        switch boxOfficeType {
        case 0: // 주간 (월~일)
            button.setTitle("     ▼  주간 박스오피스", for: .normal)
            viewModel.fetchWeeklyBoxOffice(by: 0) { [weak self] error in
                guard error != nil else { return }
                self?.retry(error: error)
            }
        case 1: // 주말 (금~일)
            button.setTitle("     ▼  주말 박스오피스", for: .normal)
            viewModel.fetchWeeklyBoxOffice(by: 1) { [weak self] error in
                guard error != nil else { return }
                self?.retry(error: error)
            }
        case 2: // 일별 (검색일 하루 전)
            button.setTitle("     ▼  일별 박스오피스", for: .normal)
            viewModel.fetchDailyBoxOffice { [weak self] error in
                guard error != nil else { return }
                self?.retry(error: error)
            }
        default:
            button.setTitle("     ▼  주간 박스오피스", for: .normal)
            viewModel.fetchWeeklyBoxOffice(by: 0) { [weak self] error in
                guard error != nil else { return }
                self?.retry(error: error)
            }
        }
    }
    
    private func retry(error: Error?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "네트워크 장애", message: error?.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "재시도", style: .default) { [weak self] action in
                self?.fetchBoxOffice()
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.boxOfficeCell, for: indexPath) as? BoxOfficeCell else { return UITableViewCell() }

        let boxOfficeList = viewModel.boxOfficeList.boxOfficeModel(indexPath.row)
        let movieInfoList = viewModel.movieInfoList.movieInfoModel(indexPath.row)
        // cell 속성
        cell.selectionStyle = .none
        cell.titleLabel.font = .systemFont(ofSize: 18)
        cell.rankLabel.font = .boldSystemFont(ofSize: 18)
        cell.rankLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        cell.openDateLabel.font = .systemFont(ofSize: 13)
        cell.openDateLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        cell.audiAccLabel.font = .systemFont(ofSize: 13)
        cell.audiAccLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        
        // cell value
        cell.thumbnailImageView.setImage(from: movieInfoList.thumbNailLinks[0])
        cell.titleLabel.text = boxOfficeList.movieName
        cell.rankLabel.text = boxOfficeList.movieRank
        cell.openDateLabel.text = "개봉일: \(boxOfficeList.openDate)"
        cell.audiAccLabel.text = "누적: \(boxOfficeList.audiAcc)"
        if boxOfficeList.rankOldAndNew == "NEW" {
            cell.newImageView.image = UIImage(named: "new")
        }
        
        return cell
    }
    
}

//MARK: - TableView delegate methods

extension BoxOfficeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}

//MARK: - UIViewControllerTransitioning delegate method

extension BoxOfficeViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presentingViewController)
    }
}

//MARK: - OptionTableViewController delegate method

extension BoxOfficeViewController: OptionTableViewControllerDelegate {
    
    func didSelectType(selectedType: Int) {
        if boxOfficeType != selectedType {
            boxOfficeType = selectedType
        }
    }
}
