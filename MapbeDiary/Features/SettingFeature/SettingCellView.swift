//
//  SettingCellView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/23/26.
//

import SwiftUI

struct SettingCellView: View {
    
    private let model: SettingModel
    
    init(model: SettingModel) {
        self.model = model
    }
    
    var body: some View {
        contentView
    }
}

extension SettingCellView {
    private var contentView: some View {
        HStack(spacing: 16) {
            makeImage(action: model.actionType)
                .padding(.all, 8)
                .background(
                    (model.actionType != .initialize ?
                    Color(UIColor.md(.tagGreen)) : Color(UIColor.md(.tagPink)))
                    .opacity(0.6)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(model.title)
                .font(.subheadline)
            
            Spacer()
            
            if let subTitle = model.detail {
                Text(subTitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
    
    @ViewBuilder
    private func makeImage(action: SettingActionType) -> some View {
        switch action {
        case .appVersion:
            Image(systemName: "info.bubble.fill")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color(UIColor.md(.greenPrimary)))
                .frame(width: 20, height: 20)
                
        case .termsAndConditions:
            Image(systemName: "doc.append.fill")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color(UIColor.md(.greenPrimary)))
                .frame(width: 20, height: 20)
            
        case .customerSupport:
            Image(systemName: "headphones.circle.fill")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color(UIColor.md(.greenPrimary)))
                .frame(width: 20, height: 20)
            
        case .initialize:
            Image(systemName: "arrow.clockwise")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color(UIColor.md(.pinkPrimary)))
                .frame(width: 20, height: 20)
        }
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    SettingViewController(reactor: SettingViewReactor())
}
#endif
