//
//  CustomIndicator.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import UIKit

struct CustomIndicator {
    let backGroundView = UIView() // 뒷배경
    let activityIndicator = UIView()
    let view: UIView
    let navigationController: UINavigationController?
    let tabBarController: UITabBarController?
    let activityView = UIActivityIndicatorView()
    let loadingTextLabel = UILabel()
    
    var navigationBarHeight: CGFloat {
        return navigationController?.navigationBar.frame.height ?? 0
    }
    
    var tabBarHeight: CGFloat {
        return tabBarController?.tabBar.frame.height ?? 0
    }
    
    func showActivityIndicator(title: String){
        settingActivityIndicator()
        backGroundView.addSubview(activityIndicator)
        settingsettingActivityView()
        settingLoadingLabel(title)
        activityIndicator.addSubview(loadingTextLabel)
        activityIndicator.addSubview(activityView)
        settingBackgoround()
        activityView.startAnimating()
    }
    
    private func settingActivityIndicator(){
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = CGPoint(x: view.frame.size.width * 0.5, y: view.frame.size.height * 0.5)
        activityIndicator.layer.cornerRadius = 10
        activityIndicator.backgroundColor = .wheetSideBrown
    }
    
    private func settingsettingActivityView(){
        activityView.center = CGPoint(x: activityIndicator.frame.size.width * 0.5 , y: ( activityIndicator.frame.size.height - navigationBarHeight - tabBarHeight) * 0.5  )
        
        activityView.hidesWhenStopped = true
        activityView.style = .large
        activityView.color = .wheetPink
    }
    
    private func settingLoadingLabel(_ title: String){
        loadingTextLabel.text = title
        loadingTextLabel.textColor = .wheetDarkBrown
        loadingTextLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        loadingTextLabel.sizeToFit()
        loadingTextLabel.center = CGPoint(x: activityView.center.x, y: activityView.center.y + 40)
        
    }
    
    private func settingBackgoround(){
        backGroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.current?.bounds.width ?? 0, height: UIScreen.current?.bounds.height ?? 0)
        
        backGroundView.backgroundColor = .wheetDarkBrown.withAlphaComponent(0.4)
        
        view.addSubview(backGroundView)
    }
    
    func stopActivity(){
        activityIndicator.removeFromSuperview()
        activityView.stopAnimating()
        activityView.removeFromSuperview()
        backGroundView.removeFromSuperview()
    }
    
}
