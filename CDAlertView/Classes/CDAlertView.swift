//
//  CDAlertView.swift
//  CDAlertView
//
//  Created by Candost Dagdeviren on 10/30/2016.
//  Copyright (c) 2016 Candost Dagdeviren. All rights reserved.
//

import AppRouter

public enum CDAlertViewType {
    case error, warning, success, notification, alarm, custom(image: UIImage), noImage
}

private protocol CDAlertViewActionDelegate: class {
    func didTap(action: CDAlertViewAction)
}

open class CDAlertViewAction: NSObject {
    @objc open dynamic var buttonTitle: String?
    @objc open dynamic var buttonTextColor: UIColor?
    @objc open dynamic var disablebuttonTextColor: UIColor = UIColor.lightGray
    @objc open dynamic var buttonFont: UIFont?
    @objc open dynamic var buttonBackgroundColor: UIColor?
    @objc open dynamic var enable = true
    @objc static public dynamic var defaultButtonTextColor = UIColor(red: 1, green: 0.4, blue: 0.2, alpha: 1)

    fileprivate weak var delegate: CDAlertViewActionDelegate?

    private var handlerBlock: ((CDAlertViewAction) -> Swift.Void)?

    public convenience init(title: String?,
                            font: UIFont? = UIFont.systemFont(ofSize: 17*CDAlertView.fontScale),
                            textColor: UIColor? = defaultButtonTextColor,
                            backgroundColor: UIColor? = nil,
                            handler: ((CDAlertViewAction) -> Swift.Void)? = nil) {
        self.init()
        buttonTitle = title
        buttonTextColor = textColor
        buttonFont = font
        buttonBackgroundColor = backgroundColor
        handlerBlock = handler
    }

    @objc func didTap() {
        if !enable {
            return
        }

        if let handler = handlerBlock {
            handler(self)
        }
        self.delegate?.didTap(action: self)
    }
}

open class CDAlertView: UIView {

    @objc open dynamic var actionSeparatorColor: UIColor = UIColor(red: 50/255,
                                                             green: 51/255,
                                                             blue: 53/255,
                                                             alpha: 0.12)
    @objc open dynamic var titleTextColor: UIColor = UIColor(red: 50/255,
                                                       green: 51/255,
                                                       blue: 53/255,
                                                       alpha: 1)

    @objc open dynamic var messageTextColor: UIColor = UIColor(red: 50/255,
                                                         green: 51/255,
                                                         blue: 53/255,
                                                         alpha: 1)

    @objc open dynamic var textFieldTextColor: UIColor = UIColor(red: 50/255,
                                                           green: 51/255,
                                                           blue: 53/255,
                                                           alpha: 1)

    @objc open dynamic var titleFont: UIFont = UIFont.boldSystemFont(ofSize: 17*fontScale) {
        didSet {
            titleLabel.font = titleFont
        }
    }

    @objc open dynamic var messageFont: UIFont = UIFont.systemFont(ofSize: 13*fontScale) {
        didSet {
            messageLabel.font = messageFont
        }
    }

    @objc open dynamic var textFieldFont: UIFont = UIFont.systemFont(ofSize: 15*fontScale) {
        didSet {
            textField.font = textFieldFont
        }
    }

    @objc open dynamic var textFieldReturnKeyType: UIReturnKeyType = .default {
        didSet {
            textField.returnKeyType = textFieldReturnKeyType
        }
    }

    @objc open dynamic var textFieldIsSecureTextEntry: Bool = false {
        didSet {
            textField.isSecureTextEntry = textFieldIsSecureTextEntry
        }
    }

    @objc open dynamic var textFieldTextAlignment: NSTextAlignment = .left {
        didSet {
            textField.textAlignment = textFieldTextAlignment
        }
    }

    @objc open dynamic var textFieldPlaceholderText: String? = nil {
        didSet {
            textField.placeholder = textFieldPlaceholderText
        }
    }

    @objc open dynamic var isTextFieldHidden: Bool = true {
        didSet {
            textField.isHidden = isTextFieldHidden

            if !isTextFieldHidden {
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            }
        }
    }

    @objc open dynamic var textFieldAutocapitalizationType: UITextAutocapitalizationType = .none {
        didSet {
            textField.autocapitalizationType = textFieldAutocapitalizationType
        }
    }

    @objc open dynamic var textFieldBackgroundColor: UIColor = UIColor.white.withAlphaComponent(0.9) {
        didSet {
            textField.backgroundColor = textFieldBackgroundColor
        }
    }

    @objc open dynamic var textFieldTintColor: UIColor = UIColor.white.withAlphaComponent(0.9) {
        didSet {
            textField.tintColor = textFieldTintColor
        }
    }

    @objc open dynamic var textFieldText: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }

    @objc open dynamic weak var textFieldDelegate: UITextFieldDelegate? {
        didSet {
            textField.delegate = textFieldDelegate
        }
    }

    @objc open dynamic var textFieldChangeBlock: (() -> Void)?

    @objc open dynamic var customView: UIView?

    @objc open dynamic var isCustomViewBottom = false

    open var hideAnimations: CDAlertAnimationBlock?

    @objc open dynamic var hideAnimationDuration: TimeInterval = 0.5

    @objc open dynamic var textFieldHeight: CGFloat = 35.0*scaleHeight

    @objc open dynamic var isActionButtonsVertical: Bool = false

    @objc open dynamic var hasShadow: Bool = true

    @objc open dynamic var isHeaderIconFilled: Bool = false

    @objc open dynamic var alertBackgroundColor: UIColor = UIColor.white.withAlphaComponent(0.9)

    @objc open dynamic var circleFillColor: UIColor?

    @objc open dynamic var popupWidth: CGFloat = 300.0 * scaleWidth

    public typealias CDAlertAnimationBlock = ((_ center: inout CGPoint, _ transform: inout CGAffineTransform, _ alpha: inout CGFloat) -> Void)?

    fileprivate var popupCenterYPositionBeforeKeyboard: CGFloat?

    fileprivate var popupView: UIView = UIView(frame: .zero)

    fileprivate var popupCenter: CGPoint {
        get {
            return popupView.center
        }
        set {
            popupView.center = newValue
        }
    }

    fileprivate var popupTransform: CGAffineTransform {
        get {
            return popupView.transform
        }
        set {
            popupView.transform = newValue
        }
    }

    fileprivate var popupAlpha: CGFloat {
        get {
            return popupView.alpha
        }
        set {
            popupView.alpha = newValue
        }
    }

    private struct CDAlertViewConstants {
        let headerHeight: CGFloat = 56*scaleHeight
        let noHeaderHeight: CGFloat = 16*scaleHeight
        let activeVelocity: CGFloat = 150
        let minVelocity: CGFloat = 300
        let separatorThickness: CGFloat = 1.0/UIScreen.main.scale
    }

    private var buttonsHeight: CGFloat {
        get {
            return self.actions.count > 0 ? 44.0*CDAlertView.scaleHeight : 0
        }
    }

    private var popupViewInitialFrame: CGRect!
    private let constants = CDAlertViewConstants()
    private var backgroundView: UIView = UIView(frame: .zero)
    private var coverView: UIView = UIView(frame: .zero)
    private var completionBlock: ((CDAlertView) -> Swift.Void)?
    private var contentStackView: UIStackView = UIStackView(frame: .zero)
    private var buttonContainer: UIStackView = UIStackView(frame: .zero)
    private var headerView: CDAlertHeaderView!
    private var buttonView: UIView = UIView(frame: .zero)
    private var titleLabel: UILabel = UILabel(frame: .zero)
    private var messageLabel: ContextLabel = ContextLabel(frame: .zero)
    private var messageScrollView: UIScrollView = UIScrollView(frame: .zero)
    private var constraintScrollViewHeight: NSLayoutConstraint?
    private var textField: ScalingTextField = ScalingTextField(frame: .zero)
    private var type: CDAlertViewType!
    private lazy var actions: [CDAlertViewAction] = [CDAlertViewAction]()

    public convenience init(title: String?,
                            message: String?,
                            type: CDAlertViewType = .noImage) {
        self.init(frame: .zero)

        self.type = type
        backgroundColor = UIColor(red: 50/255, green: 51/255, blue: 53/255, alpha: 0.4)
        if let t = title {
            titleLabel.text = t
        }

        if let m = message {
            messageLabel.text = m
        }

        self.type = type
        startObservingContentSizeChangesInScrollView()
    }

    deinit {
        stopObservingContentSizeChangesInScrollView()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if hasShadow {
            popupView.layer.shadowColor = UIColor.black.cgColor
            popupView.layer.shadowOpacity = 0.2
            popupView.layer.shadowRadius = 4
            popupView.layer.shadowOffset = CGSize.zero
            popupView.layer.masksToBounds = false
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0, y: popupView.bounds.size.height))
            path.addLine(to: CGPoint(x: 0, y: constants.headerHeight))
            path.addLine(to: CGPoint(x: popupView.bounds.size.width,
                                     y: CGFloat(constants.headerHeight-5)))
            path.addLine(to: CGPoint(x: popupView.bounds.size.width,
                                     y: popupView.bounds.size.height))
            path.close()
            popupView.layer.shadowPath = path.cgPath
        }
    }

    public func show(_ completion: ((CDAlertView) -> Void)? = nil) {
        AppRouter.window.addSubview(self)
        //        UIApplication.shared.keyWindow?.addSubview(self)
        alignToParent(with: 0)
        addSubview(backgroundView)
        backgroundView.alignToParent(with: 0)
        if !isActionButtonsVertical && actions.count > 3 {
            debugPrint("CDAlertView: You can't use more than 3 actions in horizontal mode. If you need more than 3 buttons, consider using vertical alignment for buttons. Setting vertical alignments for buttons is available via isActionButtonsVertical property of AlertView")
            actions.removeSubrange(3..<actions.count)
        }
        createViews()
        loadActionButtons()
        popupViewInitialFrame = popupView.frame

        var offScreenCenter = self.popupView.center
        offScreenCenter.y += self.constants.minVelocity * 3
        self.popupView.center = offScreenCenter
        self.alpha = 0
        UIView.animate(withDuration: 0.25,
                       animations: { [unowned self] in
                        self.popupView.frame = self.popupViewInitialFrame
                        self.alpha = 1
            },
                       completion: {[weak self] (_) in
                        self?.messageScrollView.flashScrollIndicators()
        })

        completionBlock = completion
    }

    open func hide(animations: CDAlertAnimationBlock? = nil,
                   isPopupAnimated: Bool) {
        if !isTextFieldHidden {
            textField.resignFirstResponder()
            NotificationCenter.default.removeObserver(self)
        }

        UIView.animate(withDuration: hideAnimationDuration,
                       animations: { [unowned self] in
                        if isPopupAnimated {
                            if let animations = animations {
                                animations?(&self.popupCenter, &self.popupTransform, &self.popupAlpha)
                            } else {
                                var offScreenCenter = self.popupView.center
                                offScreenCenter.y += self.constants.minVelocity * 3
                                self.popupView.center = offScreenCenter
                                self.alpha = 0
                            }
                        }
            },
                       completion: { (_) in
                        self.removeFromSuperview()
                        if let completion = self.completionBlock {
                            completion(self)
                        }
        })

    }

    open func add(action: CDAlertViewAction) {
        actions.append(action)
    }

    open func textFieldBecomeFirstResponder() {
        if !isTextFieldHidden {
            textField.becomeFirstResponder()
        }
    }

    open func textFieldResignFirstResponder() {
        if !isTextFieldHidden {
            textField.resignFirstResponder()
        }
    }

    open override func touchesEnded(_ touches: Set<UITouch>,
                                    with event: UIEvent?) {
        if actions.count == 0 {
            touches.forEach { (touch) in
                if touch.view == self.backgroundView {
                    self.hide(animations: self.hideAnimations, isPopupAnimated: true)
                }
            }
        }
    }

    // MARK: - Observing
    private var myContext = 0
    private func startObservingContentSizeChangesInScrollView() {
        messageScrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .new, context: &myContext)
    }

    private func stopObservingContentSizeChangesInScrollView() {
        messageScrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), context: &myContext)
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            if let newSize = change?[.newKey] as? CGSize {
                if let _object = object as? UIScrollView, _object == messageScrollView {
                    constraintScrollViewHeight?.constant = min(newSize.height, 290*CDAlertView.scaleHeight)
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    @objc open func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if let coverViewWindowCoordinates = popupView.superview?.convert(CGPoint(x: 0, y: popupView.frame.maxY), to: nil) {
                    let padding: CGFloat = 20
                    if coverViewWindowCoordinates.y > (keyboardSize.minY - padding) {
                        popupCenterYPositionBeforeKeyboard = popupView.center.y
                        let difference = coverViewWindowCoordinates.y - (keyboardSize.minY - padding)
                        popupView.center.y -= difference
                    }
                }
            }
        }
    }

    @objc open func keyboardWillHide(_ notification: Notification) {
        if let initialY = self.popupCenterYPositionBeforeKeyboard {
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .allowAnimatedContent, animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.popupView.center.y = initialY
            })
        }
    }

    @objc open func popupMoved(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: backgroundView)
        UIView.animate(withDuration: 0, animations: {
            self.popupView.center = location
        })

        if recognizer.state == .ended {
            let location = recognizer.location(in: backgroundView)
            let origin = CGPoint(x: backgroundView.center.x - popupViewInitialFrame.size.width/2,
                                 y: backgroundView.center.y - popupViewInitialFrame.size.height/2)
            let velocity = recognizer.velocity(in: backgroundView)
            if !CGRect(origin: origin,
                       size: popupViewInitialFrame.size).contains(location) ||
                (velocity.x > constants.activeVelocity || velocity.y > constants.activeVelocity) {
                UIView.animate(withDuration: 1, animations: {
                    self.popupView.center = self.calculatePopupViewOffScreenCenter(from: velocity)
                    self.hide(animations: self.hideAnimations, isPopupAnimated: false)
                })
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    self.popupView.center = self.backgroundView.center
                })
            }
        } else if recognizer.state == .cancelled {
            UIView.animate(withDuration: 0, animations: {
                self.popupView.center = self.backgroundView.center
            })
        }
    }

    open func getButtonForAction(action: CDAlertViewAction) -> UIButton? {
        if let index = actions.firstIndex(of: action) {
            for view in buttonContainer.arrangedSubviews {
                if let _button = view as? UIButton,
                    _button.tag == 100 + index {
                    return _button
                }
            }
        }
        return nil
    }

    // MARK: Private

    private func calculatePopupViewOffScreenCenter(from velocity: CGPoint) -> CGPoint {
        var velocityX = velocity.x
        var velocityY = velocity.y
        var offScreenCenter = popupView.center

        velocityX = velocityX >= 0 ?
            (velocityX < constants.minVelocity ? 0 : velocityX) :
            (velocityX > -constants.minVelocity ? 0 : velocityX)

        velocityY = velocityY >= 0 ?
            (velocityY < constants.minVelocity ? constants.minVelocity : velocityY) :
            (velocityY > -constants.minVelocity ? -constants.minVelocity : velocityY)

        offScreenCenter.x += velocityX
        offScreenCenter.y += velocityY

        return offScreenCenter
    }

    private func roundBottomOfCoverView() {
        let roundCornersPath = UIBezierPath(roundedRect: CGRect(x: 0.0,
                                                                y: 0.0,
                                                                width: popupWidth,
                                                                height: coverView.frame.size.height),
                                            byRoundingCorners: [.bottomLeft, .bottomRight],
                                            cornerRadii: CGSize(width: 8.0,
                                                                height: 8.0))
        let roundLayer = CAShapeLayer()
        roundLayer.path = roundCornersPath.cgPath
        coverView.layer.mask = roundLayer
    }

    private func createViews() {
        popupView.backgroundColor = UIColor.clear
        backgroundView.addSubview(popupView)

        createHeaderView()
        createButtonContainer()
        createStackView()
        createTitleLabel()

        if isCustomViewBottom {
            createMessageLabel()
            if let customView = customView {
                createCustomView(customView)
            }
        } else {
            if let customView = customView {
                createCustomView(customView)
            }
            createMessageLabel()
        }

        if !isTextFieldHidden {
            createTextField()
        }

        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.centerHorizontally()
        popupView.centerVertically()
        popupView.setWidth(popupWidth)
        popupView.setMaxHeight(UIScreen.main.bounds.size.height - 40)
        popupView.sizeToFit()
        popupView.layoutIfNeeded()
        if actions.count == 0 {
            roundBottomOfCoverView()

            let gestureRecognizer = UIPanGestureRecognizer(target: self,
                                                           action: #selector(popupMoved(recognizer:)))
            popupView.addGestureRecognizer(gestureRecognizer)
        }
    }

    private func createHeaderView() {
        headerView = CDAlertHeaderView(type: type, isIconFilled: isHeaderIconFilled)
        headerView.backgroundColor = UIColor.clear
        headerView.hasShadow = hasShadow
        headerView.alertBackgroundColor = alertBackgroundColor
        headerView.circleFillColor = circleFillColor
        popupView.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.alignTopToParent(with: 0)
        headerView.alignLeftToParent(with: 0)
        headerView.alignRightToParent(with: 0)
        switch type {
        case .noImage:
            headerView.setHeight(constants.noHeaderHeight)
        default:
            headerView.setHeight(constants.headerHeight)
        }
    }

    private func createButtonContainer() {
        var height = buttonsHeight + constants.separatorThickness
        buttonView.backgroundColor = UIColor.clear
        buttonView.layer.masksToBounds = true
        if isActionButtonsVertical {
            height = (buttonsHeight + constants.separatorThickness) * CGFloat(actions.count)
        }
        let roundCornersPath = UIBezierPath(roundedRect: CGRect(x: 0.0,
                                                                y: 0.0,
                                                                width: popupWidth,
                                                                height: height),
                                            byRoundingCorners: [.bottomLeft, .bottomRight],
                                            cornerRadii: CGSize(width: 8.0, height: 8.0))
        let roundLayer = CAShapeLayer()
        roundLayer.path = roundCornersPath.cgPath
        buttonView.layer.mask = roundLayer
        popupView.addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.alignBottomToParent(with: 0)
        buttonView.alignLeftToParent(with: 0)
        buttonView.alignRightToParent(with: 0)
        if actions.count == 0 {
            buttonView.setHeight(0)
        } else {

            let backgroundColoredView = UIView(frame: .zero)
            backgroundColoredView.backgroundColor = actionSeparatorColor
            buttonView.addSubview(backgroundColoredView)
            backgroundColoredView.alignToParent(with: 0)

            buttonContainer.spacing = constants.separatorThickness
            if isActionButtonsVertical {
                buttonContainer.axis = .vertical
            } else {
                buttonContainer.axis = .horizontal
            }
            buttonView.setHeight(height)
            buttonContainer.translatesAutoresizingMaskIntoConstraints = false
            backgroundColoredView.addSubview(buttonContainer)
            buttonContainer.alignTopToParent(with: constants.separatorThickness)
            buttonContainer.alignBottomToParent(with: 0)
            buttonContainer.alignLeftToParent(with: 0)
            buttonContainer.alignRightToParent(with: 0)
            buttonContainer.distribution = .fillEqually
        }
    }

    private func createStackView() {
        coverView.backgroundColor = alertBackgroundColor
        popupView.addSubview(coverView)
        coverView.translatesAutoresizingMaskIntoConstraints = false
        coverView.alignLeftToParent(with: 0)
        coverView.alignRightToParent(with: 0)
        coverView.place(below: headerView, margin: 0)
        coverView.place(above: buttonView, margin: 0)
        contentStackView.distribution = .equalSpacing
        contentStackView.axis = .vertical
        contentStackView.spacing = 8*CDAlertView.scaleHeight
        coverView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.alignTopToParent(with: 0)
        contentStackView.alignBottomToParent(with: 16*CDAlertView.scaleHeight)
        contentStackView.alignRightToParent(with: 16)
        contentStackView.alignLeftToParent(with: 16)
    }

    private func createTitleLabel() {
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.setMaxHeight(100*CDAlertView.scaleHeight)
        titleLabel.textColor = titleTextColor
        titleLabel.font = titleFont
        contentStackView.addArrangedSubview(titleLabel)
    }

    private func createMessageLabel() {
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //        messageLabel.textColor = messageTextColor
        messageLabel.foregroundColor = { [weak self] (linkResult) in
            switch linkResult.detectionType {
            case .userHandle:
                return UIColor(red: 71.0/255.0, green: 90.0/255.0, blue: 109.0/255.0, alpha: 1.0)
            case .hashtag:
                return UIColor(red: 151.0/255.0, green: 154.0/255.0, blue: 158.0/255.0, alpha: 1.0)
            case .url:
                return UIColor(red: 45.0/255.0, green: 113.0/255.0, blue: 178.0/255.0, alpha: 1.0)
            case .textLink:
                return UIColor(red: 45.0/255.0, green: 113.0/255.0, blue: 178.0/255.0, alpha: 1.0)
            default:
                return self?.messageTextColor ?? .black
            }
        }
        messageLabel.didTouch = {(touchResult) in

            if touchResult.state == .ended {
                if let linkResult = touchResult.linkResult {
                    switch linkResult.detectionType {
                    case .url:

                        if let url = URL(string: Utils.getHttpsUrl(url: linkResult.text)),
                            UIApplication.shared.canOpenURL(url) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                // Fallback on earlier versions
                                UIApplication.shared.openURL(url)
                            }
                        }
                        break
                    default:
                        break
                    }
                }
            }
        }
        messageLabel.minimumScaleFactor = 0.3
        messageLabel.font = messageFont
        messageScrollView.addSubview(messageLabel)
        messageLabel.alignToParent(with: 0)
        messageLabel.centerHorizontally()
        constraintScrollViewHeight = NSLayoutConstraint(item: messageScrollView,
                                                        attribute: .height,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1,
                                                        constant: 0)
        messageScrollView.addConstraint(constraintScrollViewHeight!)
        contentStackView.addArrangedSubview(messageScrollView)
    }

    private func createCustomView(_ custom: UIView) {
        custom.clipsToBounds = true
        contentStackView.addArrangedSubview(custom)
    }

    private func createTextField() {
        if textFieldDelegate == nil {
            textField.delegate = self
        }

        textField.font = textFieldFont
        textField.textColor = textFieldTextColor
        textField.clearButtonMode = .whileEditing
        textField.isSecureTextEntry = textFieldIsSecureTextEntry
        textField.returnKeyType = textFieldReturnKeyType
        textField.textAlignment = textFieldTextAlignment
        textField.borderStyle = .roundedRect
        textField.isHidden = isTextFieldHidden
        textField.placeholder = textFieldPlaceholderText
        textField.autocapitalizationType = textFieldAutocapitalizationType
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 5
        textField.setHeight(textFieldHeight)
        contentStackView.addArrangedSubview(textField)
    }

    private func loadActionButtons() {
        guard actions.count != 0 else { return }
        for action in buttonContainer.arrangedSubviews {
            buttonContainer.removeArrangedSubview(action)
        }

        for (index, action) in actions.enumerated() {
            action.delegate = self
            let button = UIButton(type: .system)
            if let bc = action.buttonBackgroundColor {
                button.backgroundColor = bc
            } else {
                button.backgroundColor = alertBackgroundColor
            }

            button.isEnabled = action.enable
            button.setTitle(action.buttonTitle, for: .normal)
            button.setTitleColor(action.buttonTextColor, for: .normal)
            button.setTitleColor(action.disablebuttonTextColor, for: .disabled)
            button.titleLabel?.font = action.buttonFont
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.addTarget(action, action: #selector(action.didTap), for: .touchUpInside)
            button.accessibilityIdentifier = "CDAlertView-Button-\(index)"
            if let index = actions.firstIndex(of: action) {
                button.tag = 100 + index
            }
            buttonContainer.addArrangedSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            //            if isActionButtonsVertical {
            //                button.setWidth(buttonContainer.frame.size.width)
            //            } else {
            //                button.setWidth((buttonContainer.frame.size.width-CGFloat(actions.count-1) * constants.separatorThickness)/CGFloat(actions.count))
            //            }

            button.setHeight(CGFloat(buttonsHeight))
        }
    }
}

extension CDAlertView: CDAlertViewActionDelegate {
    internal func didTap(action: CDAlertViewAction) {
        self.hide(animations: self.hideAnimations, isPopupAnimated: true)
    }
}

extension CDAlertView: UITextFieldDelegate {
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let _textFieldChangeBlock = textFieldChangeBlock {
            _textFieldChangeBlock()
        }
        return true
    }

    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let _textFieldChangeBlock = textFieldChangeBlock {
            _textFieldChangeBlock()
        }
        return true
    }
}
