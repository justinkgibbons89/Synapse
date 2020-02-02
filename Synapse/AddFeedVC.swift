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
			let path = Path.normalized(for: query)
			FeedReader.subscribe(to: path)
		}
		searchBar.resignFirstResponder()
		navigationController?.popViewController(animated: true)
	}
	
	/// Dismisses keyboard when results are scrolled.
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		searchBar.resignFirstResponder()
	}
}
