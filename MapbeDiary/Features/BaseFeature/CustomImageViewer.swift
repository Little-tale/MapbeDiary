//
//  CustomImageViewer.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/15/24.
//

import UIKit
import SnapKit

final class CustomImageViewer: UIViewController, UIScrollViewDelegate {
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    let backButton = UIButton()
    // MARK: 회고 -> 내일 회고로
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.backgroundColor = .black
        configureLayout()
        
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        settingScollerView()
        backButtonSetting()
        imageView.frame = scrollView.bounds
        
    }
    
    private func settingScollerView(){
        scrollView.delegate = self
        // 최대 최소 확대 비율 설정
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 0.8
        
        // 확대 - 축소 바운드 효과 활성화
        scrollView.bouncesZoom = true
        // 수평 - 수직 스크롤 인디케이터를 숨기기
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
    }
    
    private func backButtonSetting() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName:"chevron.backward")
        config.baseForegroundColor = .white
        
        backButton.configuration = config
        
        backButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            dismiss(animated: true)
        }), for: .touchUpInside)
    }
    
    func configureLayout(){
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.size.equalTo(40)
        }
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    
    }
    
    // 스크롤 뷰에서 확대/ 축소 뷰를 지정
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func loadImage(data: Data) {
        DispatchQueue.global().async { [weak self] in
            guard self != nil else { return }
            DispatchQueue.main.async {
                [weak self] in
                guard let self else { return }
                imageView.image = UIImage(data: data)
                activityIndicator.stopAnimating()
                print("불러옴")
                activityIndicator.isHidden = true
            }
        }
    }
    
}
