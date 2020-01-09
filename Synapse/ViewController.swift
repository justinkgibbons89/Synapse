import UIKit
import SWXMLHash
import CoreData

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
			let channel = FeedReader().channel(from: data)
			print("Channel: \(channel)")
			let items = FeedReader().items(from: data)
			for item in items {
				print(item.title!)
			}
		}
	}
	
	
}

class Networking {
	
	func download(_ path: String, _ completion: @escaping (Data) -> Void) {
		guard let url = URL(string: path) else {
			print("Couldn't construct URL from path: \(path)"); return
		}
		let session = URLSession.shared
		let task = session.dataTask(with: url) { (data, response, error) in
			if let error = error { print("Error: \(error)") }
			if let data = data { completion(data) }
		}
		task.resume()
	}
	
}

class FeedReader {
	
	func channel(from data: Data) -> Channel {
		let xml = SWXMLHash.parse(data)
		let channelElement = xml["rss"]["channel"]

		let channel = Channel(context: CoreData.shared.mainContext)
		channel.title = channelElement["title"].element?.text
		channel.link = channelElement["link"].element?.text
		channel.desc = channelElement["description"].element?.text
		channel.url = channelElement["atom:link"].element?.attribute(by: "href")?.text
		channel.language = channelElement["language"].element?.text
		
		return channel
	}
	
	func items(from data: Data) -> [Item] {
		var results: [Item] = []
		let xml = SWXMLHash.parse(data)
		let channelElement = xml["rss"]["channel"]
		let items = channelElement["item"].all
		for xmlItem in items {
			let item = self.item(from: xmlItem)
			results.append(item)
		}
		return results
	}
	
	func item(from xml: XMLIndexer) -> Item {
		let item = Item(context: CoreData.shared.mainContext)
		item.title = xml["title"].element?.text
		item.desc = xml["description"].element?.text
		item.link = xml["link"].element?.text
		item.content = xml["content:encoded"].element?.text
		return item
	}
}

