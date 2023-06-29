//
//  KitSelectionViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 19.05.23.
//

import UIKit

class KitSelectionViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    
    var studyStageRawValue = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tuneUI()
    }
    
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
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureAction(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func longGestureAction(_ gesture: UITapGestureRecognizer) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        let location = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: location) {
            if KitsManager.shared.isBasicKitCheck(for: indexPath, for: studyStageRawValue) {
                let alert = UIAlertController(title: "Базовые наборы слов удалять нельзя", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Вы действительно хотите удалить этот набор слов?", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .destructive) { _ in
                    KitsManager.shared.deleteUserKit(for: indexPath, for: self.studyStageRawValue)
                    self.collectionView.reloadData()
                }
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
            }
        }
    }
}

extension KitSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return KitsManager.shared.countOfKits(for: studyStageRawValue)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! KitSelectionCollectionViewCell
        
        var totalHeight: Double {
            Double(cell.frame.height)
        }
        var coefficient: Double {
            totalHeight / 100
        }
        let kitName = KitsManager.shared.getKitName(for: studyStageRawValue, with: indexPath)

        cell.progressViewHeight.constant = CGFloat(Double(UserDataManager.shared.getUserResult(for: kitName)) * coefficient)
        cell.label.text = KitsManager.shared.getKitName(for: studyStageRawValue, with: indexPath)
        cell.testResultLabel.text = "\(UserDataManager.shared.getUserResult(for: kitName))%"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let testVC = sb.instantiateViewController(withIdentifier: "TestVC") as? TestViewController {
            NotificationCenter.default.post(name: Notification.Name(rawValue: chosenTestNotificationKey), object: (indexPath, studyStageRawValue))
            self.navigationController?.pushViewController(testVC, animated: true)
        }
    }
}
