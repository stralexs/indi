//
//  StoryModeKitSelectionCollectionViewCell.swift
//  Indi
//
//  Created by Alexander Sivko on 19.05.23.
//

import RxSwift
import RxCocoa

final class StoryModeKitSelectionCollectionViewCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var testResultLabel: UILabel!
    @IBOutlet var progressViewHeight: NSLayoutConstraint!
    
    static let identifier = "StoryModeKitSelectionCollectionViewCell"
    private let disposeBag = DisposeBag()
    private var viewModel: StoryModeKitSelectionCollectionViewCellViewModelLogic!
    
    func configure(with viewModel: StoryModeKitSelectionCollectionViewCellViewModelLogic) {
        self.viewModel = viewModel
        setupBinders()
    }
    
    private func setupBinders() {
        viewModel.kitName.bind { self.label.text = $0 }
        .disposed(by: disposeBag)
        
        viewModel.testResult.bind {
            self.testResultLabel.text = "\($0)%"
            self.viewModel.countProgressHeight(with: self.frame.height)
        }
        .disposed(by: disposeBag)
        
        viewModel.progressHeight.bind {
            self.progressViewHeight.constant = $0
        }
        .disposed(by: disposeBag)
    }
}
