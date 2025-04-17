//
//  GSDViewController.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 06.02.2025.
//

import UIKit
import SwiftUI
import SnapKit

final class GSDViewController: BaseViewController {
    
    // MARK: - private properties
    private var isCancelled: Bool = false
    private let countInteration: Int = 10_000
    private var datas: Set<GSDThreadData> = []
    private let synchronizationQueue: DispatchQueue = .init(label: "synchronization")
    private let concurrentQueue: DispatchQueue = .init(label: "concurrent", attributes: .concurrent)
    private let rootView: GSDView = .init()
    private let label: UILabel = {
        let label: UILabel = .init()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    private lazy var stackView: UIStackView = {
        let stackView: UIStackView = .init(arrangedSubviews: [sirealButton, concurrentButton])
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
        view.addSubview(rootView)
        rootView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.top.equalTo(rootView.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func loading(isStart: Bool) {
        label.textColor = isStart ? .gray : .black
        if isStart {
            rootView.startLoad()
        } else {
            rootView.finishLoad()
        }
        
        stackView.arrangedSubviews.forEach {
            switch $0 {
            case let button as UIButton:
                button.isEnabled = !isStart
                
            default:
                break
            }
        }
    }
    
    private func finishLoad(initDate: Date) {
        rootView.updateView(datas: datas)
        label.text = "time: \(Date().timeIntervalSince(initDate))"
        datas.removeAll()
        loading(isStart: false)
    }
    
    @objc func buttonTouchUpInside(_ sender: UIButton) {
        let initDate: Date = .init()
        let workItem: DispatchWorkItem = .init {
            DispatchQueue.main.async { [weak self] in
                self?.finishLoad(initDate: initDate)
            }
        }
        
        switch sender {
        case sirealButton:
            loading(isStart: true)
            sirealTestMethod(initDate: initDate, workItem: workItem)
            
        case concurrentButton:
            loading(isStart: true)
            concurrentTestMethod(initDate: initDate, workItem: workItem)
            
        default:
            break
        }
    }
}

// MARK: - calculated properties
private extension GSDViewController {
    func sirealTestMethod(initDate: Date, workItem: DispatchWorkItem) {
        DispatchQueue.global().async { [weak self, countInteration] in
            let group: DispatchGroup = .init()
            for i in 0 ..< countInteration {
                group.enter()
                let aueue: DispatchQueue = .init(label: "sireal")
                aueue.async { [weak self] in
                    self?.testMethod(initDate: initDate, index: i)
                    group.leave()
                }
            }
            
            group.notify(
                queue: .global(),
                work: workItem)
        }
    }
    
    func concurrentTestMethod(initDate: Date, workItem: DispatchWorkItem) {
        DispatchQueue.global().async { [weak self, countInteration] in
            let group: DispatchGroup = .init()
            for i in 0 ..< countInteration {
                group.enter()
                self?.concurrentQueue.async { [weak self] in
                    self?.testMethod(initDate: initDate, index: i)
                    group.leave()
                }
            }
            
            group.notify(
                queue: .global(),
                work: workItem)
        }
    }
    
    private func testMethod(initDate: Date, index: Int) {
        if !isCancelled {
            if let data = GSDThreadData(initDate: initDate, thread: Thread.current) {
            Thread.sleep(forTimeInterval: 0.01)
                let _data = data.updateFinishDate()
                synchronize { [weak self] in
                    self?.datas.insert(_data)
                }
                
                if !isCancelled {
                    print(_data)
                }
            }
        }
    }
    
    private func synchronize(completion: @escaping () -> Void) {
        synchronizationQueue.sync {
            completion()
        }
    }
}
