//
//  Reducer.swift
//  SpeechToText
//
//  Created by Константин Клинов on 16/10/25.
//

import Combine
import Foundation

typealias Reducer<State, Action> = (inout State, Action, AppEnvironment) -> AnyCancellable?

let appReducer: Reducer<AppState, AppAction> = { state, action, env in
    switch action {

    case .toggleRecording:
        state.isRecording.toggle()
        if state.isRecording {
            // start
            env.speech.startRecording()
        } else {
            env.speech.stopRecording()
        }
        return nil

    case let .recognitionPartial(text):
        state.partialRecognition = text
        return nil

    case let .recognitionFinal(text):
        state.partialRecognition = ""
        state.messages.append(Message(role: .user, text: text))
        state.isLoadingResponse = true

        // Capture the current messages array (not state itself)
        let currentMessages = state.messages

        // Kick off async LLM call
        let publisher = Future<Result<String, Error>, Never> { promise in
            Task {
                do {
                    let response = try await env.llm.send(messages: currentMessages)
                    promise(.success(.success(response)))
                } catch {
                    promise(.success(.failure(error)))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { result in
            env.mainQueue.async {
                NotificationCenter.default.post(name: .agentResponseNotification, object: result)
            }
        }

        return AnyCancellable { publisher.cancel() }

    case let .sendUserMessage(text):
        state.messages.append(Message(role: .user, text: text))
        return nil

    case let .agentResponse(result):
        state.isLoadingResponse = false
        switch result {
        case let .success(text):
            state.messages.append(Message(role: .assistant, text: text))
        case let .failure(err):
            state.messages.append(Message(role: .assistant, text: "Error: \(err.localizedDescription)"))
        }
        return nil

    case let .recognitionError(err):
        state.isRecording = false
        state.partialRecognition = ""
        state.messages.append(Message(role: .assistant, text: "Recognition error: \(err)"))
        return nil
    }
}
