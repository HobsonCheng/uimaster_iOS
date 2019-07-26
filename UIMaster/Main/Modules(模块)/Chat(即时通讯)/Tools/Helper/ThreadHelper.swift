//
//  ThreadHelper.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

func dispatch_async_safely_to_main_queue(_ block: @escaping () -> Void) {
    dispatch_async_safely_to_queue(DispatchQueue.main, block)
}

// This methd will dispatch the `block` to a specified `queue`.
// If the `queue` is the main queue, and current thread is main thread, the block
// will be invoked immediately instead of being dispatched.
func dispatch_async_safely_to_queue(_ queue: DispatchQueue, _ block: @escaping () -> Void) {
    if queue === DispatchQueue.main && Thread.isMainThread {
        block()
    } else {
        queue.async {
            block()
        }
    }
}
