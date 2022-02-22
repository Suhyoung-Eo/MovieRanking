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
    
    private var starImages: [UIImage] = []
    
    var movieInfo: MovieInfoModel!
    weak var parent: UIViewController!
    
    weak var viewModel: MovieInfoViewModel! {
        didSet {
            loadStarImages(by: viewModel.gradeAndComment.0) { [weak self] in
                self?.setStarImage()
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
        let grade = Float(intGradeValue) / 2
        
        loadStarImages(by: grade) { [weak self] in
            self?.setStarImage()
        }
        
        if grade == 0 {
            deleteAlert()
        } else {
            updateGrade(by: grade)
        }
    }
    
    private func loadStarImages(by grade: Float , completion: @escaping () -> Void) {
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
    
    private func updateGrade(by grade: Float) {
        addAlert()
        viewModel.updateGrade(DOCID: movieInfo.DOCID, grade: grade)
    }
    
    private func deleteAlert() {
        
        if viewModel.gradeAndComment.0 == 0 { return }
        
        let alert = UIAlertController(title: "삭제하시겠습니까?", message: "등록된 코멘트도 함께 삭제됩니다", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.viewModel.deleteGradeAndComment(DOCID: self?.movieInfo.DOCID ?? "")
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
            self?.loadStarImages(by: self?.viewModel.gradeAndComment.0 ?? 0) {
                self?.setStarImage()
            }
        })
        parent.present(alert, animated: true)
    }
    
    private func addAlert() {
        if viewModel.userId == nil {
            let alert = UIAlertController(title: "서비스를 이용하려면 로그인하세요", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                self?.loadStarImages(by: 0) {
                    self?.setStarImage()
                }
            })
            parent.present(alert, animated: true)
        }
    }
}
