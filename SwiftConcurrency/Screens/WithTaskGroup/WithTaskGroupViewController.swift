//
//  WithTaskGroupViewController.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 09.01.2025.
//

import UIKit
import SnapKit

final class WithTaskGroupViewController: BaseViewController {
    
    // MARK: - private properties
    private let withTaskGroupService: WithTaskGroupService = .init()
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
    
    // MARK: - initializers
    deinit {
        print("deinit: main:\(Self.description())")
        task?.cancel()
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        
        Task {
            await withTaskGroupService.setDelegate(self)
        }
        
        
    }
    
    // MARK: - private methods
    @objc private func onButtonTouchUpInside(_ sender: UIButton) {
        switch sender {
        case startButton:
            task = Task { [weak self] in
                do {
                    guard let result = try await self?.withTaskGroupService.load() else { return }
                    print(result)
                    
                } catch {
                    guard let self else {
                        print("not self: \(error)")
                        return
                    }
                    
                    if Task.isCancelled {
                        self.updateLabel(text: "Task cancelled")
                        
                    } else {
                        self.updateLabel(text: error.localizedDescription)
                    }
                }
            }
            
        case cancelButton:
            task?.cancel()
            
        default:
            break
        }
    }
    
    private func updateLabel(text: String) {
        Task(priority: .high) { @MainActor in
            centerLabel.text = text
        }
    }
}

// MARK: - config
private extension WithTaskGroupViewController {
    private func config() {
        view.addSubview(centerLabel)
        centerLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
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

// MARK: - WithTaskGroupServiceDelegate
extension WithTaskGroupViewController: WithTaskGroupServiceDelegate {
    func withTaskGroupServiceLogger(_ service: WithTaskGroupService, message: String) {
        updateLabel(text: message)
    }
}
