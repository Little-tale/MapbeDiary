//
//  Ext+Reactive.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

extension Reactive where Base: UIViewController {
    
    var viewDidLoad: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
    
    var viewIsAppearing: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewIsAppearing)).map { _ in }
        return ControlEvent(events: source)
    }

    var viewWillAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    var viewDidAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    var viewWillDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    var viewDidDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
}


extension Reactive where Base: RxGestureView {
    
    public func tapGestureOnTop() -> TapControlEvent {
        return self.tapGesture { gesture, delegate in
            delegate.simultaneousRecognitionPolicy = .never
        }
    }
}
