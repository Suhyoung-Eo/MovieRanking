//
//  CommentsViewController.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/15.
//

import UIKit

class CommentsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let viewModel = AccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        navigationItem.title = "내코멘트"
        
        viewModel.loadUserCommentList { [weak self] error in
            self?.activityIndicator.stopAnimating()
            if let error = error {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self, alertTitle: "정보를 불러오지 못했습니다", message: error.localizedDescription)
                }
            } else {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch sender as? String {
        case K.Prepare.movieInfoView:
            guard let destinationVC = segue.destination as? MovieInfoViewController else {
                fatalError("Could not found MovieInfoViewController")
            }
            destinationVC.movieInfo = viewModel.movieInfoModel
        case K.Prepare.addCommentView:
            guard let destinationVC = segue.destination as? AddCommentViewController else {
                fatalError("Could not found AddCommentViewController")
            }
            destinationVC.movieInfo = viewModel.movieInfoModel
        default:
            break
        }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    deinit {
        print("deinit CommentsViewController")
    }
}

//MARK: - extension CommentsViewController

extension CommentsViewController {

    private func showEditAlert(_ index: Int) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "코멘트 수정", style: .default) { [weak self] _ in
            self?.viewModel.loadMovieInfo(by: K.Prepare.userCommentView, index: index) { error in
                
                if error != nil || self?.viewModel.movieInfoModel == nil {
                    DispatchQueue.main.async {
                        AlertService.shared.alert(viewController: self,
                                                  alertTitle: "영화 정보를 불러올 수 없습니다",
                                                  message: error?.localizedDescription)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.performSegue(withIdentifier: K.SegueId.addCommentView, sender: K.Prepare.addCommentView)
                    }
                }
            }
        })
        alert.addAction(UIAlertAction(title: "코멘트 삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteComment(userId: self?.viewModel.userId, index: index) { error in
                guard let error = error else { return }
                
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self,
                                              alertTitle: "코멘트 삭제 실패",
                                              message: error.localizedDescription)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
}

//MARK: - TableView dataSource methods

extension CommentsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.userCommentListCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.userCommentCell, for: indexPath) as? UserCommentCell else {
            fatalError("Could not found UserCommentCell")
        }
        
        let cellItem = viewModel.userCommentListModel.estimateModel(indexPath.section)
        cell.selectionStyle = .none
        cell.delegate = self
        cell.index = indexPath.section
        cell.thumbNailLink = cellItem.thumbNailLink
        cell.movieNameLabel.text = cellItem.movieName
        cell.gradeLabel.text = "평가 점수 ★ \(cellItem.grade)"
        cell.commentLabel.text = cellItem.comment
        
        return cell
    }
}

//MARK: - Cell delegate method

extension CommentsViewController: UserCommentCellDelegate {
    
    func pushedThumbNailImageButton(index: Int) {
        
        viewModel.loadMovieInfo(by: K.Prepare.userCommentView, index: index) { [weak self] error in
            
            if error != nil || self?.viewModel.movieInfoModel == nil {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self,
                                              alertTitle: "영화 정보를 불러올 수 없습니다",
                                              message: error?.localizedDescription)
                }
            } else {
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: K.SegueId.movieInfoView, sender: K.Prepare.movieInfoView)
                }
            }
        }
    }
    
    func pushedEditButton(index: Int) {
        showEditAlert(index)
    }
}
