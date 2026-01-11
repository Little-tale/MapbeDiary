//
//  ScrollImageView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/22/24.
//

import UIKit
import SnapKit

final class ScrollImageView: BaseView {
    
    var photoImageView: [UIView] = [] {
        didSet{
            setUpViews()
        }
    }
    
    let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        return scrollView
    }()

    let pageController = UIPageControl()
    
    var curretnPageLitener: ((Int) -> Void)?
    
    override func register() {
        setUpUI()
        setUpViews()
        pageController.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            changePage(current: pageController.currentPage)
            curretnPageLitener?(pageController.currentPage)
        }), for: .valueChanged)
    }
    
    override func configureHierarchy() {
        addSubview(scrollView)
        addSubview(pageController)
        scrollView.delegate = self
    }
    
    private func setUpUI(){
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageController.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(scrollView).inset(20)
            make.height.equalTo(50)
        }
    }
    
    private func setUpViews(){
        photoImageView.forEach { [weak self] view  in
            guard let self else { return }
            scrollView.addSubview(view)
        }
    
        for (index, view) in photoImageView.enumerated() {
            view.snp.makeConstraints { make in
                make.verticalEdges.equalTo(scrollView)
                make.size.equalTo(scrollView)
                if index == 0 {
                    make.leading.equalTo(scrollView)
                }else {
                    make.leading.equalTo(photoImageView[index - 1].snp.trailing)
                }
                if index == photoImageView.count - 1 {
                    make.trailing.equalTo(scrollView)
                }
            }
        }
        pageController.numberOfPages = photoImageView.count
        
    }
}
// MARK: 페이지 컨튜롤 변화 감지후 스크롤뷰 반영
extension ScrollImageView {
    private func changePage(current: Int) {
        let moveTo = CGFloat(current) * scrollView.frame.width
        let movePoint = CGPoint(x: moveTo, y: 0)
        scrollView.setContentOffset(movePoint, animated: true)
    }
}

// MARK: 스크롤 뷰 변화 감지 후 페이지 컨트롤 반영
extension ScrollImageView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageBefore = scrollView.contentOffset.x / frame.width
        let round = round(pageBefore)
        // print(round)
        pageController.currentPage = Int(round)
        curretnPageLitener?(Int(round))
    }
}
