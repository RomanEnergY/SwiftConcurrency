//
//  MainViewController.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 19.10.2024.
//

import UIKit
import SnapKit

final class MainViewController: UIViewController {
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Swift Concurrency"
        view.backgroundColor = .white
        config()
    }
}

// MARK: - config
private extension MainViewController {
    private func config() {
        let stackView: UIStackView = .init()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .equalCentering
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.trailing.equalToSuperview()
        }
        
        stackView.addArrangedSubview(configCounterButton())
        stackView.addArrangedSubview(configStructuredButton())
        stackView.addArrangedSubview(configCancelTaskButton())
        stackView.addArrangedSubview(configWithTaskGroupButton())
    }
}

// MARK: - CounterButton
private extension MainViewController {
    private func configCounterButton() -> UIButton {
        let button: UIButton = .init(type: .system)
        button.setTitle("CounterViewController", for: .normal)
        button.addTarget(self, action: #selector(onCounterButtonTouchUpInside), for: .touchUpInside)
        return button
    }
    
    @objc private func onCounterButtonTouchUpInside(_ sender: UIButton) {
        let vc: CounterViewController = .init()
        present(vc, animated: true)
    }
}

// MARK: - StructuredButton
private extension MainViewController {
    private func configStructuredButton() -> UIButton {
        let button: UIButton = .init(type: .system)
        button.setTitle("StructuredViewController", for: .normal)
        button.addTarget(self, action: #selector(onStructuredButtonTouchUpInside), for: .touchUpInside)
        return button
    }
    
    @objc private func onStructuredButtonTouchUpInside(_ sender: UIButton) {
        let vc: StructuredViewController = .init()
        present(vc, animated: true)
    }
}

// MARK: - CancelTaskButton
private extension MainViewController {
    private func configCancelTaskButton() -> UIButton {
        let button: UIButton = .init(type: .system)
        button.setTitle("CancelTaskViewController", for: .normal)
        button.addTarget(self, action: #selector(onCancelTaskButtonTouchUpInside), for: .touchUpInside)
        return button
    }
    
    @objc private func onCancelTaskButtonTouchUpInside(_ sender: UIButton) {
        let vc: CancelTaskViewController = .init()
        present(vc, animated: true)
    }
}

// MARK: - WithTaskGroupButton
private extension MainViewController {
    private func configWithTaskGroupButton() -> UIButton {
        let button: UIButton = .init(type: .system)
        button.setTitle("WithTaskGroupViewController", for: .normal)
        button.addTarget(self, action: #selector(onWithTaskGroupButtonTouchUpInside), for: .touchUpInside)
        return button
    }
    
    @objc private func onWithTaskGroupButtonTouchUpInside(_ sender: UIButton) {
        let vc: WithTaskGroupViewController = .init()
        present(vc, animated: true)
    }
}
