//
//  CancelTaskViewController.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 09.01.2025.
//

import UIKit
import SnapKit

final class CancelTaskViewController: BaseViewController {
    
    // MARK: - private properties
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
    final class StartModel {
        var image: String?
        var title: String?
    }
    
    @objc private func onButtonTouchUpInside(_ sender: UIButton) {
        switch sender {
        case startButton:
            task = Task {
                async let firstTask = firstTask()
                async let secondTask = secondTask()
                let _ = await (firstTask, secondTask)
            }
            
        case cancelButton:
            task?.cancel()
            
        default:
            break
        }
    }
    
    private func firstTask() async {
        let finish: Int = 5
        for i in 0 ..< finish {
            updateLabel(text: "(1) Task running\n\(i)/\(finish)")
            
            if Task.isCancelled {
                updateLabel(text: "(1) Task cancelled\n\(i)/\(finish)")
                return
            }
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            if i == finish - 1 {
                updateLabel(text: "(1) Task finished")
            }
        }
    }
    
    private func secondTask() async {
        let finish: Int = 5
        for i in 0 ..< finish {
            updateLabel(text: "(2) Task running\n\(i)/\(finish)")
            
            if Task.isCancelled {
                updateLabel(text: "(2) Task cancelled\n\(i)/\(finish)")
                return
            }
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            if i == finish - 1 {
                updateLabel(text: "(2) Task finished")
            }
        }
    }
    
    private func updateLabel(text: String) {
        Task(priority: .high) { @MainActor in
            centerLabel.text = text
        }
    }
}

// MARK: - config
private extension CancelTaskViewController {
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
