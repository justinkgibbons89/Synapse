import UIKit
import CoreData

class ItemListVC: UITableViewController {
	
	//MARK: Properties
	public var channel: Channel!
	
	//MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		print("Item list loaded.")
	}
	
	//MARK: UITableView Data Source
	private lazy var tableData: [Item] = {
		let fetch = Item.fetchRequest() as NSFetchRequest<Item>
		fetch.predicate = NSPredicate(format: "channel = %@", self.channel)
		fetch.sortDescriptors = []
		let results = try! CoreData.shared.mainContext.fetch(fetch)
		print("Returning \(results.count) results!")
		for item in results {
			if let title = item.title {
				print(title)
			} else {
				print("item had no title")
			}
		}
		return results
	}()
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell()
		cell.textLabel?.text = tableData[indexPath.row].title
		return cell
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableData.count
	}
}
