import UIKit
import CoreData

class ChannelsVC: UITableViewController {

	//MARK: IBActions
	@IBAction func addButtonTapped(_ sender: Any) {
		let vc = UIStoryboard.instantiate("AddFeedVC", as: AddFeedVC.self)
		navigationController?.pushViewController(vc, animated: true)
	}
	
	//MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		//FeedReader.subscribe(to: "https://www.econlib.org/author/bcaplan/feed")
		//FeedReader.subscribe(to: "https://overcomingbias.com/feed")
	}
	
	//MARK: UITableView Data Source
	private lazy var tableData: [Channel] = {
		let fetch = Channel.fetchRequest() as NSFetchRequest<Channel>
		fetch.predicate = nil
		fetch.sortDescriptors = []
		let results = try! CoreData.shared.mainContext.fetch(fetch)
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
	
	//MARK: UITableView Delegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedChannel = tableData[indexPath.row]
		let vc = UIStoryboard.instantiate("ItemListVC", as: ItemListVC.self)
		vc.navigationItem.title = selectedChannel.title
		vc.channel = selectedChannel
		navigationController?.pushViewController(vc, animated: true)
	}
	
	
}

