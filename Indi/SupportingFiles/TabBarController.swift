//
//  TabBarController.swift
//  Indi
//
//  Created by Alexander Sivko on 18.06.23.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI()
    }
    
    private func tuneUI() {
        tabBar.tintColor = UIColor.indiMainYellow
        tabBar.unselectedItemTintColor = UIColor.white
        tabBar.backgroundImage = UIImage()
        tabBar.backgroundColor = UIColor.indiDarkPurple
        tabBar.shadowImage = UIImage ()
        tabBar.layer.masksToBounds = true
        tabBar.isTranslucent = true
        tabBar.layer.cornerRadius = 30
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.delegate = self
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is NewKitSelectionViewController {
            if let newKitSelectionVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "NewKitSelectionVC") {
                newKitSelectionVC.modalPresentationStyle = .overCurrentContext
                tabBarController.present(newKitSelectionVC, animated: true)
                return false
            }
        }

        return true
    }
}

