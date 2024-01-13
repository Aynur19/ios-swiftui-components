//
//  CountdownTimerViewModel.swift
//
//
//  Created by Aynur Nasybullin on 13.01.2024.
//

import SwiftUI

public enum CountdownTimerState: String {
    case idle
    case stoped
    case processing
    case finished
}

public final class CountdownTimerViewModel: ObservableObject {
    @Published public private(set) var progress: CGFloat = 1
    @Published public private(set) var counter: Int
    @Published public private(set) var time: Int
    @Published public private(set) var state: CountdownTimerState = .idle
    
    @Published public private(set) var isNotified = false
    private var timeLeftToNotify: Int
    
    private var timer: Timer?

    public init(_ milliseconds: Int, timeLeftToNotify: Int = .max) {
        self.time = milliseconds
        self.timeLeftToNotify = timeLeftToNotify
        self.counter = milliseconds
    }
    
    public func reset(_ milliseconds: Int? = .none, timeLeftToNotify: Int? = .none) {
        timer?.invalidate()
        if let timeOfMs = milliseconds {
            time = timeOfMs
        }
        
        if let timeLeftToNotifyOfMs = timeLeftToNotify {
            self.timeLeftToNotify = timeLeftToNotifyOfMs
        }
        
        isNotified = false
        
        counter = time
        progress = 1
        state = .idle
    }
    
    public func start() {
        if let isValid = timer?.isValid, isValid { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.counter > .zero {
                tick()
            } else {
                finish()
            }
        }
        
        state = .processing
    }
    
    public func stop() {
        timer?.invalidate()
        state = .stoped
    }
    
    private func tick() {
        counter -= 100
        
        if !isNotified, counter < timeLeftToNotify {
            isNotified = true
        }
        
        progress = CGFloat(counter) / CGFloat(time)
    }
    
    private func finish() {
        self.timer?.invalidate()
        self.state = .finished
    }
    
    deinit { timer?.invalidate() }
}

