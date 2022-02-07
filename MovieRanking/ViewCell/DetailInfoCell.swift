//
//  DetailInfoCell.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/06.
//

import UIKit

class DetailInfoCell: UITableViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var directorsLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var nationLabel: UILabel!
    @IBOutlet weak var prodYearLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var movieNameOrgLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.showsHorizontalScrollIndicator = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
