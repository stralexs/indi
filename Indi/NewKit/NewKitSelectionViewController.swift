//
//  NewKitSelectionViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 22.06.23.
//

import UIKit

final class NewKitSelectionViewController: UIViewController {
    //MARK: - Variables
    @IBOutlet var topBlurredView: UIVisualEffectView!
    @IBOutlet var buttonsBackgroundView: UIView!
    @IBOutlet var newKitButtons: [UIButton]!
    
    var viewModel: NewKitSelectionViewModelProtocol!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI()
        addTapGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.topBlurredView.effect = UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterialDark)
        }
    }
    
    //MARK: - Methods
    private func tuneUI() {
        buttonsBackgroundView.layer.cornerRadius = 15
        buttonsBackgroundView.backgroundColor = UIColor.indiMainYellow
        
        newKitButtons.forEach { button in
            button.layer.cornerRadius = 10
            button.backgroundColor = UIColor.white
        }
        
        topBlurredView.effect = nil
    }

    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissVC(_:)))
        topBlurredView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissVC(_ gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true)
        topBlurredView.effect = nil
    }
    
    @IBSegueAction func presentNetworkNewKitViewController(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> NetworkNewKitViewController? {
        let networkNewKitViewController = NetworkNewKitViewController(coder: coder, viewModel: viewModel.viewModelForNetworkNewKit())
        networkNewKitViewController?.modalPresentationStyle = .fullScreen
        return networkNewKitViewController
    }
    
    @IBSegueAction private func presentUserNewKitViewController(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> UserNewKitViewController? {
        let userNewKitViewController = UserNewKitViewController(coder: coder, viewModel: viewModel.viewModelForUserNewKit())
        userNewKitViewController?.modalPresentationStyle = .fullScreen
        return userNewKitViewController
    }
}
