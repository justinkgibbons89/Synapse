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
		tableView.dataSource = diffableDataSource
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateUI()
	}
	//MARK: UITableView Diffable Data Source
	private lazy var diffableDataSource: UITableViewDiffableDataSource<Int, Channel> = {
		UITableViewDiffableDataSource<Int, Channel>(tableView: tableView) { (tableView, indexPath, channel) -> UITableViewCell? in
			let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
			cell.textLabel?.text = channel.title
			return cell
		}
	}()
	
	func updateUI(animated: Bool = true) {
        var currentSnapshot = NSDiffableDataSourceSnapshot<Int, Channel>()
        currentSnapshot.appendSections([0])
        currentSnapshot.appendItems(tableData, toSection: 0)
		diffableDataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
	
	//MARK: UITableView Data Source
	private lazy var tableData: [Channel] = {
		let fetch = Channel.fetchRequest() as NSFetchRequest<Channel>
		fetch.predicate = nil
		fetch.sortDescriptors = []
		let results = try! CoreData.shared.mainContext.fetch(fetch)
		return results
	}()
	
	/*
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
	*/
	//MARK: Fetched Results Controller
	
	
	
}

