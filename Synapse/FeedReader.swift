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
	private let context: NSManagedObjectContext
	
	//MARK: Element shorcuts
	private var channelElement: XMLIndexer { xml["rss"]["channel"] }
	private var itemElements: [XMLIndexer] { channelElement["item"].all }
	
	//MARK: Methods
	@discardableResult
	public func channel() -> Channel {
		let channel = Channel(context: context)
		channel.title = channelElement["title"].element?.text
		channel.link = channelElement["link"].element?.text
		channel.desc = channelElement["description"].element?.text
		channel.url = channelElement["atom:link"].element?.attribute(by: "href")?.text
		channel.language = channelElement["language"].element?.text
		return channel
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
	
	public func item(from xml: XMLIndexer) -> Item {
		let item = Item(context: context)
		item.title = xml["title"].element?.text
		item.desc = xml["description"].element?.text
		item.link = xml["link"].element?.text
		item.content = xml["content:encoded"].element?.text
		item.channel = channel()
		return item
	}
	
	public func save() {
		channel()
		items()
		try! context.save()
	}
}
