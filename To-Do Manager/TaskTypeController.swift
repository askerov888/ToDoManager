import UIKit

// TableVC предназначенная для изменения типа таска
class TaskTypeController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let cellTypeNib = UINib(nibName: "TaskTypeCell", bundle: nil)
        tableView.register(cellTypeNib, forCellReuseIdentifier: "TaskTypeCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return TypeCellInformation.count
    }
    
    typealias TypeCell = (title: String, description: String, type: TaskPriority)
    
    private var TypeCellInformation: [TypeCell] = [
        (title: "Важная", description: "Такой тип задач является наиболее приоритетным для выполнения. Все важные задачи выводятся в самом верху списка задач", type: .important),
        (title: "Текущая", description: "Задача с обычным приоритетом", type: .normal)
    ]
    
    var selectedType: TaskPriority = .normal

	// Описание ячейки
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// создание ячейки с помощью её пересипользования
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTypeCell", for: indexPath) as! TaskTypeCell
        
        let type = TypeCellInformation[indexPath.row]
        
        cell.typeTitle.text = type.title
        cell.typeDescription.text = type.description
        
        if selectedType == type.type {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    var doAfterSelectedType: ((TaskPriority) -> Void)?
    
	// Выбор типа данных (.important / .normal) и переход назад
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selecteddTypeInRow = TypeCellInformation[indexPath.row].type
        
        doAfterSelectedType?(selecteddTypeInRow)
        navigationController?.popViewController(animated: true)
    }
}
