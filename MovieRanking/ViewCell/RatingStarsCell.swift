//
//  RatingStarsCell.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/10.
//

import UIKit

class RatingStarsCell: UITableViewCell {
    
    @IBOutlet weak var firstStarView: UIImageView!
    @IBOutlet weak var secondStarView: UIImageView!
    @IBOutlet weak var thirdStarView: UIImageView!
    @IBOutlet weak var fourthStarView: UIImageView!
    @IBOutlet weak var fifthStarView: UIImageView!
    
    private let viewModel = FirebaseViewModel()
    private var comment =  CommentModel(userId: "", movieName: "", grade: 0, comment: "", date: "")
    private var grade: Float = 0.0
    private var starImages: [UIImage] = []
    
    var parent: UIViewController!
    var movieName: String = ""
    
    var DOCID: String = "" {
        didSet {
            guard viewModel.userId != nil else { return }
            
            viewModel.loadUserComment(DOCID: DOCID) { [weak self] comment in
                guard let comment = comment else { return }
                self?.comment = comment
                self?.loadStarImages(by: comment.grade) { [weak self] starImages in
                    guard !starImages.isEmpty else { return }
                    self?.setStarImage()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func ratingSlider(_ sender: UISlider) {
        let intGradeValue = Int(sender.value.rounded()) // range: 0 ~ 10
        self.grade = Float(intGradeValue) / 2
        
        loadStarImages(by: grade) { [weak self] starImages in
            guard !starImages.isEmpty else { return }
            self?.setStarImage()
            
            if let grade = self?.grade, grade == 0.0 {
                self?.deleteAlert()
            } else {
                self?.setGrade(by: self?.grade ?? 5.0)
            }
            
        }
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
    
    private func loadStarImages(by grade: Float , completion: @escaping ([UIImage]) -> Void) {
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
        
        DispatchQueue.main.async { [weak self] in
            completion(self?.starImages ?? [])
        }
    }
    
    private func setGrade(by grade: Float) {
        guard viewModel.userId != nil else { alertService(); return }
        
        viewModel.addComment(DOCID: DOCID,
                             movieName: movieName,
                             grade: grade,
                             comment: comment.comment) { [weak self] error in
            if let error = error {
                AlertService.shared.alert(viewController: self?.parent,
                                          alertTitle: "평점 등록에 실패 했습니다",
                                          message: error.localizedDescription,
                                          actionTitle: "확인")
            }
        }
    }
    
    private func alertService() {
        let alert = UIAlertController(title: "서비스를 이용하려면 로그인 하세요", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            self?.loadStarImages(by: 0) { starImages in
                guard !starImages.isEmpty else { return }
                self?.setStarImage()
            }
        }
        alert.addAction(action)
        parent.present(alert, animated: true, completion: nil)
    }
    
    // 평가 점수가 0인 경우 확인 후 삭제
    private func deleteAlert() {
        let alert = UIAlertController(title: "평가를 삭제 하시겠습니까?", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            if let DOCID = self?.DOCID, let comment = self?.comment {
                self?.viewModel.deleteComment(DOCID: DOCID, userId: comment.userId) { _ in }
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(action)
        alert.addAction(cancelAction)
        parent.present(alert, animated: true)
    }
}
