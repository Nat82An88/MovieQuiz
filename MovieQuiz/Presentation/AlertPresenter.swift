import UIKit

final class AlertPresenter {
    
    // MARK: - Private Properties
    
    private weak var viewController: UIViewController?
    
    // MARK: - Initializers
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Public Methods
    
    func presentAlert(with model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) {_ in
            model.completion?()
        }
        
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
