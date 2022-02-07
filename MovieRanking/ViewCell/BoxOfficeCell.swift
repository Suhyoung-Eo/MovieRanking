//
//  BoxOfficeCell.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2021/11/18.
//

import UIKit

class BoxOfficeCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var newImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var openDateLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var audiAccLabel: UILabel!
    
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
        newImageView.image = nil
    }
    
    
}
