//
//  MainViewController.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 19.10.2024.
//

import UIKit
import SnapKit

final class MainViewController: UIViewController {
    
    // MARK: - private properties
    private let buttons: [Button<UIViewController>] = [
        .init(type: GSDViewController.self),
        .init(type: CounterViewController.self),
        .init(type: StructuredViewController.self),
        .init(type: CancelTaskViewController.self),
        .init(type: WithTaskGroupViewController.self),
        .init(type: AsyncThrowingStreamViewController.self),
        .init(type: AlgoritmViewController.self),
        .init(type: BubbleSortingViewController.self)
    ]
    
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
        
        buttons.forEach {
            stackView.addArrangedSubview($0.create())
            $0.onTouchUpInside = { [weak self] vc in
                self?.present(vc, animated: true)
            }
        }
    }
}

private extension MainViewController {
    final class Button<T: UIViewController> {
        private let type: T.Type
        var onTouchUpInside: ((_ vc: UIViewController) -> Void)?
        
        // MARK: - initializers
        init(type: T.Type) {
            self.type = type
        }
        
        // MARK: - public methods
        func create() -> UIButton {
            let button: UIButton = .init(type: .system)
            let title: Substring = type.description().split(separator: ".").last ?? ""
            button.setTitle(.init(title), for: .normal)
            button.addTarget(self, action: #selector(_onTouchUpInside), for: .touchUpInside)
            return button
        }
        
        // MARK: - private methods
        @objc private func _onTouchUpInside(_ sender: UIButton) {
            onTouchUpInside?(type.init())
        }
    }
}
