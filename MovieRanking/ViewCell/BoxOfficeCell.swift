//
//  BoxOfficeCell.swift
//  MovingMovie
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
        
        // cell 재사용 시 이미지 다운로드 완료전 이전 이미지 겹침 문제 발생 방지
        thumbnailImageView.image = nil
        newImageView.image = nil
    }
    
    
}
