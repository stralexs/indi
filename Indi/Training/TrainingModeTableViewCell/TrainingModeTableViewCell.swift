//
//  TrainingTableViewCell.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import RxSwift
import RxCocoa

final class TrainingModeTableViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    
    static let identifier = "TrainingModeTableViewCell"
    private let disposeBag = DisposeBag()
    private var viewModel: TrainingModeTableViewCellViewModelLogic?
    
    func configure(with viewModel: TrainingModeTableViewCellViewModelLogic) {
        self.viewModel = viewModel
        setupBinder()
    }
    
    private func setupBinder() {
        viewModel?.kitName.bind { self.label.text = $0 }
            .disposed(by: disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
        self.backgroundColor = selected ? .indiLightPink : .white
    }
}
