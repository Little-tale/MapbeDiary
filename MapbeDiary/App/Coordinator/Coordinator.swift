import UIKit

@MainActor
protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController? { get }
    func start()
}

extension Coordinator {
    /// 다음 화면으로 이동
    func next(viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// 뒤로 이동
    func back(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func backTo(num: Int, animated: Bool = true) {
        guard let target = navigationController?.viewControllers[safe: num] else {
            print("nil target")
            return
        }
        navigationController?.popToViewController(target, animated: true)
    }
    
    /// 루트로 이동
    func rootPop(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }
    
    /// 모달로 화면을 표시
    func present(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController?.present(viewController, animated: animated, completion: completion)
    }
    
    /// 확대, 축소 애니메이션 Present
    func transitionPresent(
        viewController: UIViewController,
        target: UIView,
        completion: (() -> Void)? = nil
    ) {
        if #available(iOS 18.0, *) {
            viewController.preferredTransition = .zoom { [weak target] context in
                return target
            }
            navigationController?.present(viewController, animated: true)
            return
        }
        viewController.modalPresentationStyle = .fullScreen
        navigationController?.present(viewController, animated: false)
    }
    
    /// 현재 모달을 닫음
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController?.dismiss(animated: animated, completion: completion)
    }
    
    func backToParent(animated: Bool = true) {
        parentCoordinator?.removeChild(self)
        back(animated: animated)
    }
    
    func dismissSelf(animated: Bool = true, completion: (() -> Void)? = nil) {
        parentCoordinator?.removeChild(self)
        dismiss(animated: animated)
    }

    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

// MARK: Tel
extension Coordinator {
    func moveToTel(phoneNumber: String) {
        let phoneNumber = phoneNumber.compactMap { c in
            if c.isNumber {
                return String(c)
            }
            return nil
        }.joined(separator: "")
        
        if let url = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
