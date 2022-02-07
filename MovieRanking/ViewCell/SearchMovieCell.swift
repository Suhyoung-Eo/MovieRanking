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
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailImageView.image = nil
    }
}
