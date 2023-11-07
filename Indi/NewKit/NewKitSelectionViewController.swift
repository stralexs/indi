//
//  NewKitSelectionViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 22.06.23.
//

import UIKit

final class NewKitSelectionViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet var topBlurredView: UIVisualEffectView!
    var viewModel: NewKitSelectionViewModelLogic?
    
    //MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneBlurredViewEffect()
        addTapGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBlurredView()
    }
    
    //MARK: - Methods
    private func tuneBlurredViewEffect() {
        topBlurredView.effect = nil
    }
    
    private func animateBlurredView() {
        UIView.animate(withDuration: 0.3) {
            self.topBlurredView.effect = UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterialDark)
        }
    }

    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissVC(_:)))
        topBlurredView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissVC(_ gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true)
        topBlurredView.effect = nil
    }
    
    @IBSegueAction private func presentNetworkNewKitViewController(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> NetworkNewKitViewController? {
        guard let viewModel = viewModel else { return nil }
        let networkNewKitViewController = NetworkNewKitViewController(coder: coder, viewModel: viewModel.viewModelForNetworkNewKit())
        networkNewKitViewController?.modalPresentationStyle = .fullScreen
        return networkNewKitViewController
    }
    
    @IBSegueAction private func presentUserNewKitViewController(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> UserNewKitViewController? {
        guard let viewModel = viewModel else { return nil }
        let userNewKitViewController = UserNewKitViewController(coder: coder, viewModel: viewModel.viewModelForUserNewKit())
        userNewKitViewController?.modalPresentationStyle = .fullScreen
        return userNewKitViewController
    }
}
