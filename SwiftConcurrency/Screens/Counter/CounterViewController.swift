//
//  CounterViewController.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 09.01.2025.
//

import UIKit
import SnapKit

final class CounterViewController: BaseViewController {
    
    // MARK: - private properties
    private var counterModel: CounterModel?
    private let centerLabel: UILabel = {
        let label: UILabel = .init()
        label.font = .init(descriptor: .init(), size: 25)
        label.text = "#label"
        return label
    }()
    private lazy var addButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle("add", for: .normal)
        button.addTarget(self, action: #selector(onButtonTouchUpInside), for: .touchUpInside)
        return button
    }()
    private lazy var removeButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle("remove", for: .normal)
        button.addTarget(self, action: #selector(onButtonTouchUpInside), for: .touchUpInside)
        return button
    }()
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        config()
    }
    
    // MARK: - private methods
    @objc private func onButtonTouchUpInside(_ sender: UIButton) {
        switch sender {
        case addButton:
            addPressed()
        case removeButton:
            removePressed()
        default:
            break
        }
    }
}

// MARK: - config
private extension CounterViewController {
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
        
        stackView.addArrangedSubview(addButton)
        stackView.addArrangedSubview(removeButton)
    }
}

// MARK: - add
private extension CounterViewController {
    private func addPressed() {
        counterModel = counterModel ?? .init(label: centerLabel)
        counterModel = counterModel?.add()
    }
    
    private func removePressed() {
        counterModel = counterModel?.remove()
        if counterModel == nil {
            Task(priority: .high) { @MainActor in
                centerLabel.text = "#label"
            }
        }
    }
}
