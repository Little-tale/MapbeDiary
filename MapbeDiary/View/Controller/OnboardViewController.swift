//
//  OnboardViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/22/24.
//

import UIKit
 //MARK: 회고 isHidden Vs Alpha
class OnboardViewController: BaseHomeViewController<OnboardBaseView> {
    
    let repository = RealmRepository()
    
    var disPatchItem: DispatchWorkItem?
    var animated = false
    
    let images: [UIImage] = [
        UIImage.on1,
        UIImage.on2,
        UIImage.on3
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startImageSet()
        settingButton()
        trackingScroll()
    }
    
    private func startImageSet(){
        let imageViews = images.map { image in
            UIImageView(image: image)
        }
        homeView.imageSliderView.photoImageView = imageViews
    }
    
    
    private func settingButton(){
        homeView.startButton.alpha = 0.0
        homeView.startButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            startMapView()
        }), for: .touchUpInside)
        
        
    }
    private func showButton(){
        if !animated {
            animated = true
            UIView.animate(withDuration: 1.5) {
                [weak self] in
                guard let self else { return }
                homeView.startButton.alpha = 1
            }
        }
    }
    
    private func trackingScroll(){
        homeView.imageSliderView.curretnPageLitener = { [weak self]
            currentPage in
            guard let self else { return }
            if (currentPage + 1) == images.count {
                showButton()
            }
        }
    }
    
    private func startMapView(){
        do {
            try repository.makeFolder(folderName: "추억의 공간")
            let folder = repository.findAllFolderArray().first
            SingleToneDataViewModel.shared.shardFolderOb.value = folder
            let vc = MapViewController()
            changeRootView(vc)
        } catch {
            showAPIErrorAlert(repo: .canMakeFolder)
        }
    }
}

extension OnboardViewController {
    
    func changeRootView(_ vc: UIViewController){
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let windes = windowScene.windows.first {
                UIView.transition(with: windes, duration: 0.6) {
                    windes.rootViewController = vc
                }
                windes.makeKeyAndVisible()
            }
        }
    }
}
