import UIKit

extension UIAlertController {
    /// Add a textField
    ///
    /// - Parameters:
    ///   - height: textField height
    ///   - hInset: right and left margins to AlertController border
    ///   - vInset: bottom margin to button
    ///   - configuration: textField

    func addOneTextField(configuration: TextField.Config?) {
        let textField = OneTextFieldViewController(vInset: preferredStyle == .alert ? 12 : 0, configuration: configuration)
        let height: CGFloat = OneTextFieldViewController.Ui.height + OneTextFieldViewController.Ui.vInset
        set(vc: textField, height: height)
    }
}

final class OneTextFieldViewController: UIViewController {
    fileprivate lazy var textField = TextField()

    struct Ui {
        static let height: CGFloat = 44
        static let hInset: CGFloat = 12
        static var vInset: CGFloat = 12
    }

    init(vInset: CGFloat = 12, configuration: TextField.Config?) {
        super.init(nibName: nil, bundle: nil)
        view.addSubview(textField)
        Ui.vInset = vInset

        /// have to set textField frame width and height to apply cornerRadius
        textField.height = Ui.height
        textField.width = view.width

        configuration?(textField)

        preferredContentSize.height = Ui.height + Ui.vInset
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        aLog("has deinitialized")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        textField.width = view.width - Ui.hInset * 2
        textField.height = Ui.height
        textField.center.x = view.center.x
        textField.center.y = view.center.y - Ui.vInset / 2
    }
}
