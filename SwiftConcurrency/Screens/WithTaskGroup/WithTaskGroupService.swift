//
//  WithTaskGroupService.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 10.01.2025.
//

import Foundation

struct WithTaskGroupModel {
    let object1: Object1
    let object2: Object2
    
    struct Object1: Codable {
        let name: String
        let value: Int
    }
    
    struct Object2: Codable {
        let id: UUID
        let data: String
    }
}

protocol WithTaskGroupServiceDelegate: AnyObject {
    func withTaskGroupServiceLogger(_ service: WithTaskGroupService, message: String)
}

actor WithTaskGroupService {
    
    // MARK: - private properties
    private var logger: [String] = [] {
        didSet {
            delegate?.withTaskGroupServiceLogger(self, message: logger.joined(separator: "\n"))
        }
    }
    
    // MARK: - public properties
    private weak var delegate: WithTaskGroupServiceDelegate?
    
    // MARK: - initializers
    deinit {
        print("deinit: WithTaskGroupService")
    }
    
    // MARK: - public methods
    func setDelegate(_ delegate: WithTaskGroupServiceDelegate) {
        self.delegate = delegate
    }
    
    func load() async throws -> (WithTaskGroupModel) {
        logger.removeAll()
        logger.append("Start load objects")
        
        return try await withThrowingTaskGroup(of: Any?.self) { group in
            // Добавляем первую задачу
            group.addTask { [weak self] in
                try await self?.fetchObject1()
            }
            
            // Добавляем вторую задачу
            group.addTask { [weak self] in
                try await self?.fetchObject2()
            }
            
            print(group)
            dump(group)
            
            var object1: WithTaskGroupModel.Object1?
            var object2: WithTaskGroupModel.Object2?
            
            // Ждем завершения всех задач и собираем результаты
            for try await result in group {
                if let obj1 = result as? WithTaskGroupModel.Object1 {
                    object1 = obj1
                    
                } else if let obj2 = result as? WithTaskGroupModel.Object2 {
                    object2 = obj2
                }
            }
            
            // Распаковываем результаты
            guard
                let object1,
                let object2
            else {
                throw NSError(domain: "TaskGroup", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error while getting results"])
            }
            
            logger.append("End load objects")
            return .init(
                object1: object1,
                object2: object2)
        }
    }
    
    // MARK: - private methods
    private func fetchObject1() async throws -> WithTaskGroupModel.Object1 {
        logger.append("Fetching Object 1...")
        try await Task.sleep(nanoseconds: 3_000_000_000)
        let object1: WithTaskGroupModel.Object1 = .init(name: "My Object 1", value: 42)
        logger.append("\(object1)")
        return object1
    }
    
    private func fetchObject2() async throws -> WithTaskGroupModel.Object2 {
        logger.append("Fetching Object 2...")
        try await Task.sleep(nanoseconds: 3_000_000_000)
        let object2: WithTaskGroupModel.Object2 = .init(id: UUID(), data: "Some data for object 2")
        logger.append("\(object2)")
        return object2
    }
}
