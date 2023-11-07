//
//  TrainingTableViewCell.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import UIKit

final class TrainingModeTableViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    
    var viewModel: TrainingModeTableViewCellViewModel! {
        didSet {
            label.text = viewModel.kitName
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
        self.backgroundColor = selected ? .indiLightPink : .white
    }
}
