//
//  ContentView.swift
//  SpeechToText
//
//  Created by Константин Клинов on 16/10/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    @State private var scrollProxy: ScrollViewProxy?

    init(store: Store<AppState, AppAction>) {
        self.store = store
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .blue.opacity(0.5), .purple.opacity(0.6)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .overlay(
                    Circle()
                        .fill(LinearGradient(colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                             startPoint: .top, endPoint: .bottom))
                        .blur(radius: 120)
                        .offset(x: 200, y: -250)
                        .blendMode(.screen)
                )

            VStack(spacing: 0) {
                // MARK: - Record Button
                VStack(spacing: 8) {
                    Button(action: {
                        store.send(.toggleRecording)
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.1)]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: .blue.opacity(0.5), radius: 20, x: 0, y: 5)

                            Circle()
                                .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                                .frame(width: 100, height: 100)

                            Image(systemName: store.state.isRecording ? "stop.fill" : "waveform")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(store.state.isRecording ? 1.2 : 1.0)
                                .shadow(color: store.state.isRecording ? .red : .cyan, radius: 10)
                                .animation(.easeInOut(duration: 0.3), value: store.state.isRecording)
                        }
                    }

                    Text(store.state.isRecording ? "Listening..." : "Tap to Speak")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 20)

                // Partial Recognition
                if !store.state.partialRecognition.isEmpty {
                    Text(store.state.partialRecognition)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .padding(.horizontal)
                        .transition(.opacity)
                }

                Divider().opacity(0.3).padding(.vertical, 10)

                // MARK: - Chat Section
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(store.state.messages) { msg in
                                MessageRow(msg: msg)
                                    .id(msg.id)
                            }

                            if store.state.isLoadingResponse {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .tint(.cyan)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .onAppear { scrollProxy = proxy }
                    }
                    .onChange(of: store.state.messages.count) { _ in
                        if let last = store.state.messages.last {
                            withAnimation(.easeOut(duration: 0.4)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: .agentResponseNotification, object: nil, queue: .main) { note in
                if let result = note.object as? Result<String, Error> {
                    store.send(.agentResponse(result))
                }
            }

            store.environment.speech.onPartial = { text in
                store.send(.recognitionPartial(text))
            }
            store.environment.speech.onFinal = { text in
                store.send(.recognitionFinal(text))
            }
            store.environment.speech.onError = { err in
                store.send(.recognitionError(err))
            }
        }
    }
}

struct MessageRow: View {
    let msg: Message

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if msg.role == .assistant { avatar(role: .assistant) }

            VStack(alignment: msg.role == .user ? .trailing : .leading) {
                Text(msg.text)
                    .font(.system(size: 16, weight: .medium))
                    .padding(14)
                    .background(bubbleGradient)
                    .cornerRadius(14)
                    .shadow(color: msg.role == .user ? .blue.opacity(0.4) : .purple.opacity(0.4), radius: 8, x: 0, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(msg.role == .user ? Color.blue.opacity(0.4) : Color.purple.opacity(0.4), lineWidth: 1)
                    )
                    .foregroundColor(.white)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: msg.role == .user ? .trailing : .leading)
                    .transition(.move(edge: msg.role == .user ? .trailing : .leading))
                    .animation(.easeOut(duration: 0.4), value: msg.text)

                Text(shortDate(msg.date))
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.8))
            }

            if msg.role == .user { avatar(role: .user) }
        }
        .frame(maxWidth: .infinity, alignment: msg.role == .user ? .trailing : .leading)
        .padding(msg.role == .user ? .leading : .trailing, 40)
    }

    func avatar(role: Role) -> some View {
        ZStack {
            Circle()
                .fill(role == .user ? Color.blue.opacity(0.4) : Color.purple.opacity(0.4))
                .frame(width: 40, height: 40)
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                .shadow(color: .white.opacity(0.2), radius: 5)
            Image(systemName: role == .user ? "person.crop.circle.fill" : "brain.head.profile")
                .font(.system(size: 20))
                .foregroundColor(.white)
        }
    }

    var bubbleGradient: LinearGradient {
        msg.role == .user ?
            LinearGradient(colors: [.blue.opacity(0.7), .cyan.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) :
            LinearGradient(colors: [.purple.opacity(0.7), .pink.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    func shortDate(_ d: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: d)
    }
}
