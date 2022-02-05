//
//  SearchMovieCell.swift
//  MovingMovie
//
//  Created by Suhyoung Eo on 2022/02/05.
//

import UIKit

class SearchMovieCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieNameENLabel: UILabel!
    @IBOutlet weak var dicrectorLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnailImageView.layer.cornerRadius = thumbnailImageView.frame.height / 15
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // cell 재사용 시 이미지 다운로드 완료전 이전 이미지 겹침 문제 발생 방지
        thumbnailImageView.image = nil
    }
}
