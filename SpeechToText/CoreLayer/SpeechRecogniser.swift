//
//  SpeechRecogniser.swift
//  SpeechToText
//
//  Created by Константин Клинов on 16/10/25.
//

import Foundation
import Speech
import AVFoundation

final class SpeechRecogniser {
    private let recognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    // Callbacks
    var onPartial: ((String) -> Void)?
    var onFinal: ((String) -> Void)?
    var onError: ((String) -> Void)?

    init() {
        SFSpeechRecognizer.requestAuthorization { status in
            // nothing we can do here synchronously; app should react when user attempts
        }
        AVAudioSession.sharedInstance() // ensure availability
    }

    func startRecording() {
        Task {
            do {
                try await configureAudioSessionAndStart()
            } catch {
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }

    func stopRecording() {
        audioEngine.stop()
        request?.endAudio()
        task?.finish()
        task = nil
    }

    private func configureAudioSessionAndStart() async throws {
        let status = SFSpeechRecognizer.authorizationStatus()
        guard status == .authorized else {
            throw NSError(domain: "Speech", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition not authorized. Please enable in Settings."])
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else { throw NSError(domain: "Speech", code: 2, userInfo: nil) }
        request.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            if let result = result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    if result.isFinal {
                        self?.onFinal?(text)
                    } else {
                        self?.onPartial?(text)
                    }
                }
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
}
