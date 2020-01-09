import UIKit
import SWXMLHash
import CoreData

class FeedVC: UITableViewController {

	//MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		print("Feed vc loaded.")
		download() { xml in
			let title = xml["rss"]["channel"]["title"].element?.text
			print(title as Any)
		}
	}
	
	func download(_ completion: @escaping (XMLIndexer) -> Void) {
		print("Trying to download...")
		let url = URL(string: "https://slatestarcodex.com/feed/")!
		let session = URLSession.shared
		let task = session.dataTask(with: url) { (data, response, error) in
			if let error = error { print("Error: \(error)") }
			
			if let data = data {
				let string = String(data: data, encoding: .utf8)!
				print("\(string) download complete")
				let xml = SWXMLHash.parse(data)
				completion(xml)
			}
		}
		
		task.resume()
	}
}

class FeedReader {
	
	func read(from data: Data) {
		let xml = SWXMLHash.parse(data)
		let root = xml["rss"]

		
	}
}

