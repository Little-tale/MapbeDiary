//
//  LoadingViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/13/26.
//

import Foundation

final class LoadingViewController: BaseHomeViewController<LoadingView> {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    func startLoading() {
        homeView.startAnimating()
    }
    
    func stopLoading() {
        homeView.stopAnimating()
    }
}
