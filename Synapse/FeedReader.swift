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
	
	private lazy var cachedChannel: Channel = {
		let channel = Channel(context: context)
		channel.title = channelElement["title"].element?.text
		channel.link = channelElement["link"].element?.text
		channel.desc = channelElement["description"].element?.text
		channel.url = channelElement["atom:link"].element?.attribute(by: "href")?.text
		channel.language = channelElement["language"].element?.text
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
		item.channel = channel()
		print("built item: \(item)")
		return item
	}
	
	public func save() {
		channel()
		items()
		try! context.save()
	}
	
	//MARK: Subscribing
	public static func subscribe(to channelPath: String) {
		Networking().download(channelPath) { data in
			let feedReader = FeedReader(data: data)
			feedReader.save()
		}
	}
	
	public static func analyze(_ channelPath: String) {
		print("Analyzing...")
		Networking().download(channelPath) { (data) in
			let feedReader = FeedReader(data: data)
			let items = feedReader.items()
		}
	}
}
