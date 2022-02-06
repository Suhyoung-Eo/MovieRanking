//
//  StaffsInfoCell.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/06.
//

import UIKit

protocol StaffsInfoCellDelegate: AnyObject {
    func didPushButton(data: Any)
}

class StaffsInfoCell: UITableViewCell {
    
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var firstActorLabel: UILabel!
    @IBOutlet weak var secondActorLabel: UILabel!
  
    weak var delegate: StaffsInfoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func staffsInfoViewButton(_ sender: Any) {
        delegate?.didPushButton(data: "staffView")
    }
}
