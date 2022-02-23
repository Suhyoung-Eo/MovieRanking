//
//  CommentCell.swift
//  MovingRanking
//
//  Created by Suhyoung Eo on 2022/02/07.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var emotionImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var firstStarImageView: UIImageView!
    @IBOutlet weak var secondStarImageView: UIImageView!
    @IBOutlet weak var thirdStarImageView: UIImageView!
    @IBOutlet weak var fourthStarImageView: UIImageView!
    @IBOutlet weak var fifthStarImageView: UIImageView!
    @IBOutlet weak var stateEmptyLabel: UILabel!
    
    private var starImages: [UIImage?] = []
    
    var grade: Float = 0.0 {
        didSet {
            emotionImageView.image = loadEmotionImage(grade: grade)
            loadStarImages(grade: grade) { [weak self] starImages in
                guard !starImages.isEmpty else { return }
                
                DispatchQueue.main.async {
                    self?.firstStarImageView.image = starImages[0]
                    self?.secondStarImageView.image = starImages[1]
                    self?.thirdStarImageView.image = starImages[2]
                    self?.fourthStarImageView.image = starImages[3]
                    self?.fifthStarImageView.image = starImages[4]
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        emotionImageView.image = nil
        firstStarImageView.image = nil
        secondStarImageView.image = nil
        thirdStarImageView.image = nil
        fourthStarImageView.image = nil
        fifthStarImageView.image = nil
    }
    
    private func loadEmotionImage(grade: Float) -> UIImage? {
        switch grade {
        case 0:
            return UIImage(named: K.Image.noIdeaFace)
        case 0.5, 1.0:
            return UIImage(named: K.Image.tooBadFace)!
        case 1.5, 2.0:
            return UIImage(named: K.Image.badFace)!
        case 2.5, 3.0:
            return UIImage(named: K.Image.normalFace)!
        case 3.5, 4.0:
            return UIImage(named: K.Image.goodFace)!
        case 4.5, 5.0:
            return UIImage(named: K.Image.veryGoodFace)!
        default:
            return nil
        }
    }
    
    private func loadStarImages(grade: Float , completion: @escaping ([UIImage?]) -> Void) {
        starImages = []
        var starImage: UIImage?
        
        for i in 1...5 {
            if Float(i) <= grade {
                starImage = UIImage(named: K.Image.starFull)
            } else if Float(i) - grade == 0.5 {
                starImage = UIImage(named: K.Image.starHalf)
            } else {
                starImage = nil
            }
            starImages.append(starImage)
        }
        
        completion(starImages)
    }
}
