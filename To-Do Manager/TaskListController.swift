import Foundation
import UIKit

	// Класс описывающий лист задач
class TaskListController: UITableViewController {
	
    // хранилище задач
    var tasksStorage: TasksStorageProtocol = TasksStorage()
	
    // коллекция задач
    var tasks: [TaskPriority:[TaskProtocol]] = [:] {
		// Обсервер, который сортирует задачи по статусу (выполненные ниже, запланнированные выше)
        didSet {
            for (tasksGroupPriority, taskGroup) in tasks {
                tasks[tasksGroupPriority] = taskGroup.sorted { task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2position
                }
            }
            var savingArray: [TaskProtocol] = []
            tasks.forEach { _, value in
                savingArray += value
            }
			// сохрание задач в хранилище после изменений
            tasksStorage.saveTasks(savingArray)
        }
        willSet {
            tableView.reloadData()
        }
    }
    
	// Начальная установка задач в таблице
    func setTasks(_ tasksCollection: [TaskProtocol]) {
		// Группируем по важности
    sectionsTypesPosition.forEach { taskType in
    tasks[taskType] = []
    }
		// добавляем в уже сгруппированный массив, задачи
    tasksCollection.forEach { task in
    tasks[task.type]?.append(task)
    }
}

    
    // порядок отображения секциий по типам
    // индекс в массиве соответствует индексу секции в таблице
    var sectionsTypesPosition: [TaskPriority] = [.important, .normal]
    
	// порядок отображения задач по их статусу
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]

    override func viewDidLoad() {
        super.viewDidLoad()
		// Загрузка задач
        loadTasks()
		
		// Добавление кнопки edit в navigationBar
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		// Вытаскивания типа задачи
        let taskType = sectionsTypesPosition[indexPath.section]
        // Удаление задачи из хранилища
		tasks[taskType]?.remove(at: indexPath.row)
        // Удаление строки в таблице
		tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Создание 2 константы секций (старая секция и новая)
        let taskTypeFrom = sectionsTypesPosition[sourceIndexPath.section]
        let taskTypeTo = sectionsTypesPosition[destinationIndexPath.section]
        
		// Безопасное извлечение двигающуйся таски
        guard let moveTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }
        // Удаление строки откуда она пришла
        tasks[taskTypeFrom]?.remove(at: sourceIndexPath.row)
        // Добавление строки куда передвинули
        tasks[taskTypeTo]?.insert(moveTask, at: destinationIndexPath.row)
        
        // При измнении типа, то меняется и тип
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]?[destinationIndexPath.row].type = taskTypeTo
        }
        // Обновление данных
        tableView.reloadData()
    }
    
    private func loadTasks() {
        // Создание словаря с ключами important, normal и с пустыми значениями/массив
        sectionsTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        // Каждую таску которая загружается называем task и помещаем в массив в зависимости от типа приоритета
        tasksStorage.loadTasks().forEach { task in
            tasks[task.type]?.append(task)
        }
    }


    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
     return tasks.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let taskType = sectionsTypesPosition[section]
        guard let currentTasksType = tasks[taskType] else {
            return 0
        }
        return currentTasksType.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return getConfiguredTaskCell_constraints(for: indexPath)
        return getConfiguredTaskCell_stack(for: indexPath)
    }

	// Оглавление каждой секции
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let taskType = sectionsTypesPosition[section]
        if taskType == .important {
            title = "Важные"
        } else if taskType == .normal {
            title = "Текущие"
        }
        return title
    }
    
	// Действия при нажатии на строку (изменения статуса)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // верификация на то, что строка есть
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return
        }
        // верификация на то, что строка имеет статус "Запланировано", если нет, то снимаем выделенение
        guard tasks[taskType]![indexPath.row].status == .planned else {
            return tableView.deselectRow(at: indexPath, animated: true)
        }
        // Изменение статуса строки
        tasks[taskType]![indexPath.row].status = .completed
        // Обновление секции в таблице
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
	// Действие при свайпа слева направо
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskType = sectionsTypesPosition[indexPath.section]
        guard (tasks[taskType]?[indexPath.row]) != nil else {return nil}
        
		// Описание Action - Не выполнено
        let dontCompleted = UIContextualAction(
            style: .normal,
            title: "Не выполнена",
            handler: {_,_,_ in
                self.tasks[taskType]?[indexPath.row].status = .planned
                tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
            }
        )
        
		// Описания Action - Edit
        let editTasks = UIContextualAction(
            style: .normal,
            title: "Изменить") { _,_,_ in
                let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskEditController") as! TaskEditController
				// Передача старых данных в edit контроллер
                editScreen.taskText = self.tasks[taskType]?[indexPath.row].title
                editScreen.taskType = self.tasks[taskType]![indexPath.row].type
                editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
                editScreen.doAfterEdit = { [self] title, type, status in
                    let editedTask = Task(title: title, type: type, status: status)
                    tasks[taskType]![indexPath.row] = editedTask
                    tableView.reloadData()
                }
				// переход в edit контроллер
                self.navigationController?.pushViewController(editScreen, animated: true)
                
            }
        editTasks.backgroundColor = .darkGray
        let swipeConfiguration: UISwipeActionsConfiguration
		
		// Логика появление action кнопок зависящая от статуса
        if tasks[taskType]![indexPath.row].status == .completed   {
        swipeConfiguration = UISwipeActionsConfiguration(actions: [editTasks, dontCompleted])
        } else  {
        swipeConfiguration = UISwipeActionsConfiguration(actions: [editTasks])
        }
    return swipeConfiguration
}
    
	// Помещение новых или измененных данных из контроллера edit в массив
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let dest = segue.destination as! TaskEditController
            dest.doAfterEdit = { [unowned self] title, type, status in
                let newTask = Task(title: title, type: type, status: status)
                tasks[type]?.append(newTask)
				// обновление таблицы
                tableView.reloadData()
            }
        }
    }
    
    
//    private func getConfiguredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
//        // загружаем прототип ячейки по идентификатору
//        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
//
//        // получаем данные о задаче, которую необходимо вывести в ячейке
//        let taskType = sectionsTypesPosition[indexPath.section]
//
//        guard let currentTask = tasks[taskType]?[indexPath.row] else {return cell}
//
//        // текстовая метка символа
//        let symbolLabel = cell.viewWithTag(1) as? UILabel
//        // текстовая метка названия задачи
//        let textLabel = cell.viewWithTag(2) as? UILabel
//
//        // изменяем символ в ячейке
//        symbolLabel?.text = getSymbolForTask(with: currentTask.status)
//        // изменяем текст в ячейке
//        textLabel?.text = currentTask.title
//
//        // изменяем цвет текста и символа в зависимости от статуса таски
//        if currentTask.status == .planned {
//            symbolLabel?.textColor = .black
//            textLabel?.textColor = .black
//        } else {
//            symbolLabel?.textColor = .lightGray
//            let attributedText = NSAttributedString(
//                string: textLabel?.text ?? "",
//                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
//            )
//            textLabel?.attributedText = attributedText
//            textLabel?.textColor = .lightGray
//
//        }
//        return cell
//    }
    
    // Описание символа для соответствующего типа задачи
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var resultSymbol: String
        if status == .planned {
            resultSymbol = "\u{25CB}"
        } else if status == .completed {
            resultSymbol = "\u{25C9}"
        } else {
                resultSymbol = ""
            }
        return resultSymbol
    }
    
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        
        let taskType = sectionsTypesPosition[indexPath.section]
        
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        cell.title.text = currentTask.title
		
		// Вставка символа для соответствующего типа задачи
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        
		// Логика зачеркивания текста зависящая от статуса
        if currentTask.status == .planned {
            cell.symbol.textColor = .black
            cell.title.textColor = .black
            let attributedText = NSAttributedString(
                string: cell.title.text ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.isEmpty]
            )
            cell.title.attributedText = attributedText
        }
        else {
            cell.symbol.textColor = .lightGray
            cell.title.textColor = .lightGray
            let attributedText = NSAttributedString(
                string: cell.title.text ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            cell.title.attributedText = attributedText
        }
        return cell
    }
    
}
