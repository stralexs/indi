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
        setupViewControllersViewModels()
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
    
    private func setupViewControllersViewModels() {
        guard let viewControllers = self.viewControllers else { return }
        
        viewControllers.forEach { viewController in
            var childViewController: UIViewController?
            
            if let navigationController = viewController as? UINavigationController {
                childViewController = navigationController.viewControllers.first
            }
            
            switch childViewController {
            case let viewController as StoryModeViewController:
                viewController.viewModel = StoryModeViewModel()
            case let viewController as TrainingModeViewController:
                viewController.viewModel = TrainingModeViewModel()
            default:
                break
            }
        }
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is NewKitSelectionViewController {
            if let newKitSelectionVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "NewKitSelectionVC") as? NewKitSelectionViewController {
                newKitSelectionVC.viewModel = NewKitSelectionViewModel()
                newKitSelectionVC.modalPresentationStyle = .overCurrentContext
                tabBarController.present(newKitSelectionVC, animated: true)
                return false
            }
        }

        return true
    }
}

