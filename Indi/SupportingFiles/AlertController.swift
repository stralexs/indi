//
//  ViewControllerAlertControllerExtension.swift
//  Indi
//
//  Created by Alexander Sivko on 3.11.23.
//

import UIKit

struct CustomAlertAction: Equatable {
    let title: String
    let style: UIAlertAction.Style
    
    static let okAction: CustomAlertAction = .init(title: "Oк")
    static let cancelAction: CustomAlertAction = .init(title: "Отмена", style: .cancel)
    static let doneAction: CustomAlertAction = .init(title: "Готово")
    static let backToMenu: CustomAlertAction = .init(title: "В главное меню", style: .cancel)
    
    init(title: String, style: UIAlertAction.Style = .default) {
        self.title = title
        self.style = style
    }
}

extension UIViewController {
    func presentBasicAlert(title: String?, message: String?, alertStyle: UIAlertController.Style = .alert, actions: [CustomAlertAction], completionHandler: ((_ action: CustomAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        
        for action in actions {
            let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                guard let completionHandler = completionHandler else { return }
                completionHandler(action)
            }
            alertController.addAction(alertAction)
        }
        
        self.present(alertController, animated: true)
    }
}
