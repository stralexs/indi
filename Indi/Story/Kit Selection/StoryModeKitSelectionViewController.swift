//
//  StoryModeKitSelectionViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 19.05.23.
//

import UIKit

final class StoryModeKitSelectionViewController: UIViewController {
    //MARK: - Variables
    @IBOutlet var collectionView: UICollectionView!
    var viewModel: StoryModeKitSelectionViewModelProtocol!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addLongGesture()
        tuneUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    //MARK: - Private Methods
    private func tuneUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.indiMainBlue
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 50
        layout.minimumLineSpacing = 50
        layout.itemSize = CGSize.init(width: 130, height: 130)

        collectionView.collectionViewLayout = layout
    }
    
    private func addLongGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureAction(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func longGestureAction(_ gesture: UITapGestureRecognizer) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        let location = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: location) {
            if viewModel.isBasicKitCheck(for: indexPath) {
                let alert = UIAlertController(title: "Базовые наборы слов удалять нельзя", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Вы действительно хотите удалить этот набор слов?", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .destructive) { [weak self] _ in
                    self?.viewModel.deleteUserKit(for: indexPath)
                    self?.collectionView.reloadData()
                }
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
            }
        }
    }
}

//MARK: - CollectionView Data Source and Delegate
extension StoryModeKitSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! StoryModeKitSelectionCollectionViewCell
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        cell.viewModel = cellViewModel
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let testVC = sb.instantiateViewController(withIdentifier: "TestVC") as? StoryModeTestingViewController {
            testVC.viewModel = viewModel.viewModelForTesting(indexPath)
            viewModel.postChosenTestNotification(for: indexPath)
            self.navigationController?.pushViewController(testVC, animated: true)
        }
    }
}
