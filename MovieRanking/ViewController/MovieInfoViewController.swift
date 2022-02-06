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
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "MovieImageCell", bundle: nil), forCellReuseIdentifier: K.CellIdentifier.movieImageCell)
        
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // scroll 시 섹션 헤더 상단 고정 방지
        let dummyViewHeight = CGFloat(40)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: dummyViewHeight))
        tableView.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.movieImageCell) as! MovieImageCell
        
        // cell 속성
        cell.selectionStyle = .none
        cell.movieNameLabel.font = .boldSystemFont(ofSize: 20)
        cell.movieInfoLabel.font = .boldSystemFont(ofSize: 15)
        cell.movieInfoLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        cell.posterImageView.isUserInteractionEnabled = true
        cell.posterImageView.tag = 1
        cell.stllImageView.isUserInteractionEnabled = true
        cell.stllImageView.tag = 2
        
        let posterImagetapped = UITapGestureRecognizer(target: self, action: #selector(tappedPosterImage))
        posterImagetapped.numberOfTapsRequired = 1
        cell.posterImageView.addGestureRecognizer(posterImagetapped)
        
        let stllImagetapped = UITapGestureRecognizer(target: self, action: #selector(tappedstllImage))
        stllImagetapped.numberOfTapsRequired = 1
        cell.stllImageView.addGestureRecognizer(stllImagetapped)
        
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
        
    }
}

//MARK: - tableView delegate methods

extension MovieInfoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = .gray.withAlphaComponent(0.1)
        
        return view
    }
}
