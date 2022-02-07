//
//  MovieInfoViewController.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/06.
//

import UIKit

class MovieInfoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movieInfo = MovieInfoModel(MovieInfo.empty)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "MovieImageCell", bundle: nil), forCellReuseIdentifier: K.CellIdentifier.movieImageCell)
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
}

//MARK: - tableView dataSource methods

extension MovieInfoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 5:
            return 3
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
            
            let posterImagetapped = UITapGestureRecognizer(target: self, action: #selector(tappedPosterImage))
            posterImagetapped.numberOfTapsRequired = 1
            cell.posterImageView.addGestureRecognizer(posterImagetapped)
            
            let stllImagetapped = UITapGestureRecognizer(target: self, action: #selector(tappedstllImage))
            stllImagetapped.numberOfTapsRequired = 1
            cell.stllImageView.addGestureRecognizer(stllImagetapped)
            
            // cell 속성
            cell.selectionStyle = .none
            cell.movieNameLabel.font = .boldSystemFont(ofSize: 20)
            cell.movieInfoLabel.font = .boldSystemFont(ofSize: 15)
            cell.movieInfoLabel.textColor = UIColor.white.withAlphaComponent(0.8)
            cell.posterImageView.isUserInteractionEnabled = true
            cell.posterImageView.tag = 1
            cell.stllImageView.isUserInteractionEnabled = true
            cell.stllImageView.tag = 2
            
            
            // cell value
            if !movieInfo.stllsLinks[0].isEmpty {
                cell.stllImageView.setImage(from: movieInfo.stllsLinks[0])
            } else {
                cell.stllImageView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            }
            
            cell.posterImageView.setImage(from: movieInfo.thumbNailLinks[0])
            cell.movieNameLabel.text = movieInfo.movieName
            cell.movieInfoLabel.text = "\(movieInfo.prodYear) \(movieInfo.nation) \(movieInfo.genre)"
            
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.userInteractionCell) as? UserInteractionCell else {
                fatalError("Could not found ViewCell")
            }
            // cell 속성
            cell.selectionStyle = .none
            
            // cell value
            cell.delegate = self
            cell.gradeLabel.text = "평균 평점"
            
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.detailInfoCell) as? DetailInfoCell else {
                fatalError("Could not found ViewCell")
            }
            
            // cell 속성
            cell.selectionStyle = .none
            cell.storyLabel.font = .systemFont(ofSize: 15)
            cell.storyLabel.textColor = UIColor.black.withAlphaComponent(0.8)
            cell.directorsLabel.font = .systemFont(ofSize: 13)
            cell.runtimeLabel.font = .systemFont(ofSize: 13)
            cell.ratingLabel.font = .systemFont(ofSize: 13)
            cell.genreLabel.font = .systemFont(ofSize: 13)
            cell.nationLabel.font = .systemFont(ofSize: 13)
            cell.prodYearLabel.font = .systemFont(ofSize: 13)
            cell.movieNameOrgLabel.font = .systemFont(ofSize: 13)
            
            // cell value
            cell.storyLabel.text = movieInfo.story[0].plotText
            cell.directorsLabel.text = movieInfo.directors[0].directorNm
            cell.runtimeLabel.text = movieInfo.runtime
            cell.ratingLabel.text = movieInfo.rating
            cell.genreLabel.text = movieInfo.genre
            cell.nationLabel.text = movieInfo.nation
            cell.prodYearLabel.text = movieInfo.prodYear
            cell.movieNameOrgLabel.text = movieInfo.movieNameOrg
            
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.staffsInfoCell) as? StaffsInfoCell else {
                fatalError("Could not found ViewCell")
            }
            
            // cell 속성
            cell.selectionStyle = .none
            cell.directorLabel.font = .systemFont(ofSize: 17)
            cell.firstActorLabel.font = .systemFont(ofSize: 17)
            cell.secondActorLabel.font = .systemFont(ofSize: 17)
            
            // cell value
            cell.delegate = self
            cell.directorLabel.text = movieInfo.directors[0].directorNm
            cell.firstActorLabel.text = movieInfo.actors[0].actorNm
            cell.secondActorLabel.text = movieInfo.actors.count > 1 ? movieInfo.actors[1].actorNm : ""
            
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.commentHeadCell) as? CommentHeadCell else {
                fatalError("Could not found ViewCell")
            }
            cell.selectionStyle = .none
            return cell
        case 5:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.commentCell) as? CommentCell else {
                fatalError("Could not found ViewCell")
            }
            // cell 속성
            cell.selectionStyle = .none
            
            // cell value
            cell.userNameLabel.text = "어수형"
            cell.commentLabel.text = "정말 잼 있어요"
            cell.dateLabel.text = "2022.02.07"
            
            DispatchQueue.main.async {
                // emotion image
                cell.emotionImageView.image = UIImage(named: K.Image.veryGoodFace)
                
                // star image
                cell.firstStarImageView.image = UIImage(named: K.Image.starFull)
                cell.secondStarImageView.image = UIImage(named: K.Image.starFull)
                cell.thirdStarImageView.image = UIImage(named: K.Image.starFull)
                cell.fourthStarImageView.image = UIImage(named: K.Image.starFull)
                cell.fifthStarImageView.image = UIImage(named: K.Image.starFull)
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
        return 3
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
        print("pushedAddCommentButton")
    }
    
    func pushedWishToWatchButton() {
        print("pushedWishToWatchButton")
    }
}
