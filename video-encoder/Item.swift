//
//  Item.swift
//  video-encoder
//
//  Created by 肖鹏 on 2025/8/19.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
