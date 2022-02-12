//
//  MovieImageCell.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/06.
//

import UIKit

class MovieImageCell: UITableViewCell {

    @IBOutlet weak var stllImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        posterImageView.layer.cornerRadius = posterImageView.frame.height / 15
        movieNameLabel.font = .boldSystemFont(ofSize: 20)
        movieInfoLabel.font = .boldSystemFont(ofSize: 15)
        movieInfoLabel.textColor = UIColor.white.withAlphaComponent(0.8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
