//
//  Item.swift
//  Hwatgim
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var reason: String
    var mood: String
    var detail: String

    init(timestamp: Date, reason: String = "", mood: String = "", detail: String = "") {
        self.timestamp = timestamp
        self.reason = reason
        self.mood = mood
        self.detail = detail
    }
}
