//
//  AddCommentViewController.swift
//  MovingRanking
//
//  Created by Suhyoung Eo on 2022/02/07.
//

import UIKit

class AddCommentViewController: UIViewController {

    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!

    var movieId: String = ""
    var movieName: String = ""

    private var grade: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
        
        movieNameLabel.text = movieName
        gradeLabel.text = "0.0"
    }
    
    @IBAction func confirmButton(_ sender: Any) {
        
    }
    
    @IBAction func ratingSlider(_ sender: UISlider) {
        let intGradeValue = Int(sender.value.rounded()) // range: 0 ~ 10
        
        // tag되어 있는 별(UIImageView) 사용
        for i in 1...5 {
            if let starImage = view.viewWithTag(i) as? UIImageView {
                if i * 2 <= intGradeValue {
                    starImage.image = UIImage(named: K.Image.starFull)
                } else if (i * 2) - intGradeValue == 1 {
                    starImage.image = UIImage(named: K.Image.starHalf)
                } else {
                    starImage.image = UIImage(named: K.Image.starEmpty)
                }
            }
        }
        
        grade = Float(intGradeValue) / 2
        gradeLabel.text = String(format: "%.1f", grade)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - UITextView delegate methods

extension AddCommentViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
}
