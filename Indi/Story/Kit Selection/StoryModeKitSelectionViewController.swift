//
//  StoryModeKitSelectionViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 19.05.23.
//

import RxSwift
import RxCocoa

final class StoryModeKitSelectionViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet var collectionView: UICollectionView!
    
    private let disposeBag = DisposeBag()
    var viewModel: (StoryModeKitSelectionViewModelData & StoryModeKitSelectionViewModelLogic)!
    
    //MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        addLongGesture()
        tuneUI()
    }
}

    // MARK: - Rx setup
extension StoryModeKitSelectionViewController {
    private func setupCollectionView() {
        viewModel.kits
            .bind(to: collectionView
                .rx.items(cellIdentifier: StoryModeKitSelectionCollectionViewCell.identifier, cellType: StoryModeKitSelectionCollectionViewCell.self)) { row, kit, cell in
                    cell.configure(with: self.viewModel.cellViewModel(for: row))
                }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { _ in
                guard let indexPath = self.collectionView.indexPathsForSelectedItems?.first else { return }
                let sb = UIStoryboard(name: "Main", bundle: nil)
                if let testVC = sb.instantiateViewController(withIdentifier: "TestVC") as? StoryModeTestingViewController {
                    testVC.viewModel = self.viewModel.viewModelForTesting(indexPath)
                    self.navigationController?.pushViewController(testVC, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func addLongGesture() {
        let longPressGesture = UILongPressGestureRecognizer()
        collectionView.addGestureRecognizer(longPressGesture)
        
        longPressGesture.rx.event.bind(onNext: { gesture in
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            let location = gesture.location(in: self.collectionView)
            if let indexPath = self.collectionView.indexPathForItem(at: location) {
                if self.viewModel.isBasicKitCheck(for: indexPath) {
                    self.presentBasicAlert(title: "Базовые наборы слов удалять нельзя", message: nil, actions: [.okAction], completionHandler: nil)
                } else {
                    let alert = UIAlertController(title: "Вы действительно хотите удалить этот набор слов?", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ок", style: .destructive) { _ in
                        self.viewModel.deleteUserKit(for: indexPath)
                    }
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true)
                }
            }
        })
        .disposed(by: disposeBag)
    }
}

    // MARK: - Functionality
extension StoryModeKitSelectionViewController {
    private func tuneUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .indiMainBlue
    }
}
