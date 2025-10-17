//
//  Store.swift
//  SpeechToText
//
//  Created by Константин Клинов on 16/10/25.
//

import Foundation
import Combine

final class Store<State, Action>: ObservableObject {
    @Published private(set) var state: State
    private let reducer: Reducer<State, Action>
    public let environment: AppEnvironment
    private var cancellables: Set<AnyCancellable> = []

    init(initial: State, reducer: @escaping Reducer<State, Action>, environment: AppEnvironment) {
        self.state = initial
        self.reducer = reducer
        self.environment = environment
    }

    func send(_ action: Action) {
        if let c = reducer(&state, action, environment) {
            cancellables.insert(c)
        }
    }
}
