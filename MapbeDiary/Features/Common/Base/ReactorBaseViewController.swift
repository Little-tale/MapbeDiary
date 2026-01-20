//
//  ReactorBaseViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/11/26.
//

import UIKit
import ReactorKit
import RxSwift

class ReactorBaseViewController<R: Reactor, V: VCBaseView>: UIViewController, ReactorKit.View {
    
    typealias Reactor = R
    
    // MARK: property
    
    let mainView: V
    var disposeBag = DisposeBag()
    weak var coordinator: Coordinator?
    
    
    // MARK: initial
    
    init(
        reactor: R,
        coordinator: Coordinator? = nil
    ) {
        self.mainView = V()
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
        setUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        register()
    }
    
    /// required Call "super.bind(reactor: reactor)"
    func bind(reactor: R) {
        sendActions(reactor: reactor)
    }
    
    /// View -> Reactor OR View Actions
    func sendActions(reactor: R) {}
    
    /// Delegate Register
    func register() {}
    
    /// another UI Setting If you Need Use
    func setUI() {}
    
    deinit {
        print("deinit:", String(describing: type(of: self)))
    }
}
