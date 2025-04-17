//
//  GSDView.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 06.02.2025.
//

import UIKit
import SnapKit

final class GSDView: UIView {
    
    // MARK: - private properties
    private let label: UILabel = {
        let label: UILabel = .init()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView: UIActivityIndicatorView = .init(style: .large)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = .blue
        return activityIndicatorView
    }()
    
    // MARK: - initializers
    init() {
        super.init(frame: .zero)
        config()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public methods
    func updateView(datas: Set<GSDThreadData>) {
        label.text = "numbers: \(datas.count)"
    }
    
    func startLoad() {
        activityIndicatorView.startAnimating()
        label.isHidden = true
    }
    
    func finishLoad() {
        activityIndicatorView.stopAnimating()
        label.isHidden = false
    }
    
    // MARK: - private methods
    private func config() {
        addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
