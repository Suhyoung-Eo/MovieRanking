//
//  AddCommentViewController.swift
//  MovingRanking
//
//  Created by Suhyoung Eo on 2022/02/07.
//

import UIKit

class AddCommentViewController: UIViewController {

    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!

    var DOCID: String = ""
    var movieName: String = ""
    
    private let viewModel = FirebaseViewModel()
    private var comment: CommentModel!
    private var grade: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
        movieNameLabel.text = movieName
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 이전에 코멘트를 남긴 경우 불러옴
        viewModel.loadUserComment(DOCID: DOCID) { [weak self] comment in
            
            if let comment = comment {
                let intGradeValue = Int(comment.grade * 2)
                self?.rating(by: intGradeValue)
                self?.commentTextView.text = comment.comment
            } else {
                self?.rating(by: 0)
                self?.commentTextView.text = ""
            }
        }
    }
    
    @IBAction func confirmButton(_ sender: Any) {
        
        if viewModel.userId == nil { alertService(); return }
        
        guard let comment = commentTextView.text, grade != 0 else {
            AlertService.shared.alert(viewController: self,
                                      alertTitle: "코맨트 등록에 실패 했습니다",
                                      message: "평점 등록은 필수입니다",
                                      actionTitle: "확인")
            return
        }
        
        viewModel.addComment(DOCID: DOCID,
                             movieName: movieName,
                             grade: grade,
                             comment: comment) { [weak self] error in
            
            if error == nil {
                self?.dismiss(animated: true, completion: nil)
                return
            }
            
            DispatchQueue.main.async {
                AlertService.shared.alert(viewController: self,
                                          alertTitle: "코맨트 등록에 실패 했습니다",
                                          message: error?.localizedDescription,
                                          actionTitle: "확인")
            }
        }
    }
    
    @IBAction func ratingSlider(_ sender: UISlider) {
        let intGradeValue = Int(sender.value.rounded()) // range: 0 ~ 10
        rating(by: intGradeValue)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func rating(by intGradeValue: Int) {
        // tag되어 있는 별(UIImageView) 사용
        for i in 1...5 {
            if let starImage = view.viewWithTag(i) as? UIImageView {
                if i * 2 <= intGradeValue {
                    starImage.image = UIImage(named: K.Image.starFull)
                } else if (i * 2) - intGradeValue == 1 {
                    starImage.image = UIImage(named: K.Image.starHalf)
                } else {
                    starImage.image = UIImage(named: K.Image.starEmpty)
                }
            }
        }
        
        grade = Float(intGradeValue) / 2
        gradeLabel.text = String(format: "%.1f", grade)
    }
    
    private func alertService() {
        let alert = UIAlertController(title: "서비스를 이용하려면 로그인 하세요", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            self?.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    deinit {
        print("deinit AddCommentViewController")
    }
}

//MARK: - UITextView delegate methods

extension AddCommentViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if viewModel.userId == nil { alertService(); return false }
        return true
    }
}
