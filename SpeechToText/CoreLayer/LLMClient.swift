//
//  LLMClient.swift
//  SpeechToText
//
//  Created by Константин Клинов on 16/10/25.
//

import Foundation

protocol LLMClient {
    func send(messages: [Message]) async throws -> String
}

final class MockLLMClient: LLMClient {
    func send(messages: [Message]) async throws -> String {
        let lastUser = messages.last { $0.role == .user }?.text ?? "Hello"
        return "Echo: \(lastUser)\n\n(This is a local mock assistant. To use a real LLM, provide an OpenAI API key and implement OpenAILLMClient.)"
    }
}

final class OllamaClient: LLMClient {
    let baseURL: URL
    let model: String

    init(baseURL: URL = URL(string: "http://localhost:11434")!,
         model: String = "llama3") {
        self.baseURL = baseURL
        self.model = model
    }

    func send(messages: [Message]) async throws -> String {
        let chatMessages = messages.map { ["role": $0.role.rawValue, "content": $0.text] }
        let body: [String: Any] = [
            "model": model,
            "messages": chatMessages
        ]

        var req = URLRequest(url: baseURL.appendingPathComponent("api/chat"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let str = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "Ollama", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Ollama error: \(str)"])
        }

        // ✅ FIX: Ollama streams JSON objects line-by-line
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Ollama", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid UTF-8 data"])
        }

        var combinedText = ""
        for line in responseString.split(separator: "\n") {
            guard let jsonData = line.data(using: .utf8) else { continue }
            if let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let msg = json["message"] as? [String: Any],
               let content = msg["content"] as? String {
                combinedText += content
            }
        }

        return combinedText.isEmpty ? "(No response)" : combinedText
    }
}
