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
}
