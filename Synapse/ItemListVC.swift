import UIKit
import CoreData

class ItemListVC: UITableViewController, NSFetchedResultsControllerDelegate {
	
	//MARK: Properties
	public var channel: Channel!
	
	//MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		configureFetchedResultsController()
		configureRefreshControl()
		updateSnapshot(animated: false)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	//MARK: Refresh Control
	func configureRefreshControl() {
		tableView.refreshControl = UIRefreshControl()
		tableView.refreshControl?.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
	}
	
	@objc private func refreshPulled() {
		FeedReader.getNewItems(for: channel) {
			DispatchQueue.main.async {
				self.tableView.refreshControl?.endRefreshing()
			}
		}
	}
	
	//MARK: UITableView Data Source
	private lazy var diffableDataSource: UXDiffableDataSource<Int, Item> = {
		UXDiffableDataSource<Int, Item>(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
			let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
			cell.textLabel?.text = item.title
			return cell
		}
	}()
	
	private var frc: NSFetchedResultsController<Item>!
	
	func configureFetchedResultsController() {
		let fetch = Item.fetchRequest() as NSFetchRequest<Item>
		fetch.predicate = NSPredicate(format: "channel = %@", channel)
		fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Item.pubDate, ascending: false)]
		frc = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: CoreData.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		frc.delegate = self
		
		do {
			try frc.performFetch()
		} catch {
			print("Error performing FRC fetch: \(error)")
		}
	}
	
	func updateSnapshot(animated: Bool = true) {
        var currentSnapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        currentSnapshot.appendSections([0])
		currentSnapshot.appendItems(frc.fetchedObjects ?? [], toSection: 0)
		diffableDataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
	
	//MARK: NSFetchedResultsController Delegate
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		updateSnapshot()
	}
	
	//MARK: UITableView Delegate
	public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let selectedItem = frc.fetchedObjects?[indexPath.row] else {
			print("Couldn't find item at index: \(indexPath.row)"); return
		}
		let vc = UIStoryboard.instantiate("ItemVC", as: ItemVC.self)
		vc.item = selectedItem
		vc.navigationItem.title = selectedItem.title
		navigationController?.pushViewController(vc, animated: true)
	}
	
	//MARK: Swipe Actions
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard let selectedItem = frc.fetchedObjects?[indexPath.row] else {
			print("Couldn't find Channel at index path \(indexPath)"); return nil
		}
		
		let context = CoreData.shared.viewContext
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, successHandler) in
			successHandler(true)
			context.delete(selectedItem)
			try! context.save()
		}
		
		let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
		return swipeActions
	}
}
