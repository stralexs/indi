//
//  UserNewKitTableViewCell.swift
//  Indi
//
//  Created by Alexander Sivko on 23.05.23.
//

import UIKit

class UserNewKitTableViewCell: UITableViewCell {
    @IBOutlet var background: UIView!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var correctAnswerLabel: UILabel!
    @IBOutlet var firstIncorrectAnswer: UILabel!
    @IBOutlet var secondIncorrectAnswer: UILabel!
    @IBOutlet var thirdIncorrectAnswer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tuneUI()
    }
    
    private func tuneUI() {
        background.backgroundColor = UIColor.indiLightPink
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
