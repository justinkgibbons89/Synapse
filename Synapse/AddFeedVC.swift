import UIKit

class AddFeedVC: UITableViewController, UISearchBarDelegate {
	
	//MARK: IBOutlet
	@IBOutlet weak var searchBar: UISearchBar!
	
	//MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		searchBar.delegate = self
		searchBar.autocapitalizationType = .none
	}
	
	//MARK: UISearchBar Delegate
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let query = searchBar.text?.lowercased() {
			FeedReader.subscribe(to: query) { channel in
				print("Subscribed to channel: \(channel)")
			}
		}
		searchBar.resignFirstResponder()
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		print("Scrolled!")
		searchBar.resignFirstResponder()
	}
}
