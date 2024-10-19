//
//  CounterModel.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 09.01.2025.
//

import UIKit

class CounterModel {
    
    // MARK: - private properties
    private var count = 0
    private var timer: Timer?
    private weak var label: UILabel?
    
    // MARK: - initializers
    init(label: UILabel) {
        self.label = label
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - public methods
    func add() -> Self? {
        count += 1
        updateTimer()
        return self
    }
    
    func remove() -> Self? {
        count -= 1
        if count <= 0 {
            return nil
        } else {
            updateTimer()
            return self
        }
    }
    
    // MARK: - private methods
    private func updateTimer() {
        timerTick()
        timer?.invalidate()
        timer = nil
        
        timer = .scheduledTimer(
            withTimeInterval: 1 / Double(count > 0 ? count : 1),
            repeats: true,
            block: { [weak self] _ in
                self?.timerTick()
            })
    }
    
    private func timerTick() {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        updateLabel(text: dateFormatter.string(from: .init()))
    }
    
    private func updateLabel(text: String) {
        Task(priority: .high) { @MainActor in
            label?.text = "\(text) (\(count))"
        }
    }
}
