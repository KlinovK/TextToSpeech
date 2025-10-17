//
//  AppAction.swift
//  SpeechToText
//
//  Created by Константин Клинов on 16/10/25.
//

import Foundation

enum AppAction {
    case toggleRecording
    case recognitionPartial(String)
    case recognitionFinal(String)
    case recognitionError(String)
    case sendUserMessage(String)
    case agentResponse(Result<String, Error>)
}
