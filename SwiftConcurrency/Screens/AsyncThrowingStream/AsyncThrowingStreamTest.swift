//
//  AsyncThrowingStreamTest.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 11.01.2025.
//

import Foundation

final class AsyncThrowingStreamTest {
    enum Status {
        case downloading(Float)
        case completed(String)
    }
    
    // MARK: - private properties
    private var value: Int = 0
    private var finishValue: Int = 10
    
    // MARK: - public methods
    func next() {
        value += 1
    }
    
    func cancel() {
        value
    }
    
    func download(
        urlStr: String,
        progressHandler: (Float) -> Void,
        completion: (Result<String, Error>) -> Void
    ) throws {
        // .. Download implementation
    }
}

extension AsyncThrowingStreamTest {
    func download(urlStr: String) -> AsyncThrowingStream<Status, Error> {
        return AsyncThrowingStream { continuation in
            do {
                try download(
                    urlStr: urlStr,
                    progressHandler: { progress in
                        continuation.yield(.downloading(progress))
                    },
                    completion: { result in
                        switch result {
                        case .success(let data):
                            continuation.yield(.completed(data))
                            continuation.finish()
                            
                        case .failure(let error):
                            continuation.finish(throwing: error)
                        }
                    })
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}
