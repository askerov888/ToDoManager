import UIKit
import Foundation

// Протоколы включающий в себя загрузку и сохранение данных
protocol TasksStorageProtocol {
    func loadTasks() -> [TaskProtocol]
    func saveTasks(_ tasks: [TaskProtocol])
}

// Класс сторадж (UserDefaults)
class TasksStorage: TasksStorageProtocol {
    private var storage = UserDefaults.standard
    var storageKey = "tasks"
    private enum taskKey: String {
        case title
        case type
        case status
    }
    
	// Метод, в котором происходит загрузка данных
    func loadTasks() -> [TaskProtocol] {
		
		// Массив, куда будут помещаться данные
        var resultTasks: [TaskProtocol] = []
		
		// Тестовые данные
//		var resultTask: [TaskProtocol] = [
//			Task(title: "Купить хлеб", type: .normal, status: .planned),
//            Task(title: "Помыть кота", type: .important, status: .planned),
//            Task(title: "Отдать долг Арнольду", type: .important, status: .completed),
//            Task(title: "Купить новый пылесос", type: .normal, status: .completed),
//            Task(title: "Подарить цветы супруге", type: .important, status: .planned),
//            Task(title: "Позвонить родителям", type: .important, status: .planned),
//            Task(title: "Пригласить на вечеринку Дольфа, Джеки, Леонардо, Уилла и Джонни", type: .important, status: .planned) ]
		
		// Массив из словарей, выгруженный из UserDefaults
        let arrayFromStorage = storage.array(forKey: storageKey) as? [[String: String]] ?? []
        
		// Помещение данных в специально подготовленный пустой массив
        for task in arrayFromStorage {
            guard let title = task[taskKey.title.rawValue],
                  let typeRaw = task[taskKey.type.rawValue],
                  let statusRaw = task[taskKey.status.rawValue] else {continue}
            let type: TaskPriority = typeRaw == "important" ? .important: .normal
            let status: TaskStatus = statusRaw == "completed" ? .completed: .planned
            resultTasks.append(Task(title: title, type: type, status: status))
        }
        return resultTasks
    }
    
	// Сохранение данных в UserDefaults
    func saveTasks(_ tasks: [TaskProtocol]) {
		// Подготовка пустого массива из словарей для UserDefaults
        var arrrayForStorage: [[String: String]] = []
        
		// Помещение данных в новый словарь и поочередное добавление в специально подготовленный массив
        tasks.forEach { task in
            var newElement: [String: String] = [:]
            newElement[taskKey.title.rawValue] = task.title
            newElement[taskKey.type.rawValue] = (task.type == .important ? "important" : "normal")
            newElement[taskKey.status.rawValue] = (task.status == .completed ? "completed": "planned")
            arrrayForStorage.append(newElement)
        }
		// Установка массива в UserDefaults
        storage.set(arrrayForStorage, forKey: storageKey)
    }
}
