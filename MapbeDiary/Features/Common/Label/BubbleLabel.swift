//
//  BubbleLabel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/18/26.
//

import UIKit

final class BubbleLabel: UILabel {
    var insets: UIEdgeInsets = .zero
    var cornerRadius: CGFloat = 8
    var tailSize: CGSize = CGSize(width: 12, height: 8)
    var tailOffset: CGFloat = 12
    var tailDirection: TailDirection = .bottomLeft

    private let bubbleMaskLayer = CAShapeLayer()

    enum TailDirection {
        case bottomLeft
        case bottomRight
        case topLeft
        case topRight
    }

    private var effectiveInsets: UIEdgeInsets {
        switch tailDirection {
        case .topLeft, .topRight:
            return UIEdgeInsets(
                top: insets.top + tailSize.height,
                left: insets.left,
                bottom: insets.bottom,
                right: insets.right
            )
        case .bottomLeft, .bottomRight:
            return UIEdgeInsets(
                top: insets.top,
                left: insets.left,
                bottom: insets.bottom + tailSize.height,
                right: insets.right
            )
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let maxTextWidth = max(0, bounds.width - effectiveInsets.left - effectiveInsets.right)
        if preferredMaxLayoutWidth == 0 && maxTextWidth > 0 {
            preferredMaxLayoutWidth = maxTextWidth
            invalidateIntrinsicContentSize()
        }
        bubbleMaskLayer.frame = bounds
        bubbleMaskLayer.path = bubblePath().cgPath
        layer.mask = bubbleMaskLayer
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetBounds = bounds.inset(by: effectiveInsets)
        var rect = super.textRect(forBounds: insetBounds, limitedToNumberOfLines: numberOfLines)
        rect.origin.x -= effectiveInsets.left
        rect.origin.y -= effectiveInsets.top
        rect.size.width += effectiveInsets.left + effectiveInsets.right
        rect.size.height += effectiveInsets.top + effectiveInsets.bottom
        return rect
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: effectiveInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + effectiveInsets.left + effectiveInsets.right,
            height: size.height + effectiveInsets.top + effectiveInsets.bottom
        )
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fitted = super.sizeThatFits(
            CGSize(
                width: size.width - effectiveInsets.left - effectiveInsets.right,
                height: size.height - effectiveInsets.top - effectiveInsets.bottom
            )
        )
        return CGSize(
            width: fitted.width + effectiveInsets.left + effectiveInsets.right,
            height: fitted.height + effectiveInsets.top + effectiveInsets.bottom
        )
    }

    private func bubblePath() -> UIBezierPath {
        let bodyHeight = max(0, bounds.height - tailSize.height)
        let bodyRect: CGRect
        let isTop = tailDirection == .topLeft || tailDirection == .topRight
        if isTop {
            bodyRect = CGRect(x: 0, y: tailSize.height, width: bounds.width, height: bodyHeight)
        } else {
            bodyRect = CGRect(x: 0, y: 0, width: bounds.width, height: bodyHeight)
        }

        let path = UIBezierPath(roundedRect: bodyRect, cornerRadius: cornerRadius)

        let clampedOffset = min(max(tailOffset, 0), max(0, bounds.width - tailSize.width))
        let tailX: CGFloat
        if tailDirection == .bottomRight || tailDirection == .topRight {
            tailX = max(0, bounds.width - clampedOffset - tailSize.width)
        } else {
            tailX = clampedOffset
        }

        if isTop {
            let tailBaseY = bodyRect.minY
            let tailTip = CGPoint(x: tailX + tailSize.width * 0.5, y: tailBaseY - tailSize.height)
            path.move(to: CGPoint(x: tailX, y: tailBaseY))
            path.addLine(to: tailTip)
            path.addLine(to: CGPoint(x: tailX + tailSize.width, y: tailBaseY))
        } else {
            let tailBaseY = bodyRect.maxY
            let tailTip = CGPoint(x: tailX + tailSize.width * 0.5, y: tailBaseY + tailSize.height)
            path.move(to: CGPoint(x: tailX, y: tailBaseY))
            path.addLine(to: tailTip)
            path.addLine(to: CGPoint(x: tailX + tailSize.width, y: tailBaseY))
        }
        path.close()

        return path
    }
}
