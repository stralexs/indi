//
//  StatisticsTableViewCell.swift
//  Indi
//
//  Created by Alexander Sivko on 27.05.23.
//

import UIKit

class StatisticsTableViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var background: UIView!
    @IBOutlet var kitProgressView: UIView!
    @IBOutlet var kitProgressViewWidth: NSLayoutConstraint!
    @IBOutlet var progressNumber: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        tuneUI()
    }
    
    private func tuneUI() {
        background.backgroundColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
        background.layer.cornerRadius = 10
        background.clipsToBounds = true
        
        kitProgressView.backgroundColor = UIColor(red: 1, green: 102 / 255, blue: 102 / 255, alpha: 1)
    }
}
