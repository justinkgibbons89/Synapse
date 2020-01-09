import UIKit

class FeedVC: UITableViewController {

	//MARK: IBActions
	@IBAction func addButtonTapped(_ sender: Any) {
		let vc = UIStoryboard.instantiate("AddFeedVC", as: AddFeedVC.self)
		navigationController?.pushViewController(vc, animated: true)
	}
	
	//MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		Networking().download("https://slatestarcodex.com/feed/") { data in
			let feedReader = FeedReader(data: data)
			let channel = feedReader.channel(from: data)
			print("Channel: \(channel)")
			let items = feedReader.items(from: data)
			for item in items {
				print(item.title!)
			}
		}
	}
	
	
}

