//
//  UserCommentCell.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/15.
//

import UIKit

protocol UserCommentCellDelegate: AnyObject {
    func pushedEditButton()
    func pushedThumbNailImageButton(index: Int)
}

class UserCommentCell: UITableViewCell {


    @IBOutlet weak var thumbNailImageButton: UIButton!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    weak var delegate: UserCommentCellDelegate?
    var index: Int = 0
    
    var thumbNailLink: String = "" {
        didSet {
            DownloadImage.shared.download(from: thumbNailLink) { [weak self] image in
                self?.thumbNailImageButton.setImage(image, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        thumbNailImageButton.layer.masksToBounds = true
        thumbNailImageButton.layer.cornerRadius = thumbNailImageButton.frame.width / 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        thumbNailImageButton.setImage(nil, for: .normal)
    }
    
    @IBAction func thumbNailImageButton(_ sender: Any) {
        delegate?.pushedThumbNailImageButton(index: index)
    }
    
    @IBAction func editButton(_ sender: Any) {
        delegate?.pushedEditButton()
    }
}
