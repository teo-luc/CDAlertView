//
//  ImageHelper.swift
//  Pods
//
//  Created by Candost Dagdeviren on 02/11/2016.
//
//

import UIKit.UIImage

open class ImageHelper {
    class open func loadImage(name: String?) -> UIImage? {
        if let n = name {
            let podBundle = Bundle(for: ImageHelper.self)
            if let url = podBundle.url(forResource: "CDAlertView", withExtension: "bundle") {
                let bundle = Bundle(url: url)
                return UIImage(named: n, in: bundle, compatibleWith: nil)
            } else {
                return UIImage(named: n, in: podBundle, compatibleWith: nil)
            }
        }
        return nil
    }
}
