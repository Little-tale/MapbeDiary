//
//  LoadingWindow.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/13/26.
//

import UIKit

@MainActor
final class LoadingWindow {
    
    static let shared = LoadingWindow()
    
    private var window: UIWindow?
    
    private let loadingViewController = LoadingViewController()
    
    private init() {}
}

// MARK: API
extension LoadingWindow {
    
    func show(title: String? = nil, in scene: UIWindowScene? = nil) {
        guard let windowScene = scene ?? resolveWindowScene() else { return }
        
        if window?.windowScene !== windowScene {
            window = UIWindow(windowScene: windowScene)
            window?.rootViewController = loadingViewController
            window?.backgroundColor = .clear
            window?.windowLevel = .alert + 5
        }
        
        if let title {
            loadingViewController.homeView.setTitle(title)
        }
        
        loadingViewController.startLoading()
        window?.isHidden = false
        window?.makeKeyAndVisible()
    }
    
    func hide() {
        loadingViewController.stopLoading()
        window?.isHidden = true
        window = nil
    }
}

// MARK: Helper
extension LoadingWindow {
    
    private func resolveWindowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }
}
