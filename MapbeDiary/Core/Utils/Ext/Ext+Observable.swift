//
//  Ext+Observable.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import RxSwift

extension Observable {
    
    typealias SendType = Send<Element>
    typealias OperationType = @Sendable (_ send: SendType) async throws -> Void
    
    static func run(
        priority: TaskPriority? = nil,
        operation: @escaping OperationType
    ) -> Observable<Element> {
        
        Observable.create { observer in
            let task = Task(priority: priority) {
                do {
                    try await operation(
                        Send { value in
                            observer.onNext(value)
                        }
                    )
                    observer.onCompleted()
                } catch is CancellationError {
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }

            return Disposables.create { task.cancel() }
        }
    }
}

@MainActor
struct Send<Element>: Sendable {
    
    typealias SendType = @MainActor @Sendable (Element) -> Void
    
    private let send: SendType

    init(_ send: @escaping SendType) {
        self.send = send
    }

    func callAsFunction(_ value: Element) {
        guard !Task.isCancelled else { return }
        send(value)
    }
}
