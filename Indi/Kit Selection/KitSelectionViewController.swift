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
        navigationItem.backBarButtonItem?.tintColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        
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
        let location = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: location) {
            if KitsLibrary.shared.isBasicKitCheck(for: indexPath, for: studyStageRawValue) {
                let alert = UIAlertController(title: "Базовые наборы слов удалять нельзя", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Вы действительно хотите удалить этот набор слов?", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .destructive) { _ in
                    KitsLibrary.shared.deleteUserKit(for: indexPath, for: self.studyStageRawValue)
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
        return KitsLibrary.shared.countOfKits(for: studyStageRawValue)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! KitCollectionViewCell
        cell.label.text = KitsLibrary.shared.getKitName(for: studyStageRawValue, with: indexPath)
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
