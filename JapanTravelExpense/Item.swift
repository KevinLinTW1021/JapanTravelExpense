//
//  Item.swift
//  JapanTravelExpense
//
//  Created by KevinLin on 2025/1/7.
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
