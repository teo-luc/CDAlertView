//
//  CDAlertHeaderView.swift
//  CDAlertView
//
//  Created by Candost Dagdeviren on 10/30/2016.
//  Copyright (c) 2016 Candost Dagdeviren. All rights reserved.
//

import UIKit.UIView

private extension CDAlertViewType {
    var fillColor: UIColor? {
        switch self {
        case .error:
            return UIColor(red: 235/255, green: 61/255, blue: 65/255, alpha: 1)
        case .success:
            return UIColor(red: 65/255, green: 158/255, blue: 57/255, alpha: 1)
        case .warning:
            return UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        case .notification:
            return UIColor(red: 27/255, green: 169/255, blue: 225/255, alpha: 1)
        case .alarm:
            return UIColor(red: 196/255, green: 52/255, blue: 46/255, alpha: 1)
        case .custom:
            return nil
        case .noImage:
            return nil
        }
    }
}

internal class CDAlertHeaderView: UIView {

    // MARK: Properties

    internal var circleFillColor: UIColor? {
        didSet {
            if let cfc = circleFillColor {
                fillColor = cfc
            }
        }
    }
    internal var isIconFilled: Bool = false
    internal var alertBackgroundColor: UIColor = UIColor.white.withAlphaComponent(0.9)
    internal var hasShadow: Bool = true
    private var fillColor: UIColor!
    private var type: CDAlertViewType?
    private var imageView: UIImageView?

    convenience init(type: CDAlertViewType?, isIconFilled: Bool) {
        self.init(frame: .zero)
        self.type = type
        self.isIconFilled = isIconFilled
        backgroundColor = UIColor.clear
        fillColor = type?.fillColor ?? UIColor.white.withAlphaComponent(0.9)
        imageView = createImageView()
        self.backgroundColor = UIColor.green
    }

    // MARK: UIView

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: rect.size.height/2, width: rect.size.width, height: rect.size.height/2),
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 8, height: 8))
        alertBackgroundColor.setFill()
        path.fill()

        switch type {
        case .noImage:
            break
        default:
            let curve = UIBezierPath(arcCenter: CGPoint(x: rect.size.width/2, y: 28*CDAlertView.scaleHeight),
                                     radius: 28*CDAlertView.scaleHeight,
                                     startAngle: 0,
                                     endAngle: CGFloat.pi,
                                     clockwise: false)
            alertBackgroundColor.setFill()
            curve.fill()

            let innerCircle = UIBezierPath(arcCenter: CGPoint(x: rect.size.width/2, y: 28*CDAlertView.scaleHeight),
                                           radius: 24*CDAlertView.scaleHeight,
                                           startAngle: 0,
                                           endAngle: 2 * CGFloat.pi,
                                           clockwise: true)
            fillColor.setFill()
            innerCircle.fill()

            if hasShadow {
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOpacity = 0.2
                layer.shadowRadius = 4
                layer.shadowOffset = CGSize.zero
                layer.masksToBounds = false
                let shadowPath = UIBezierPath()
                shadowPath.move(to: CGPoint(x: 0.0, y: rect.size.height))
                shadowPath.addLine(to: CGPoint(x: 0, y: rect.size.height/2))
                shadowPath.addLine(to: CGPoint(x: (rect.size.width/2)-15, y: rect.size.height/2))
                shadowPath.addArc(withCenter: CGPoint(x: rect.size.width/2, y: 28*CDAlertView.scaleHeight),
                                  radius: 28*CDAlertView.scaleHeight,
                                  startAngle: 0,
                                  endAngle: CGFloat.pi,
                                  clockwise: false)
                shadowPath.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height/2))
                shadowPath.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height))
                shadowPath.addLine(to: CGPoint(x: rect.size.width-10, y: rect.size.height-5))
                shadowPath.addLine(to: CGPoint(x: 10, y: rect.size.height-5))
                shadowPath.close()
                layer.shadowPath = shadowPath.cgPath
            }
        }
    }

    // MARK: Private

    private func createImageView() -> UIImageView? {
        guard let type = type else { return nil }

        let imageView = UIImageView(frame: .zero)
        var imageName: String?
        switch type {
        case .error:
            imageView.image = ImageHelper.loadImage(name: "error")
        case .success:
            imageView.image = ImageHelper.loadImage(name: "check")
        case .warning:
            imageName = isIconFilled ? "warningFilled" : "warningOutline"
            imageView.image = ImageHelper.loadImage(name: imageName)
        case .notification:
            imageName = isIconFilled ? "notificationFilled" : "notificationOutline"
            imageView.image = ImageHelper.loadImage(name: imageName)
        case .alarm:
            imageName = isIconFilled ? "alarmFilled" : "alarmOutline"
            imageView.image = ImageHelper.loadImage(name: imageName)
        case .custom(let image):
            imageView.image = image
        case .noImage:
            imageView.image = nil
        }

        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerHorizontally()
        imageView.centerVertically()
        imageView.setHeight(24*CDAlertView.scaleHeight)
        imageView.setWidth(24*CDAlertView.scaleHeight)

        return imageView
    }
}
