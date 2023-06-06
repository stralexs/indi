//
//  NetworkingTableViewCell.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import UIKit

class NetworkingTableViewCell: UITableViewCell {
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
        background.backgroundColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
