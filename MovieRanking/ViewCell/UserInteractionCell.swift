//
//  UserInteractionCell.swift
//  MovingRanKing
//
//  Created by Suhyoung Eo on 2022/02/07.
//

import UIKit

protocol UserInteractionCellDelegate: AnyObject {
    func pushedAddCommentButton(data: Any)
    func pushedWishToWatchButton()
}

class UserInteractionCell: UITableViewCell {

    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var wishToWatchButton: UIButton!

    weak var delegate: UserInteractionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func addCommentButton(_ sender: Any) {
        delegate?.pushedAddCommentButton(data: K.Prepare.addCommentView)
    }
    
    @IBAction func wishToWatchButton(_ sender: Any) {
        delegate?.pushedWishToWatchButton()
    }
}
