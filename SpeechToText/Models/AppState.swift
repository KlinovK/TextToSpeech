//
//  AppState.swift
//  SpeechToText
//
//  Created by Константин Клинов on 16/10/25.
//

import Foundation

struct AppState {
    var messages: [Message] = []
    var isRecording: Bool = false
    var partialRecognition: String = ""
    var isLoadingResponse: Bool = false
}
