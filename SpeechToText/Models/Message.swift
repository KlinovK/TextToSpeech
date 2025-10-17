//
//  Message.swift
//  SpeechToText
//
//  Created by Константин Клинов on 16/10/25.
//

import UIKit

struct Message: Identifiable, Codable, Equatable {
    let id: UUID
    let role: Role
    let text: String
    let date: Date

    init(id: UUID = UUID(), role: Role, text: String, date: Date = Date()) {
        self.id = id
        self.role = role
        self.text = text
        self.date = date
    }
}
