//
//  AsyncThrowingStreamViewController.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 09.01.2025.
//

import UIKit
import SnapKit

final class AsyncThrowingStreamViewController: BaseViewController {
    
    // MARK: - private properties
    private var asyncThrowingStreamTest: AsyncThrowingStreamTest?
    private let centerLabel: UILabel = {
        let label: UILabel = .init()
        label.font = .init(descriptor: .init(), size: 25)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "#label"
        return label
    }()
    private lazy var startButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle("start Task", for: .normal)
        button.addTarget(self, action: #selector(onButtonTouchUpInside), for: .touchUpInside)
        return button
    }()
    private lazy var cancelButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle("calcel Task", for: .normal)
        button.addTarget(self, action: #selector(onButtonTouchUpInside), for: .touchUpInside)
        return button
    }()
    private var task: Task<(), Never>?
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    // MARK: - private methods
    @objc private func onButtonTouchUpInside(_ sender: UIButton) {
        switch sender {
        case startButton:
            startButtonPressed()
        case cancelButton:
            asyncThrowingStreamTest?.cancel()
        default:
            break
        }
    }
    
    private func startButtonPressed() {
        Task {
            do {
                if let asyncThrowingStreamTest {
                    asyncThrowingStreamTest.next()
                    
                } else {
                    let asyncThrowingStreamTest: AsyncThrowingStreamTest = .init()
                    for try await result in asyncThrowingStreamTest.download(urlStr: "Test") {
                        switch result {
                        case .downloading(let value):
                            centerLabel.text = "downloading: \(value)"
                            
                        case .completed(let text):
                            centerLabel.text = "completed: \(text)"
                        }
                    }
                    
                    self.asyncThrowingStreamTest = asyncThrowingStreamTest
                }
            } catch {
                centerLabel.text = "\(error)"
            }
        }
    }
}

// MARK: - config
private extension AsyncThrowingStreamViewController {
    private func config() {
        view.addSubview(centerLabel)
        centerLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        let stackView: UIStackView = .init()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .equalCentering
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(centerLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        stackView.addArrangedSubview(startButton)
        stackView.addArrangedSubview(cancelButton)
    }
}
