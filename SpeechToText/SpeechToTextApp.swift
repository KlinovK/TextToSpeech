//
//  SpeechToTextApp.swift
//  SpeechToText
//
//  Created by Константин Клинов on 16/10/25.
//

import SwiftUI

@main
struct SpeechToTextApp: App {
    var body: some Scene {
        WindowGroup {
            let speech = SpeechRecogniser()

            let llm = OllamaClient(baseURL: URL(string: "http://192.168.1.23:11434")!, model: "phi3")
            let env = AppEnvironment(speech: speech, llm: llm, mainQueue: DispatchQueue.main)
            let store = Store(initial: AppState(), reducer: appReducer, environment: env)

            ContentView(store: store)
        }
    }
}
