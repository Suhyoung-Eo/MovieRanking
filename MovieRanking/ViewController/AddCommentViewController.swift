//
//  AddCommentViewController.swift
//  MovingRanking
//
//  Created by Suhyoung Eo on 2022/02/07.
//

import UIKit

class AddCommentViewController: UIViewController {
    
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    private let viewModel = MovieInfoViewModel()
    var movieInfo: MovieInfoModel!
    var comment: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
        
        viewModel.gotErrorStatus = { [weak self] in
            if let error = self?.viewModel.error {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self, alertTitle: "코멘트 등록에 실패했습니다", message: error.localizedDescription)
                }
            }
        }
        
        viewModel.onUpdatedComment = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        movieNameLabel.text = movieInfo.movieName
        commentTextView.text = comment
    }
    
    @IBAction func confirmButton(_ sender: Any) {
        if viewModel.userId == nil { showAlert(); return }
        
        if let comment = commentTextView.text, !comment.isEmpty {
            viewModel.addComment(DOCID: movieInfo.DOCID, comment: comment)
        } else {
            AlertService.shared.alert(viewController: self, alertTitle: "작성한 코멘트가 없습니다")
            commentTextView.text = comment
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "서비스를 이용하려면 로그인하세요", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in self?.dismiss(animated: true, completion: nil) })
        present(alert, animated: true, completion: nil)
    }
    
    deinit {
        print("deinit AddCommentViewController")
    }
}

//MARK: - UITextView delegate methods

extension AddCommentViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if viewModel.userId == nil { showAlert(); return false }
        return true
    }
}
