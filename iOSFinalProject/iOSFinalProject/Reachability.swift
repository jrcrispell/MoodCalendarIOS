//
//  Reachability.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 12/13/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import Foundation
import SystemConfiguration


// Code credit: http://www.brianjcoleman.com/tutorial-check-for-internet-connection-in-swift/
// Extra help: https://stackoverflow.com/questions/39046377/swift-3-unsafepointer0-no-longer-compile-in-xcode-8-beta-6

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1, { (zeroSockAddress) in
                SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, zeroSockAddress)
            })
            }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
        
    }
}
