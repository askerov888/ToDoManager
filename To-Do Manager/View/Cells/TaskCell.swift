import UIKit

// класс описывающий ячейку таски черех xib, статически
class TaskCell: UITableViewCell {
    
    @IBOutlet var symbol: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var hid: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
