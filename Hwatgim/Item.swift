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
    var intensity: Int = 3
    var customReason: String = ""
    var customMood: String = ""

    init(timestamp: Date, reason: String = "", mood: String = "", detail: String = "", intensity: Int = 3, customReason: String = "", customMood: String = "") {
        self.timestamp = timestamp
        self.reason = reason
        self.mood = mood
        self.detail = detail
        self.intensity = intensity
        self.customReason = customReason
        self.customMood = customMood
    }
}
