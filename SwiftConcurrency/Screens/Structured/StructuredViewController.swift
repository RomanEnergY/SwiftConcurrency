//
//  StructuredViewController.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 09.01.2025.
//

import UIKit
import SnapKit

final class StructuredViewController: BaseViewController {
    
    // MARK: - private properties
    private var timer: Timer?
    private let label: UILabel = {
        let label: UILabel = .init()
        label.font = .init(descriptor: .init(), size: 25)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "#loading..."
        return label
    }()
    private lazy var serialLoadButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle("serial", for: .normal)
        button.addTarget(self, action: #selector(onButtonTouchUpInside), for: .touchUpInside)
        return button
    }()
    private lazy var concarrensyLoadButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle("concarrensy", for: .normal)
        button.addTarget(self, action: #selector(onButtonTouchUpInside), for: .touchUpInside)
        return button
    }()
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    // MARK: - private methods
    private func startTimer() {
        let startDate: Date = .init()
        stopTimer()
        
        timer = .scheduledTimer(
            withTimeInterval: 0.001,
            repeats: true,
            block: { [weak self] _ in
                self?.timerTick(startDate: startDate)
            })
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timerTick(startDate: Date) {
        let time = Date().timeIntervalSince1970
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "mm:ss.SSS"
        updateLabel(text: dateFormatter.string(from: .init(timeIntervalSince1970: time - startDate.timeIntervalSince1970)))
    }
    
    private func updateLabel(text: String) {
        Task(priority: .high) { @MainActor in
            label.text = text
        }
    }
    
    @objc private func onButtonTouchUpInside(_ sender: UIButton) {
        startTimer()
        
        switch sender {
        case serialLoadButton:
            serialLoad()
        case concarrensyLoadButton:
            concarrensyLoad()
        default:
            break
        }
    }
}

// MARK: - config
private extension StructuredViewController {
    private func config() {
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        let stackView: UIStackView = .init()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .equalCentering
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        stackView.addArrangedSubview(serialLoadButton)
        stackView.addArrangedSubview(concarrensyLoadButton)
    }
}

// MARK: - calculated properties
private extension StructuredViewController {
    private func serialLoad() {
        Task {
            let firstText = await loadFirstText()
            let secondText = await loadSecondText()
            let thirdText = await loadThirdText()
            let fourthText = await loadFourthText()
            
            await updateLabel(array: firstText, secondText, thirdText, fourthText)
        }
    }
    
    private func concarrensyLoad() {
        Task {
            async let firstText = loadFirstText()
            async let secondText = loadSecondText()
            async let thirdText = loadThirdText()
            async let fourthText = loadFourthText()
            
            let result = await (first: firstText, second: secondText, third: thirdText, fourth: fourthText)
            await updateLabel(array: result.first, result.second, result.third, result.fourth)
        }
    }
    
    private func loadFirstText() async -> String {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return "first method"
    }
    
    private func loadSecondText() async -> String {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return "second method"
    }
    
    private func loadThirdText() async -> String {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return "third method"
    }
    
    private func loadFourthText() async -> String {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return "fourth method"
    }
    
    private func updateLabel(array: String...) async {
        stopTimer()
        Task(priority: .high) { @MainActor in
            label.text = [
                array.joined(separator: "\n"),
                label.text ?? ""
            ].joined(separator: "\n")
        }
    }
}
