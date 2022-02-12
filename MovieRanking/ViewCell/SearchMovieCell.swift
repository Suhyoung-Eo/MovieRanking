//
//  SearchMovieCell.swift
//  MovieRanking
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
        movieNameLabel.font = .systemFont(ofSize: 18)
        movieNameENLabel.font = .systemFont(ofSize: 13)
        movieNameENLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        dicrectorLabel.font = .systemFont(ofSize: 13)
        dicrectorLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        ratingLabel.font = .systemFont(ofSize: 13)
        ratingLabel.textColor = UIColor.black.withAlphaComponent(0.5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailImageView.image = nil
    }
}
