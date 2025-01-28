//
//  AlgoritmViewController.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 09.01.2025.
//

import UIKit
import SnapKit

final class AlgoritmViewController: BaseViewController {
    
    // MARK: - private properties
    private let algoritmView: AlgoritmView = .init()
    private lazy var startButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle("start", for: .normal)
        button.addTarget(self, action: #selector(onButtonTouchUpInside), for: .touchUpInside)
        return button
    }()
    private lazy var resetButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle("reset", for: .normal)
        button.addTarget(self, action: #selector(onButtonTouchUpInside), for: .touchUpInside)
        return button
    }()
    
    // MARK: - initializers
    deinit {
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    // MARK: - private methods
    @objc private func onButtonTouchUpInside(_ sender: UIButton) {
        switch sender {
        case startButton:
            algoritmView.next()
        case resetButton:
            algoritmView.reset()
        default:
            break
        }
    }
}

// MARK: - config
private extension AlgoritmViewController {
    private func config() {
        view.addSubview(algoritmView)
        algoritmView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize(width: 250, height: 250))
        }
        
        let stackView: UIStackView = .init()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .equalCentering
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(algoritmView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        stackView.addArrangedSubview(startButton)
        stackView.addArrangedSubview(resetButton)
    }
}

// MARK: - AlgoritmView
final class AlgoritmView: UIView {
    private struct Point {
        let title: String
        let coordinate: CGPoint
    }
    
    fileprivate struct BindingPoint {
        let main: String
        let bindings: [String]
    }
    
    fileprivate final class Road {
        var uid: String = UUID().uuidString
        var items: [Item] = []
        var result: (Result<Bool, Error>)?
        
        struct Item {
            let main: String
            let binding: String
        }
    }
    
    private var pointArray: [Point] = []
    private var bindingBlack: [BindingPoint] = []
    private var roads: [Road] = []
    private let lineWidth: CGFloat = 5
    private var lineWidthCenter: CGFloat {
        lineWidth / 2
    }
    
    // MARK: - initializers
    init() {
        super.init(frame: .zero)
        config()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - life cycle
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setLineWidth(lineWidth)
        bindingBlack.forEach { item in
            guard let main = pointArray.first(where: { $0.title == item.main }) else { return }
            item.bindings.forEach { bindingItem in
                guard let bindingItem = pointArray.first(where: { $0.title == bindingItem }) else { return }
                context.move(to: main.coordinate)
                context.addLine(to: bindingItem.coordinate)
                context.setStrokeColor(UIColor.black.cgColor)
                context.strokePath()
            }
        }
        
        bindingBlack.forEach { item in
            guard let main = pointArray.first(where: { $0.title == item.main }) else { return }
            let ellipseWidth = lineWidth * 2
            context.addEllipse(in: .init(
                x: main.coordinate.x - ellipseWidth / 2,
                y: main.coordinate.y - ellipseWidth / 2,
                width: ellipseWidth,
                height: ellipseWidth))
            
            context.setFillColor(UIColor.white.cgColor)
            context.fillPath()
        }
        
        roads.forEach { item in
            item.items.enumerated().forEach { enumerate in
                guard let main = pointArray.first(where: { $0.title == enumerate.element.main }),
                      let binding = pointArray.first(where: { $0.title == enumerate.element.binding })
                else {
                    return
                }
                
                context.move(to: main.coordinate)
                context.addLine(to: binding.coordinate)
                context.setStrokeColor(UIColor.green.cgColor)
                context.strokePath()
                
                let ellipseWidth = lineWidth * 2
                context.addEllipse(in: .init(
                    x: main.coordinate.x - ellipseWidth / 2,
                    y: main.coordinate.y - ellipseWidth / 2,
                    width: ellipseWidth,
                    height: ellipseWidth))
                
                let mainColor: UIColor = enumerate.offset == 0 ? .red : .green
                context.setFillColor(mainColor.cgColor)
                context.fillPath()
                
                context.addEllipse(in: .init(
                    x: binding.coordinate.x - ellipseWidth / 2,
                    y: binding.coordinate.y - ellipseWidth / 2,
                    width: ellipseWidth,
                    height: ellipseWidth))
                
                let bindingColor: UIColor
                if enumerate.offset == 0 {
                    bindingColor = item.items.count == 1 ? .white : .green
                } else {
                    bindingColor = .white
                }
                
                context.setFillColor(bindingColor.cgColor)
                context.fillPath()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateStage()
    }
    
    // MARK: - public methods
    func next() {
        if let roadLast = roads.last,
           let roadItemsLast = roadLast.items.last,
           !(roadLast.items.map { $0.main }.contains(where: { $0 == roadItemsLast.binding })) {
            nextStep(road: roadLast)
            
        } else {
            roads.removeAll()
            nextStep(road: .init())
        }
        setNeedsDisplay()
    }
    
    func reset() {
        roads.last?.items.removeAll()
        setNeedsDisplay()
    }
    
    // MARK: - private methods
    private func config() {
        backgroundColor = .white
    }
    
    private func nextStep(road: Road) {
        guard !road.items.isEmpty else {
            let element = pointArray.randomElement()
            let mainPoint = bindingBlack.first(where: { $0.main == element?.title ?? "" })
            let direction = mainPoint?.bindings.randomElement()
            
            guard let mainPoint, let direction else {
                return
            }
            
            appendRoad(road, mainPoint: mainPoint.main, direction: direction)
            return
        }
        
        recursionSearchNextStep(road)
    }
    
    private func recursionSearchNextStep(_ road: Road) {
        guard 
            let roadItemLastBinding = road.items.last,
            let direction = bindingBlack.searchDirection(road: road)
        else {
            return
        }
        
        appendRoad(road, mainPoint: roadItemLastBinding.binding, direction: direction)
    }
    
    private func appendRoad(_ road: Road, mainPoint: String, direction: String) {
        road.items.append(.init(
            main: mainPoint,
            binding: direction))
        
        if roads.first(where: { $0.uid == road.uid }) == nil {
            roads.append(road)
        }
    }
    
    private func updateStage() {
        pointArray.removeAll()
        pointArray.append(contentsOf: [
            .init(title: "A", coordinate: .init(x: lineWidth, y: lineWidth)),
            .init(title: "B", coordinate: .init(x: bounds.midX, y: lineWidth)),
            .init(title: "C", coordinate: .init(x: bounds.maxX - lineWidth, y: lineWidth)),
            .init(title: "D", coordinate: .init(x: lineWidth, y: bounds.midY)),
            .init(title: "E", coordinate: .init(x: bounds.midX, y: bounds.midY)),
            .init(title: "F", coordinate: .init(x: bounds.maxX - lineWidth, y: bounds.midY)),
            .init(title: "G", coordinate: .init(x: lineWidth, y: bounds.maxY - lineWidth)),
            .init(title: "H", coordinate: .init(x: bounds.midX, y: bounds.maxY - lineWidth)),
            .init(title: "I", coordinate: .init(x: bounds.maxX - lineWidth, y: bounds.maxY - lineWidth))
        ])
        
        bindingBlack.append(contentsOf: [
            .init(main: "A", bindings: ["B", "D"]),
            .init(main: "B", bindings: ["C", "E"]),
            .init(main: "C", bindings: ["F"]),
            .init(main: "D", bindings: ["G"]),
            .init(main: "E", bindings: ["G", "I"]),
            .init(main: "E", bindings: ["G", "I"]),
            .init(main: "F", bindings: ["I"]),
            .init(main: "G", bindings: ["H"]),
            .init(main: "H", bindings: ["I"]),
            .init(main: "I", bindings: ["H", "E"])
        ])
    }
}

private extension Array where Element == AlgoritmView.BindingPoint {
    func searchDirection(road: AlgoritmView.Road) -> String? {
        guard let lastElement = road.items.last else { return nil }
        var roadMainItems = road.items.map { $0.main }
        roadMainItems.append(lastElement.binding)
        
        let bindings = searchPoints(for: lastElement.binding)
        let subtracting = bindings.subtracting(roadMainItems)
        if subtracting.isEmpty {
            let point = roadMainItems.first(where: { item in
                bindings.contains { $0 == item }
            })
            
            if let point,
               searchPoints(for: point).isEmpty {
                
            } else {
                
            }
            
            return point
            
        } else {
            return subtracting.randomElement()
        }
    }
    
    private func searchMainElement(for binding: String) -> String? {
        let element = first(where: { $0.main == binding })
        return element?.main
    }
    
    private func searchBindingsElement(for binding: String) -> [String]? {
        let element = first(where: { $0.bindings.contains { $0 == binding }})
        return element?.bindings
    }
    
    private func searchPoints(for binding: String) -> Set<String> {
        let main = first(where: { $0.main == binding })?.bindings ?? []
        let bindings = self
            .filter { $0.bindings.contains(where: { $0 == binding }) }
            .map { $0.main }
        
        return Set([main, bindings]
            .flatMap { $0 })
    }
}
