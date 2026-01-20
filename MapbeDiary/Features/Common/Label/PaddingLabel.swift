//
//  PaddingLabel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/20/26.
//

import UIKit

class PaddingLabel: UILabel {
    var insets: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let s = super.sizeThatFits(
            CGSize(width: size.width - insets.left - insets.right,
                   height: size.height - insets.top - insets.bottom)
        )
        return CGSize(width: s.width + insets.left + insets.right,
                      height: s.height + insets.top + insets.bottom)
    }
}
