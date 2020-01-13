import UIKit
import CoreData

class ChannelsVC: UITableViewController, NSFetchedResultsControllerDelegate {

	//MARK: IBActions
	@IBAction func addButtonTapped(_ sender: Any) {
		let vc = UIStoryboard.instantiate("AddFeedVC", as: AddFeedVC.self)
		navigationController?.pushViewController(vc, animated: true)
	}
	
	//MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = diffableDataSource
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		tableView.delegate = self
		configureFetchedResultsController()
		updateSnapshot(animated: false)
	}
	
	override func viewDidAppear(_ animated: Bool) {
			super.viewDidAppear(animated)
//			FeedReader.subscribe(to: "https://theamericansun.com/rss")
//			FeedReader.subscribe(to: "https://slatestarcodex.com/feed")
	}
	
	//MARK: UITableView Diffable Data Source
	private lazy var diffableDataSource: UXDiffableDataSource<Int, Channel> = {
		UXDiffableDataSource<Int, Channel>(tableView: tableView) { (tableView, indexPath, channel) -> UITableViewCell? in
			let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
			cell.textLabel?.text = channel.title
			return cell
		}
	}()
	
	//MARK: Fetched Results Controller
	private var frc: NSFetchedResultsController<Channel>!
	
	func configureFetchedResultsController() {
		let fetch = Channel.fetchRequest() as NSFetchRequest<Channel>
		fetch.predicate = nil
		fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Channel.subscribeDate, ascending: true)]
		frc = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: CoreData.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		frc.delegate = self
		
		do {
			try frc.performFetch()
		} catch {
			print("Error performing FRC fetch: \(error)")
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		updateSnapshot()
	}
	
	func updateSnapshot(animated: Bool = true) {
        var currentSnapshot = NSDiffableDataSourceSnapshot<Int, Channel>()
        currentSnapshot.appendSections([0])
		currentSnapshot.appendItems(frc.fetchedObjects ?? [], toSection: 0)
		diffableDataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
	
	//MARK: UITableView Delegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedChannel = frc.fetchedObjects![indexPath.row]
		let vc = UIStoryboard.instantiate("ItemListVC", as: ItemListVC.self)
		vc.navigationItem.title = selectedChannel.title
		vc.channel = selectedChannel
		navigationController?.pushViewController(vc, animated: true)
	}
	
	//MARK: Swipe Actions
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard let selectedChannel = frc.fetchedObjects?[indexPath.row] else {
			print("Couldn't find Channel at index path \(indexPath)"); return nil
		}
		
		let context = CoreData.shared.viewContext
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, successHandler) in
			successHandler(true)
			context.delete(selectedChannel)
			try! context.save()
		}
		
		let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
		return swipeActions
	}
	
}

