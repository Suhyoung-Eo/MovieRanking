//
//  MovieInfoViewController.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/06.
//

import UIKit

class MovieInfoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = FirebaseViewModel()
    private var userInfose: [UserInfoModel] = []
    private var gradeAverage: Float = 0.0
    private var wishToWatch: Bool = false
    
    var movieInfo = MovieInfoModel(MovieInfo.empty) {
        didSet {
            loadUserInfose()
            loadWishToWatch()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "MovieImageCell", bundle: nil), forCellReuseIdentifier: K.CellIdentifier.movieImageCell)
        tableView.register(UINib(nibName: "RatingStarsCell", bundle: nil), forCellReuseIdentifier: K.CellIdentifier.ratingStarsCell)
        tableView.register(UINib(nibName: "UserInteractionCell", bundle: nil), forCellReuseIdentifier: K.CellIdentifier.userInteractionCell)
        tableView.register(UINib(nibName: "DetailInfoCell", bundle: nil), forCellReuseIdentifier: K.CellIdentifier.detailInfoCell)
        tableView.register(UINib(nibName: "StaffsInfoCell", bundle: nil), forCellReuseIdentifier: K.CellIdentifier.staffsInfoCell)
        tableView.register(UINib(nibName: "CommentHeadCell", bundle: nil), forCellReuseIdentifier: K.CellIdentifier.commentHeadCell)
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: K.CellIdentifier.commentCell)
        tableView.dataSource = self
        tableView.delegate = self
        
        // ios15에서 setionHeader에 여백이 생기는 이슈
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
        navigationItem.title = movieInfo.movieName
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.title = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let sender = sender as? String {
            switch sender {
            case "postImageView":
                guard let destinationVC = segue.destination as? ImageViewController else {
                    fatalError("Could not found segue destination")
                }
                destinationVC.imageLinks = movieInfo.thumbNailLinks
            case "stllImageView":
                guard let destinationVC = segue.destination as? ImageViewController else {
                    fatalError("Could not found segue destination")
                }
                destinationVC.imageLinks = movieInfo.stllsLinks
            case "staffView":
                guard let destinationVC = segue.destination as? StaffsInfoTableViewController else {
                    fatalError("Could not found segue destination")
                }
                destinationVC.staffs = movieInfo.staffs
            case "addCommentView":
                guard let destinationVC = segue.destination as? AddCommentViewController else {
                    fatalError("Could not found segue destination")
                }
                destinationVC.movieInfo = movieInfo
            default:
                return
            }
        }
    }
    
    deinit {
        print("deinit MovieInfoViewController")
    }
}

//MARK: - extension MovieInfoViewController

extension MovieInfoViewController {
    
    @objc private func tappedPosterImage(gesture: UITapGestureRecognizer) {
        if !movieInfo.thumbNailLinks[0].isEmpty {
            performSegue(withIdentifier: K.SegueIdentifier.imageView, sender: "postImageView")
        }
    }
    
    @objc private func tappedstllImage(gesture: UITapGestureRecognizer) {
        if !movieInfo.stllsLinks[0].isEmpty {
            performSegue(withIdentifier: K.SegueIdentifier.imageView, sender: "stllImageView")
        }
    }
    
    private func loadUserInfose() {
        viewModel.loadUserInfose(DOCID: movieInfo.DOCID) { [weak self] userInfose, gradeAverage, error in
            guard error == nil else { return }
            self?.userInfose = userInfose
            self?.gradeAverage = gradeAverage

            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func loadWishToWatch() {
        viewModel.loadWishToWatch(DOCID: movieInfo.DOCID) { [weak self] isWish in
            self?.wishToWatch = isWish
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

//MARK: - tableView dataSource methods

extension MovieInfoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 6:
            return userInfose.isEmpty ? 1 : userInfose.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // scroll 시 섹션 헤더 상단 고정 방지
        let dummyViewHeight = CGFloat(40)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: dummyViewHeight))
        tableView.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.movieImageCell) as? MovieImageCell else {
                fatalError("Could not found ViewCell")
            }
            
            let posterImageTapped = UITapGestureRecognizer(target: self, action: #selector(tappedPosterImage))
            posterImageTapped.numberOfTapsRequired = 1
            cell.posterImageView.addGestureRecognizer(posterImageTapped)
            
            let stllImageTapped = UITapGestureRecognizer(target: self, action: #selector(tappedstllImage))
            stllImageTapped.numberOfTapsRequired = 1
            cell.stllImageView.addGestureRecognizer(stllImageTapped)

            cell.selectionStyle = .none
            cell.posterImageView.setImage(from: movieInfo.thumbNailLinks[0])
            cell.movieNameLabel.text = movieInfo.movieName
            cell.movieInfoLabel.text = "\(movieInfo.prodYear) \(movieInfo.nation) \(movieInfo.genre)"
            
            if !movieInfo.stllsLinks[0].isEmpty {
                cell.stllImageView.setImage(from: movieInfo.stllsLinks[0])
            } else {
                cell.stllImageView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            }
            
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.ratingStarsCell) as? RatingStarsCell else {
                fatalError("Could not found ViewCell")
            }
            
            cell.selectionStyle = .none
            cell.parent = self
            cell.movieInfo = movieInfo
            
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.userInteractionCell) as? UserInteractionCell else {
                fatalError("Could not found ViewCell")
            }
            
            cell.selectionStyle = .none
            cell.delegate = self
            cell.gradeLabel.text = gradeAverage == 0 ? "첫 평점을 등록해 주세요" : "평균 ★ \(String(format: "%.1f", gradeAverage))"
            cell.wishToWatchButton.setImage(wishToWatch ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "plus"), for: .normal)
            cell.wishToWatchButton.tintColor = wishToWatch ? UIColor(red: 0.92, green: 0.20, blue: 0.36, alpha: 1.00) : UIColor.darkGray
            
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.detailInfoCell) as? DetailInfoCell else {
                fatalError("Could not found ViewCell")
            }
            
            cell.selectionStyle = .none
            cell.storyLabel.text = movieInfo.story[0].plotText
            cell.directorsLabel.text = movieInfo.directors[0].directorNm
            cell.runtimeLabel.text = movieInfo.runtime
            cell.ratingLabel.text = movieInfo.rating
            cell.genreLabel.text = movieInfo.genre
            cell.nationLabel.text = movieInfo.nation
            cell.prodYearLabel.text = movieInfo.prodYear
            cell.movieNameOrgLabel.text = movieInfo.movieNameOrg
            
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.staffsInfoCell) as? StaffsInfoCell else {
                fatalError("Could not found ViewCell")
            }
            
            cell.selectionStyle = .none
            cell.delegate = self
            cell.directorLabel.text = movieInfo.directors[0].directorNm
            cell.firstActorLabel.text = movieInfo.actors[0].actorNm
            cell.secondActorLabel.text = movieInfo.actors.count > 1 ? movieInfo.actors[1].actorNm : ""
            
            return cell
        case 5:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.commentHeadCell) as? CommentHeadCell else {
                fatalError("Could not found ViewCell")
            }
            cell.selectionStyle = .none
            
            return cell
        case 6:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.commentCell) as? CommentCell else {
                fatalError("Could not found ViewCell")
            }
            
            cell.selectionStyle = .none
            
            if userInfose.isEmpty {
                cell.stateEmptyLabel.isHidden = false
            } else {
                let userInfo = userInfose[indexPath.row]
                cell.stateEmptyLabel.isHidden = true
                cell.grade = userInfo.grade
                cell.userNameLabel.text = userInfo.userId
                cell.commentLabel.text = userInfo.comment
                cell.dateLabel.text = userInfo.date
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}

//MARK: - tableView delegate methods

extension MovieInfoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 0
        default:
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = .gray.withAlphaComponent(0.1)
        
        return view
    }
}

//MARK: - Cell Delegate methods

extension MovieInfoViewController: StaffsInfoCellDelegate, UserInteractionCellDelegate {
    
    func pushedStaffsInfoViewButton(data: Any) {
        performSegue(withIdentifier: K.SegueIdentifier.staffsInfoTableView, sender: data)
    }
    
    func pushedAddCommentButton(data: Any) {
        performSegue(withIdentifier: K.SegueIdentifier.addCommentView, sender: data)
    }
    
    func pushedWishToWatchButton() {
        wishToWatch = viewModel.userId == nil ? false : !wishToWatch
        viewModel.updateWishToWatch(DOCID: movieInfo.DOCID,
                                    movieId: movieInfo.movieId,
                                    movieSeq: movieInfo.movieSeq,
                                    movieName: movieInfo.movieName,
                                    thumbNailLink: movieInfo.thumbNailLinks[0],
                                    wishToWatch: wishToWatch) { error in
            guard error != nil else { return }
            
            DispatchQueue.main.async {
                AlertService.shared.alert(viewController: self,
                                          alertTitle: "보고싶어요 목록 저장에 실패 했습니다",
                                          message: nil, actionTitle: "확인")
            }
        }
        tableView.reloadData()
    }
}
