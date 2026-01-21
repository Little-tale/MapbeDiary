//
//  WrappedTagView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/22/26.
//

import UIKit

final class WrappedTagView: BaseView {
    
    private var tagLabels: [PaddingLabel] = []
    
    private var cachedContentSize: CGSize = .zero
    
    var tagSpacing: CGFloat = 8 {
        didSet { setNeedsLayout() }
    }
    
    var lineSpacing: CGFloat = 8 {
        didSet { setNeedsLayout() }
    }
    
    var contentInsets: UIEdgeInsets = .zero {
        didSet { setNeedsLayout() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = layoutTags(maxWidth: bounds.width, applyFrames: true)
        if cachedContentSize != size {
            cachedContentSize = size
            invalidateIntrinsicContentSize()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutTags(maxWidth: size.width, applyFrames: false)
    }
    
    override var intrinsicContentSize: CGSize {
        if bounds.width > 0 {
            return layoutTags(maxWidth: bounds.width, applyFrames: false)
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: cachedContentSize.height)
    }
    
    private func makeTagLabel(text: String) -> PaddingLabel {
        let label = PaddingLabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.backgroundColor = .md(.tagBlue).withAlphaComponent(0.4)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.insets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        return label
    }
    
    private func layoutTags(maxWidth: CGFloat, applyFrames: Bool) -> CGSize {
        let availableWidth = max(0, maxWidth - contentInsets.left - contentInsets.right)
        var x = contentInsets.left
        var y = contentInsets.top
        var rowHeight: CGFloat = 0
        
        for label in tagLabels {
            
            let size = label.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
            
            let isNotFirst = x > contentInsets.left
            let currentXWithLabelWidth = x + size.width
            let startXWithAvailableWidth = contentInsets.left + availableWidth
            
            if isNotFirst && (currentXWithLabelWidth > startXWithAvailableWidth) {
                x = contentInsets.left
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            
            if applyFrames {
                label.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            }
            
            x += size.width + tagSpacing
            rowHeight = max(rowHeight, size.height)
        }
        
        let height = y + rowHeight + contentInsets.bottom
        return CGSize(width: maxWidth, height: height)
    }
}

extension WrappedTagView {
    
    func setTags(_ tags: [String]) {
        tagLabels.forEach { $0.removeFromSuperview() }
        tagLabels = tags.map { makeTagLabel(text: $0) }
        tagLabels.forEach { addSubview($0) }
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
}
