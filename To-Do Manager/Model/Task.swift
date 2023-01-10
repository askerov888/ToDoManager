import Foundation
import UIKit

// Подготовка тасков и их значений

enum TaskPriority {
    case important
    case normal
}

enum TaskStatus {
    case planned
    case completed
}

protocol TaskProtocol {
    var title: String {get set}
    var type: TaskPriority {get set}
    var status: TaskStatus {get set}
}

struct Task: TaskProtocol {
    var title: String
    var type: TaskPriority
    var status: TaskStatus
}
