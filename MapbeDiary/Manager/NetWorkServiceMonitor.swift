//
//  NetWorkServiceMonitor.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/22/24.
//

import Network
/*
 NWPathMovitor
 Apple이 네트워크 프레임 워크
 네트워크 연결의 상태를 모니터링 할 수 있게 해주는 클래스
 네트워크 연결상태가 변경 될때마다 알림을 받을 수 있다.
 현재 연결 상태도 받을수 있다.
 */

final class NetWorkServiceMonitor {
    static let shared = NetWorkServiceMonitor()
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    // 회고
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown
    
    private init(){
        monitor = NWPathMonitor()
    }
    
    enum ConnectionType {
        case cellular
        case ethernet
        case unknown
        case wifi
    }
    
    public func startMonitor( ){
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = {
            [weak self] path in
            guard let self else { return }
            isConnected = path.status == .satisfied
            getConnectionType(path)
        }
    }
    /// NWPath 에서 path.status 열겨헝중
    /// .satisfied는 인터넷이 연결된 상태임을 뜻한다.
    /// usesInterfaceType 에선 셀룰러 와이파이 무선 연결 등이 더 존재한다.
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi){
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular){
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet){
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
    
    public func stopMonitoring(){
        monitor.cancel()
    }
}
