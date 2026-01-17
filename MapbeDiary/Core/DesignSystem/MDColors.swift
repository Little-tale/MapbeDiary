//
//  MDColors.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/18/26.
//

import Foundation

enum MDColors {
    
    // MARK: - Base
    case background
    case surface
    case divider
    case shadow
    
    // MARK: - Text
    case textPrimary
    case textSecondary
    case textHint
    
    // MARK: - Brand / Action
    case primary
    case onPrimary
    
    // MARK: - Accent
    case accent
    case onAccent
    
    // MARK: - Memo Tag Colors
    case tagYellow
    case tagPink
    case tagBlue
    case tagGreen
    case tagPurple
    
    // MARK: - Dark Mode (Optional)
    case backgroundDark
    case surfaceDark
    case textPrimaryDark
    case textSecondaryDark
    case primaryDark
    
    // MARK: - Destructive (iOS Red tone)
    case destructive
    case onDestructive
    
    var hexValue: String {
        switch self {
            
            // Base
        case .background:        return "#F9FAFB"
        case .surface:           return "#FFFFFF"
        case .divider:           return "#E5E7EB"
        case .shadow:            return "#0000001A"
            
            // Text
        case .textPrimary:       return "#111827"
        case .textSecondary:     return "#6B7280"
        case .textHint:          return "#9CA3AF"
            
            // Brand / Action
        case .primary:           return "#0A84FF"
        case .onPrimary:         return "#FFFFFF"
            
            // Accent (iOS-like Green)
        case .accent:            return "#34C759"
        case .onAccent:          return "#FFFFFF"
            
            // Memo Tags
        case .tagYellow:         return "#FFF3B0"
        case .tagPink:           return "#FFD6E7"
        case .tagBlue:           return "#D6E8FF"
        case .tagGreen:          return "#D7FBE3"
        case .tagPurple:         return "#E9DDFF"
            
            // Dark Mode
        case .backgroundDark:    return "#0B0F17"
        case .surfaceDark:       return "#111827"
        case .textPrimaryDark:   return "#F9FAFB"
        case .textSecondaryDark: return "#CBD5E1"
        case .primaryDark:       return "#0A84FF"
            
            // Destructive (iOS-like Red)
        case .destructive:       return "#FF3B30"   // iOS systemRed 느낌
        case .onDestructive:     return "#FFFFFF"
        }
    }
}
