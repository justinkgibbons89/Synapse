import UIKit
import CoreData

class BookmarksVC: UITableViewController, NSFetchedResultsControllerDelegate {
	
	//MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//Set up data source
		tableView.dataSource = diffableDataSource
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		tableView.delegate = self
		
		//Configure fetch and diffable snapshot
		fetchedResultsController.delegate = self //enables live updates
		updateSnapshot(animated: false) //don't animate on first update (it looks weird)
	}
	
	//MARK: UITableView Data Source
	private lazy var diffableDataSource =
		UITableViewDiffableDataSource<Int, Item>(tableView: tableView) {
			(tableView, indexPath, item) -> UITableViewCell? in
			let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell()
			cell.textLabel?.text = item.title
			return cell
		}
	
	private func updateSnapshot(animated: Bool = true) {
		var snap = NSDiffableDataSourceSnapshot<Int, Item>()
		snap.appendSections([0])
		snap.appendItems(fetchedResultsController.fetchedObjects ?? [])
		diffableDataSource.apply(snap, animatingDifferences: animated)
	}
	
	private var fetchedResultsController: NSFetchedResultsController<Item> = {
		let fetch = Item.fetchRequest() as NSFetchRequest<Item>
		fetch.predicate = NSPredicate(format: "isBookmarked = %@", NSNumber(booleanLiteral: true))
		fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Item.pubDate, ascending: true)]
		let frc = NSFetchedResultsController(
			fetchRequest: fetch,
			managedObjectContext: CoreData.shared.viewContext,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
		try! frc.performFetch()
		return frc
	}()
	
	//MARK: NSFetchedResultsController Delegate
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		updateSnapshot()
	}
	
	//MARK: UITableView Delegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let selectedItem = fetchedResultsController.fetchedObjects?[indexPath.row] else {
			print("Couldn't find item at index path \(indexPath)"); return
		}
		let vc = UIStoryboard.instantiate("ItemVC", as: ItemVC.self)
		vc.item = selectedItem
		vc.navigationItem.title = selectedItem.title
		navigationController?.pushViewController(vc, animated: true)
	}
}
