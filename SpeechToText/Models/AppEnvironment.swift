//
//  AppEnvironment.swift
//  SpeechToText
//
//  Created by Константин Клинов on 16/10/25.
//

import Foundation

struct AppEnvironment {
    let speech: SpeechRecogniser
    let llm: LLMClient
    let mainQueue: DispatchQueue
}
