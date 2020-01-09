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
	
	//MARK: Initializer
	internal init(data: Data) {
		self.xml = SWXMLHash.parse(data)
	}
	
	//MARK: Properties
	let xml: XMLIndexer
	
	//MARK: Element shorcuts
	var channelElement: XMLIndexer { xml["rss"]["channel"] }
	var itemElements: [XMLIndexer] { channelElement["item"].all }
	
	//MARK: Methods
	func channel(from data: Data) -> Channel {
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
		for itemElement in itemElements {
			let item = self.item(from: itemElement)
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

