//
//  NetworkNewKitViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import UIKit

final class NetworkNewKitViewController: NewKitViewController {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var noInternetImage: UIImageView!
    @IBOutlet var noInternetLabel: UILabel!
                    
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI()
        setupBinders()
        noInternetConnectionAlert()
    }
    
    override func tuneUI() {
        super.tuneUI()
        activityIndicator.startAnimating()
        noInternetImage.image = UIImage(named: "Dino-no-internet")
        noInternetImage.isHidden = true
        noInternetLabel.isHidden = true
    }
    
    override func setupBinders() {
        super.setupBinders()
        viewModel.questions.bind { [weak self] _ in
            if let viewModel = self?.viewModel as? NetworkNewKitViewModel {
                viewModel.retrieveQuestions {
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        self?.activityIndicator.isHidden = true
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func noInternetConnectionAlert() {
        if let viewModel = viewModel as? NetworkNewKitViewModel {
            if viewModel.isConnectedToInternet == false {
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title: "Нет соединения с интернетом", message: "Пожалуйста, проверьте ваше подключение и попробуйте ещё раз", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ок", style: .default)
                    alert.addAction(okAction)
                    self?.present(alert, animated: true)
                    
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                    self?.noInternetImage.isHidden = false
                    self?.noInternetLabel.isHidden = false
                }
            }
        }
    }
}
