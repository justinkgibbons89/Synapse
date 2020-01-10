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
		setupFRC()
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
	
	func setupFRC() {
		let fetch = Channel.fetchRequest() as NSFetchRequest<Channel>
		fetch.predicate = nil
		fetch.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
		frc = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: CoreData.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
		frc.delegate = self
		
		do {
			try frc.performFetch()
		} catch {
			print("Error performing FRC fetch: \(error)")
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateSnapshot()
		//FeedReader.subscribe(to: "https://theamericansun.com/rss")
		//FeedReader.subscribe(to: "https://slatestarcodex.com/feed")
		/*
		FeedReader.xml(for: "https://slatestarcodex.com/feed") { (xml) in
			let title = xml["rss"]["channel"]["title"].element?.text
			print(title as Any)
			let url = xml["rss"]["channel"]["atom:link"].element?.attribute(by: "href")?.text
			print(url as Any)
			
			print(" ")
			let atom = xml["rss"]["channel"]["atom:link"].element
			print("atom elem: \(atom as Any)")
			print("atom name: \(atom?.name as Any)")
			print("atom attribs: \(atom?.allAttributes as Any)")
			print(" ")
		}*/
		
		FeedReader.xml(for: "https://theamericansun.com/rss") { (xml) in
			let title = xml["rss"]["channel"]["title"].element?.text
			print(title as Any)
			let url = xml["rss"]["channel"]["atom:link"].element?.attribute(by: "href")?.text
			print(url as Any)
			
			print(" ")
			let atom = xml["rss"]["channel"]["atom:link"].element
			print("atom elem: \(atom as Any)")
			print("atom name: \(atom?.name as Any)")
			print("atom attribs: \(atom?.allAttributes as Any)")
			
			for xmlChild in xml["rss"]["channel"].children[0...5] {
				print(xmlChild)
			}
			
			let result = try? xml["rss"]["channel"].byKey("atom:link")
			print("R: \(result as Any)")
			print(result?.element?.attribute(by: "href")?.text as Any)
			print(" ")
			
			let hmm = xml["rss"]["channel"]["atom:link"].filterAll { (element, index) -> Bool in
				if let attribute = element.attribute(by: "rel") {
					return attribute.text == "self"
				} else {
					print("no rel attribute")
					return false
				}
			}
			print("hmm: \(hmm.element?.attribute(by: "href")?.text)")
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
		
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, successHandler) in
			successHandler(true)
			CoreData.shared.mainContext.delete(selectedChannel)
		}
		
		let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
		return swipeActions
	}
	
}

