//
//  BubbleSortingViewController.swift
//  SwiftConcurrency
//
//  Created by ZverikRS on 15.02.2025.
//

import UIKit

final class BubbleSortingViewController: BaseViewController {
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
}

// MARK: - config
private extension BubbleSortingViewController {
    private func config() {
        let array: [Int] = [4, 5, 11, 9, 2, 10, 1, 6, 3, 8, 0, 7]
        print(array)
        print(array.sortedMerge())
    }
}

/// Сортировка пузырьком (Bubble Sort)
/// Простейший, но наименее эффективный алгоритм. Сравнивает соседние элементы и меняет их местами, если они не в правильном порядке.
/// Время: O(n^2).
extension Array where Element: Comparable {
    func sortedBubble() -> [Element] {
        var sortArray = self
        return sortArray.sortBubble()
    }
    
    mutating func sortBubble() -> [Element] {
        for i in 0 ..< count {
            for j in 0 ..< count - 1 - i {
                if self[j] > self[j + 1] {
                    swapAt(j + 1, j)
                }
            }
        }
        
        return self
    }
}

/// Сортировка вставками (Insertion Sort)
/// Более эффективна, чем сортировка пузырьком, особенно для частично отсортированных данных.
/// Строит отсортированную последовательность, вставляя элементы по одному в правильное место.
/// Время: O(n^2), но близко к O(n) для почти отсортированных массивов
extension Array where Element: Comparable {
    func sortedInsertion() -> [Element] {
        var sortArray = self
        return sortArray.sortInsertion()
    }
    
    mutating func sortInsertion() -> [Element] {
        for i in 1 ..< count {
            var j = i
            while j > 0 && self[j] < self[j - 1] {
                swapAt(j, j - 1)
                j -= 1
            }
        }
        
        return self
    }
}

/// Сортировка выбором (Selection Sort)
/// Находит наименьший элемент в неотсортированной части массива и помещает его в начало.
/// Время: O(n^2)
extension Array where Element: Comparable {
    func sortedSelection() -> [Element] {
        var sortArray = self
        return sortArray.sortSelection()
    }
    
    mutating func sortSelection() -> [Element] {
        for i in 0 ..< count - 1 {
            var minIndex = i
            for j in i + 1 ..< count {
                if self[j] < self[minIndex] {
                    minIndex = j
                }
            }
            if minIndex != i {
                swapAt(i, minIndex)
            }
        }
        
        return self
    }
}

/// Сортировка слиянием (Merge Sort)
/// Алгоритм "разделяй и властвуй". Разделяет массив на две половины, рекурсивно сортирует их, а затем сливает отсортированные половины.
/// Время: O(n log n). Стабильная сортировка.
extension Array where Element: Comparable {
    func sortedMerge() -> [Element] {
        guard count > 1 else { return self }
        
        let middleIndex = count / 2
        let leftArray = Array(self[0 ..< middleIndex])
        let rightArray = Array(self[middleIndex ..< count])
        
        return leftArray.sortedMerge().merge(array: rightArray.sortedMerge())
    }
    
    private func merge(array: [Element]) -> [Element] {
        var selfIndex = 0
        var mergeArrayIndex = 0
        var mergedArray: [Element] = []
        
        while selfIndex < count && mergeArrayIndex < array.count {
            if self[selfIndex] < array[mergeArrayIndex] {
                mergedArray.append(self[selfIndex])
                selfIndex += 1
            } else {
                mergedArray.append(array[mergeArrayIndex])
                mergeArrayIndex += 1
            }
        }
        
        mergedArray.append(contentsOf: self[selfIndex...])
        mergedArray.append(contentsOf: array[mergeArrayIndex...])
        return mergedArray
    }
}
