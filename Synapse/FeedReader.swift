import Foundation
import SWXMLHash
import CoreData

class FeedReader {
	
	//MARK: Initializer
	internal init(data: Data, context: NSManagedObjectContext = CoreData.shared.mainContext) {
		self.context = context
		self.xml = SWXMLHash.parse(data)
	}
	
	//MARK: Properties
	private let xml: XMLIndexer
	public let context: NSManagedObjectContext
	
	//MARK: Element shorcuts
	private var channelElement: XMLIndexer { xml["rss"]["channel"] }
	private var itemElements: [XMLIndexer] { channelElement["item"].all }
	
	private func atom() -> String? {
		let result = channelElement["atom:link"].filterAll { (element, index) -> Bool in
			if let attribute = element.attribute(by: "rel") {
				return attribute.text == "self"
			} else {
				return false
			}
		}
		return result.element?.attribute(by: "href")?.text
	}
	
	private lazy var cachedChannel: Channel = {
		let channel = Channel(context: context)
		channel.title = channelElement["title"].element?.text
		channel.link = channelElement["link"].element?.text
		channel.desc = channelElement["description"].element?.text
		channel.url = atom()
		channel.language = channelElement["language"].element?.text
		channel.subscribeDate = Date()
		return channel
	}()

	//MARK: Methods
	@discardableResult
	public func channel() -> Channel {
		cachedChannel
	}
	
	@discardableResult
	public func items() -> [Item] {
		var results: [Item] = []
		for itemElement in itemElements {
			let item = self.item(from: itemElement)
			results.append(item)
		}
		return results
	}
	
	private func item(from indexer: XMLIndexer) -> Item {
		let item = Item(context: context)
		item.title = indexer["title"].element?.text
		item.desc = indexer["description"].element?.text
		item.link = indexer["link"].element?.text
		item.content = indexer["content:encoded"].element?.text
		item.pubDate = try? DateManager.parse(indexer["pubDate"].element?.text ?? "")
		item.channel = channel()
		return item
	}
	
	public func save() {
		channel()
		items()
		do {
			try context.save()
		} catch {
			print("Error saving context w/channel and items: \(error)")
		}
	}
	
	//MARK: Subscribing
	public static func subscribe(to channelPath: String, completion: ((Channel) -> Void)? = nil) {
		Networking().download(channelPath) { data in
			let feedReader = FeedReader(data: data)
			feedReader.save()
			DispatchQueue.main.async {
				completion?(feedReader.channel())
			}
		}
	}
	
	public static func analyze(_ channelPath: String) {
		Networking().download(channelPath) { (data) in
			let feedReader = FeedReader(data: data)
			let items = feedReader.items()
			for item in items {
				print(item)
			}
		}
	}
	
	public static func xml(for channelPath: String, completion: @escaping (XMLIndexer) -> Void) {
		Networking().download(channelPath) { (data) in
			let xmlResult = SWXMLHash.parse(data)
			completion(xmlResult)
		}
	}
}
