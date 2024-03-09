//
//  FloatingCustomLayout.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import FloatingPanel

final class FloatingCustomLayout: FloatingPanelLayout {
    var position: FloatingPanel.FloatingPanelPosition {
        return .bottom
    }
    
    var initialState: FloatingPanel.FloatingPanelState {
        return .half
    }

    var anchors: [FloatingPanel.FloatingPanelState : FloatingPanel.FloatingPanelLayoutAnchoring] {
        
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 260, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 100, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
    
}

