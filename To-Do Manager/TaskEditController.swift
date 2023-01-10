import UIKit
import Foundation

// Класс создания или редактирования таски
class TaskEditController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTitle.text = taskText
        taskTypeLabel.text = taskTitles[taskType]
        taskStatusLabel.text = taskTitlesStatusSwich[taskStatus]
        if taskStatus == .completed {
            statusSwitch.isOn = true
        } else {
            statusSwitch.isOn = false
        }
    }
	
	// класс сохраняющий данные
    @IBAction func saveTask() {
        let title = taskTitle.text!.trimmingCharacters(in: .whitespaces)
        if title == "" {
			// валидация при пустом названии такски
            let allert = UIAlertController(title: "Неверные данные", message: "Заполните текст в поле", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Повторить", style: .default, handler: nil)
            allert.addAction(ok)
            self.present(allert, animated: true, completion: nil)
        } else {
            let type = taskType
            let status: TaskStatus = statusSwitch.isOn ? .completed : .planned
            doAfterEdit?(title, type, status)
            navigationController?.popViewController(animated: true)
        }
    }

    private var taskTitles: [TaskPriority: String] = [
        .important: "Важная",
        .normal: "Текушая"
    ]
    
    private var taskTitlesStatusSwich: [TaskStatus: String] = [
        .planned: "Запланированно",
        .completed: "Выполненно"
    ]
    
	// свойства через которых происходит передача данных между контроллерами
    var taskText: String?
    var taskType: TaskPriority = .normal
    var taskStatus: TaskStatus = .planned
    
	// Аутлеты элементов интерфейса
    @IBOutlet var taskTitle: UITextField!
    @IBOutlet var taskTypeLabel: UILabel!
    @IBOutlet var taskStatusLabel: UILabel!
    @IBOutlet var statusSwitch: UISwitch!
    
	// свойство нужное для передачи данных назад в Лист
    var doAfterEdit: ((String, TaskPriority, TaskStatus) -> Void)?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        }

	// Переход в следующий контроллер с передачей типа таски
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskTypeScreen" {
        let dest = segue.destination as! TaskTypeController
        
        dest.selectedType = taskType
        
        dest.doAfterSelectedType = { [unowned self] typeSelected in
            taskType = typeSelected
            taskTypeLabel.text = taskTitles[taskType]
            }
        }
    }
}
