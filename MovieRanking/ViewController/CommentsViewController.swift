//
//  CommentsViewController.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/15.
//

import UIKit

class CommentsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let FBViewModel = FirebaseViewModel()
    private let viewModel = MovieInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        
        navigationItem.title = "내코멘트"
        FBViewModel.loadUserCommentList { [weak self] error in self?.showAlert(by: error) }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? MovieInfoViewController else {
            fatalError("Could not found segue destination")
        }
        
        destinationVC.movieInfo = viewModel.movieInfoModel

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
        
    private func showAlert(by error: Error?) {
        guard error == nil else {
            DispatchQueue.main.async {
                AlertService.shared.alert(viewController: self, alertTitle: "정보를 불러 오지 못 했습니다")
            }
            return
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "코멘트 수정", style: .default))
        alert.addAction(UIAlertAction(title: "코멘트 삭제", style: .destructive))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
}

//MARK: - TableView dataSource methods

extension CommentsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return FBViewModel.userCommentListCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.userCommentCell, for: indexPath) as? UserCommentCell else {
            fatalError("Could not found UserCommentCell")
        }
        
        let cellItem = FBViewModel.userCommentListModel.estimateModel(indexPath.section)
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
  
        let movieInfo = FBViewModel.userCommentListModel.estimateModel(index)
        
        viewModel.fetchMovieInfo(Id: movieInfo.movieId, Seq: movieInfo.movieSeq) { [weak self] error in
            guard error == nil else {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self, alertTitle: "네트워크 장애", message: error?.localizedDescription)
                }
                return
            }
            
            if self?.viewModel.movieInfoModel == nil {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self, alertTitle: "해당 영화 정보가 없습니다")
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: K.SegueId.movieInfoView, sender: nil)
            }
        }
    }
    
    func pushedEditButton() {
        showAlert()
    }
}
