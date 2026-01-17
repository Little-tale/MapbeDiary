//
//  OnboardViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/22/24.
//

import UIKit
import RxSwift
import RxCocoa


final class OnboardViewController: ReactorBaseViewController<OnboardReactor,OnboardVCView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startImageSet()
        settingButton()
    }
    
    override func bind(reactor: OnboardReactor) {
        super.bind(reactor: reactor)
        
        reactor.state
            .map { $0.buttonAlpha }
            .skip(1) // Default State
            .distinctUntilChanged()
            .bind(with: self) { owner, alpha in
                owner.showButton(alpha: alpha)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.error }
            .distinctUntilChanged()
            .bind(with: self) { owner, error in
                owner.showAPIErrorAlert(repo: error)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.nextVC }
            .bind(with: self) { owner, service in
                let vc = MapViewController(
                    reactor: MapViewReactor(
                        sharedEvent: service,
                        locationManager: LocationManager()
                    )
                )
                owner.changeRootView(vc)
            }
            .disposed(by: disposeBag)
    }
   
    override func sendActions(reactor: OnboardReactor) {
        // startButton Tapped
        mainView.startButton.rx
            .tap
            .throttle(.seconds(1), latest: false ,scheduler: MainScheduler.instance)
            .map { OnboardReactor.Action.startButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // currentPageListener -> currentPageIdxChanged
        mainView.imageSliderView.currentPageListener = { [weak self] current in
            guard let self else { return }
            let imageViews =  mainView.imageSliderView.photoImageView
            
            reactor.action.onNext(.currentPageIdxChanged(
                index: current, imageCount: imageViews.count)
            )
        }

    }
}

extension OnboardViewController {
    
    private func startImageSet(){
        let images: [UIImage] = [
            UIImage.on1,
            UIImage.on2,
            UIImage.on3
        ]
        
        let imageViews = images.map { image in
            UIImageView(image: image)
        }
        
        mainView.imageSliderView.photoImageView = imageViews
    }
    
    private func settingButton(){
        mainView.startButton.alpha = 0.0
    }
    
    private func showButton(alpha: Double){
        let alpha: CGFloat = alpha
        
        UIView.animate(withDuration: 1.5) { [weak self] in
            guard let self else { return }
            mainView.startButton.alpha = alpha
        }
    }
}
