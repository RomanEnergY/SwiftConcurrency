//
//  GSDViewController.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 06.02.2025.
//

import UIKit
import SnapKit

final class GSDViewController: BaseViewController {
    
    // MARK: - private properties
    private var isCancelled: Bool = false
    private let countInteration: Int = 10_000
    private var threadNumbers: Set<Int> = []
    private var threadUids: Set<String> = []
    private let synchronizationQueue: DispatchQueue = .init(label: "synchronization")
    private let concurrentQueue: DispatchQueue = .init(label: "concurrent", attributes: .concurrent)
    private let label: UILabel = {
        let label: UILabel = .init()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    private lazy var stackView: UIStackView = {
        let stackView: UIStackView = .init(arrangedSubviews: [sirealButton, activityIndicatorView, concurrentButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    private lazy var sirealButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle("sirealQueue", for: .normal)
        button.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        return button
    }()
    
    private lazy var concurrentButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle("concurrentQueue", for: .normal)
        button.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        return button
    }()
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView: UIActivityIndicatorView = .init(style: .large)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = .blue
        return activityIndicatorView
    }()
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    deinit {
        isCancelled = true
    }
}

// MARK: - calculated properties
private extension GSDViewController {
    func config() {
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
    }
    
    @objc func buttonTouchUpInside(_ sender: UIButton) {
        let date: Date = .init()
        let workItem: DispatchWorkItem = .init {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                let texts: [String] = [
                    "threads count: \(self.threadNumbers.count)",
                    "thread uids: \(self.threadUids.count)",
                    "date: \(Date().timeIntervalSince(date))",
                ]
                
                self.label.text = texts.joined(separator: "\n")
                self.threadNumbers.removeAll()
                self.threadUids.removeAll()
                self.finishTestMethod()
            }
        }
        
        switch sender {
        case sirealButton:
            startTestMethod()
            sirealTestMethod(workItem: workItem)
            
        case concurrentButton:
            startTestMethod()
            concurrentTestMethod(workItem: workItem)
            
        default:
            break
        }
    }
    
    private func startTestMethod() {
        label.textColor = .gray
        stackView.arrangedSubviews.forEach {
            switch $0 {
                case let activityIndicatorView as UIActivityIndicatorView:
                activityIndicatorView.startAnimating()
                
            default:
                $0.isHidden = true
            }
        }
    }
    
    private func finishTestMethod() {
        label.textColor = .black
        stackView.arrangedSubviews.forEach {
            switch $0 {
                case let activityIndicatorView as UIActivityIndicatorView:
                activityIndicatorView.stopAnimating()
                
            default:
                $0.isHidden = false
            }
        }
        
    }
}

// MARK: - calculated properties
private extension GSDViewController {
    func sirealTestMethod(workItem: DispatchWorkItem) {
        DispatchQueue.global().async { [weak self, countInteration] in
            let group: DispatchGroup = .init()
            for i in 0 ..< countInteration {
                group.enter()
                let aueue: DispatchQueue = .init(label: "sireal")
                aueue.async { [weak self] in
                    self?.testMethod(index: i)
                    group.leave()
                }
            }
            
            group.notify(
                queue: .global(),
                work: workItem)
        }
    }
    
    func concurrentTestMethod(workItem: DispatchWorkItem) {
        DispatchQueue.global().async { [weak self, countInteration] in
            let group: DispatchGroup = .init()
            for i in 0 ..< countInteration {
                group.enter()
                self?.concurrentQueue.async { [weak self] in
                    self?.testMethod(index: i)
                    group.leave()
                }
            }
            
            group.notify(
                queue: .global(),
                work: workItem)
        }
    }
    
    private func testMethod(index: Int) {
        if !isCancelled {
            Thread.sleep(forTimeInterval: 0.01)
            let threadCurrent = Thread.current
            if let number = threadCurrent.number {
                synchronize { [weak self] in
                    self?.threadNumbers.insert(number)
                }
            }
            
            if let uid = threadCurrent.nSThreadUid {
                synchronize { [weak self] in
                    self?.threadUids.insert(uid)
                }
            }
            
            if !isCancelled {
                print("index(\(index)): \(threadCurrent)")
            }
        }
    }
    
    private func synchronize(completion: @escaping () -> Void) {
        synchronizationQueue.sync {
            completion()
        }
    }
}

extension Thread {
    var number: Int? {
        let threadCurrent = "\(self)"
        return threadCurrent.threadNumber
    }
    
    var nSThreadUid: String? {
        let threadCurrent = "\(self)"
        return threadCurrent.nSThreadUid
    }
}

private extension String {
    var threadNumber: Int? {
        if let numberStr = find(pattern: "number = (?<number>\\d{1,}),", key: "number") {
            return Int(numberStr)
        } else {
            return nil
        }
    }
    
    var nSThreadUid: String? {
        find(pattern: "<NSThread: (?<uid>\\S{1,})>", key: "uid")
    }
    
    func find(pattern: String, key: String) -> String? {
        let range = NSRange(startIndex ..< endIndex, in: self)
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: self, range: range),
           let key = match.getRange(key: key, in: self) {
            return key
        } else {
            return nil
        }
    }
}

private extension NSTextCheckingResult {
    func getRange(key: String, in text: String) -> String? {
        if let range = Range(range(withName: key), in: text) {
            return String(text[range])
        } else {
            return nil
        }
    }
}
