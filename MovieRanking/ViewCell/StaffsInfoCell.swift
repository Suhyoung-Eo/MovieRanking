//
//  StaffsInfoCell.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/06.
//

import UIKit

protocol StaffsInfoCellDelegate: AnyObject {
    func pushedStaffsInfoViewButton(data: Any)
}

class StaffsInfoCell: UITableViewCell {
    
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var firstActorLabel: UILabel!
    @IBOutlet weak var secondActorLabel: UILabel!
  
    weak var delegate: StaffsInfoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        directorLabel.font = .systemFont(ofSize: 17)
        firstActorLabel.font = .systemFont(ofSize: 17)
        secondActorLabel.font = .systemFont(ofSize: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func staffsInfoViewButton(_ sender: Any) {
        delegate?.pushedStaffsInfoViewButton(data: K.Prepare.staffView)
    }
}
