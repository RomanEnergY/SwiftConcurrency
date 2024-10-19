//
//  BaseViewController.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 10.01.2025.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {
    
    // MARK: - private properties
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.text = "\(Self.description())"
        return label
    }()
    
    // MARK: - initializers
    deinit {
        print("deinit: \(Self.description())")
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
        }
    }
}
