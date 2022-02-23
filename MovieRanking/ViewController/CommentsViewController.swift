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
    @IBOutlet weak var emptyImage: UIImageView!
    
    private let viewModel = AccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        navigationItem.title = "내코멘트"
        emptyImage.isHidden = false
        
        viewModel.gotErrorStatus = { [weak self] in
            if let error = self?.viewModel.error {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    AlertService.shared.alert(viewController: self, alertTitle: "Error", message: error.localizedDescription)
                }
            }
        }
        
        viewModel.onUpdatedMovieInfo = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                
                if self.viewModel.isMovieInfoModelEmpty {
                    AlertService.shared.alert(viewController: self, alertTitle: "영화 정보를 불러올 수 없습니다")
                } else if self.viewModel.prepareId == K.Prepare.movieInfoView {
                    self.performSegue(withIdentifier: K.SegueId.movieInfoView, sender: K.Prepare.movieInfoView)
                } else if self.viewModel.prepareId == K.Prepare.addCommentView {
                    self.performSegue(withIdentifier: K.SegueId.addCommentView, sender: K.Prepare.addCommentView)
                }
            }
        }
        
        viewModel.onUpdatedAccountCommentList = { [weak self] in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                if self?.viewModel.accountCommentListCount == 0 {
                    self?.emptyImage.isHidden = false
                } else {
                    self?.emptyImage.isHidden = true
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emptyImage.isHidden = true
        viewModel.loadAccountCommentList()
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
            destinationVC.comment = viewModel.comment
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
            self?.viewModel.fetchMovieInfo(by: K.Prepare.addCommentView, index: index)
        })
        alert.addAction(UIAlertAction(title: "코멘트 삭제", style: .destructive) { [weak self] _ in
            self?.showDeleteAlert(index: index)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showDeleteAlert(index: Int) {
        let alert = UIAlertController(title: "코멘트 삭제", message: "코멘트를 삭제하시겠어요?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "삭제하기", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteComment(userId: self?.viewModel.userId, index: index)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
}

//MARK: - TableView dataSource methods

extension CommentsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.accountCommentListCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.userCommentCell, for: indexPath) as? UserCommentCell else {
            fatalError("Could not found UserCommentCell")
        }
        
        let cellItem = viewModel.accountCommentListModel.accountCommentModel(indexPath.section)
        cell.selectionStyle = .none
        cell.delegate = self
        cell.index = indexPath.section
        cell.thumbNailLink = cellItem.thumbNailLink
        cell.movieNameLabel.text = cellItem.movieName
        cell.gradeLabel.text = cellItem.grade == 0 ? "평가가 없습니다" : "평가 점수 ★ \(cellItem.grade)"
        cell.commentLabel.text = cellItem.comment
        
        return cell
    }
}

//MARK: - Cell delegate method

extension CommentsViewController: UserCommentCellDelegate {
    
    func pushedThumbNailImageButton(index: Int) {
        viewModel.fetchMovieInfo(by: K.Prepare.movieInfoView, index: index)
    }
    
    func pushedEditButton(index: Int) {
        showEditAlert(index)
    }
}
