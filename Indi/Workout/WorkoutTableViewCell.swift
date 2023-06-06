//
//  WorkoutTableViewCell.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.accessoryType = selected ? .checkmark : .none
        self.backgroundColor = selected ? UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1) : .white
    }
}
