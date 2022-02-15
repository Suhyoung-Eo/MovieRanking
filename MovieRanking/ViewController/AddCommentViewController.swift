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
    @IBOutlet weak var firstStarView: UIImageView!
    @IBOutlet weak var secondStarView: UIImageView!
    @IBOutlet weak var thirdStarView: UIImageView!
    @IBOutlet weak var fourthStarView: UIImageView!
    @IBOutlet weak var fifthStarView: UIImageView!
    
    private let viewModel = FirebaseViewModel()
    private var starImages: [UIImage] = []
    private var grade: Float = 0.0
    
    var movieInfo: MovieInfoModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
        movieNameLabel.text = movieInfo.movieName
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 이전에 코멘트를 남긴 경우 불러옴
        viewModel.loadCurrentUserComment(DOCID: movieInfo.DOCID) { [weak self] error in
            guard error == nil else {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self, alertTitle: "코멘트를 불러 오지 못 했습니다")
                }
                return
            }
            
            self?.grade = self?.viewModel.currentUserComment?.grade ?? 0
            self?.loadStarImages(by: self?.grade ?? 0) {
                self?.setStarImage()
            }
            
            DispatchQueue.main.async {
                self?.commentTextView.text = self?.viewModel.currentUserComment?.comment
            }
        }
    }
    
    @IBAction func confirmButton(_ sender: Any) {
        
        if viewModel.userId == nil { showAlert(); return }
        
        guard let comment = commentTextView.text, grade != 0 else {
            AlertService.shared.alert(viewController: self, alertTitle: "코맨트 등록에 실패 했습니다", message: "평점 등록은 필수입니다")
            return
        }
        
        viewModel.addComment(DOCID: movieInfo.DOCID,
                             movieId: movieInfo.movieName,
                             movieSeq: movieInfo.movieSeq,
                             movieName: movieInfo.movieName,
                             thumbNailLink: movieInfo.thumbNailLinks[0],
                             grade: grade,
                             comment: comment) { [weak self] error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    AlertService.shared.alert(viewController: self, alertTitle: "코맨트 등록에 실패 했습니다", message: error?.localizedDescription)
                }
                return
            }
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func ratingSlider(_ sender: UISlider) {
        let intGradeValue = Int(sender.value.rounded()) // range: 0 ~ 10
        grade = Float(intGradeValue) / 2
        
        loadStarImages(by: grade) { [weak self] in
            self?.setStarImage()
        }
        
        if grade == 0, viewModel.currentUserComment.grade != 0 {
            deleteAlert()
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func loadStarImages(by grade: Float, completion: @escaping () -> Void) {
        starImages = []
        var starImage: UIImage?
        
        for i in 1...5 {
            if Float(i) <= grade {
                starImage = UIImage(named: K.Image.starFull)
            } else if Float(i) - grade == 0.5 {
                starImage = UIImage(named: K.Image.starHalf)
            } else {
                starImage = UIImage(named: K.Image.starEmpty)
            }
            starImages.append(starImage ?? UIImage())
        }
        
        gradeLabel.text = String(format: "%.1f", grade)
        completion()
    }
    
    private func setStarImage() {
        DispatchQueue.main.async { [weak self] in
            self?.firstStarView.image = self?.starImages[0]
            self?.secondStarView.image = self?.starImages[1]
            self?.thirdStarView.image = self?.starImages[2]
            self?.fourthStarView.image = self?.starImages[3]
            self?.fifthStarView.image = self?.starImages[4]
        }
    }
    
    private func deleteAlert() {
        if viewModel.userId == nil { return }
        let alert = UIAlertController(title: "삭제 하시겠습니까?", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            self?.viewModel.deleteComment(DOCID: self?.movieInfo.DOCID ?? "",
                                          userId: self?.viewModel.currentUserComment?.userId ?? "") { _ in }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] action in
            self?.loadStarImages(by: self?.viewModel.currentUserComment?.grade ?? 0) {
                self?.setStarImage()
            }
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showAlert() {
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
        if viewModel.userId == nil { showAlert(); return false }
        return true
    }
}
