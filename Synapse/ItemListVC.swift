import UIKit
import CoreData

class ItemListVC: UITableViewController, NSFetchedResultsControllerDelegate {
	
	//MARK: Properties
	public var channel: Channel!
	
	//MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		setupFRC()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		updateSnapshot()
	}
	
	//MARK: UITableView Diffable Data Source
	private lazy var diffableDataSource: UXDiffableDataSource<Int, Item> = {
		UXDiffableDataSource<Int, Item>(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
			let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
			cell.textLabel?.text = item.title
			return cell
		}
	}()
	
	//MARK: Fetched Results Controller
	private var frc: NSFetchedResultsController<Item>!
	
	func setupFRC() {
		let fetch = Item.fetchRequest() as NSFetchRequest<Item>
		fetch.predicate = NSPredicate(format: "channel = %@", channel)
		fetch.sortDescriptors = [NSSortDescriptor(key: "pubDate", ascending: false)]
		frc = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: CoreData.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
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
        var currentSnapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        currentSnapshot.appendSections([0])
		currentSnapshot.appendItems(frc.fetchedObjects ?? [], toSection: 0)
		diffableDataSource.apply(currentSnapshot, animatingDifferences: animated)
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
}
