//
//  After.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/13/26.
//

import Foundation

protocol After {}

extension After where Self: AnyObject {
    
  @inlinable
  func after(_ block: (Self) throws -> Void) rethrows -> Self {
    try block(self)
    return self
  }
    
}

extension NSObject: After {}
