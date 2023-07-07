//
//  TrainingTableViewCell.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import UIKit

class TrainingModeTableViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.accessoryType = selected ? .checkmark : .none
        self.backgroundColor = selected ? UIColor.indiLightPink : .white
    }
}
