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
			feedReader.save()
			/*
			let channel = feedReader.channel()
			print("Channel: \(channel)")
			let items = feedReader.items()
			for item in items {
				print(item.title!)
			}*/
		}
	}
	
	
}

