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
    private var boxOfficeType = 0   //  0: 주간/ 1: 주말/ 2: 일별 박스오피스
    
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
                self?.tableView.separatorStyle = .singleLine
                self?.tableView.reloadData()
                self?.button.isEnabled = true
            }
        }
        
        fetchBoxOffice(boxOfficeType)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    private func fetchBoxOffice(_ boxOfficeType: Int) {
        button.isEnabled = false    // 박스오피스 정보 다운로드 완료전까지 선택 버튼 비활성화
        
        switch boxOfficeType {
        case 0:
            button.setTitle("     ▼  주간 박스오피스", for: .normal)
            viewModel.fetchWeeklyBoxOffice(by: 0)   // 주간 (월~일)
        case 1:
            button.setTitle("     ▼  주말 박스오피스", for: .normal)
            viewModel.fetchWeeklyBoxOffice(by: 1)   // 주말 (금~일)
        case 2:
            button.setTitle("     ▼  일별 박스오피스", for: .normal)
            viewModel.fetchDailyBoxOffice()           // 일별 (검색일 하루 전)
        default:
            button.setTitle("     ▼  주간 박스오피스", for: .normal)
            viewModel.fetchWeeklyBoxOffice(by: 0)
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
