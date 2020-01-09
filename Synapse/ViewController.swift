import UIKit
import SWXMLHash
import CoreData

class FeedVC: UITableViewController {

	//MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		print("Feed vc loaded.")
		Networking().download("https://slatestarcodex.com/feed/") { data in
			let channel = FeedReader().channel(from: data)
			print("Channel: \(channel)")
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

		let channel = Channel(context: CoreData.shared.persistentContainer.viewContext)
		channel.title = channelElement["title"].element?.text
		channel.link = channelElement["link"].element?.text
		channel.desc = channelElement["description"].element?.text
		channel.url = channelElement["atom:link"].element?.attribute(by: "href")?.text
		channel.language = channelElement["language"].element?.text
		
		return channel
	}
}

