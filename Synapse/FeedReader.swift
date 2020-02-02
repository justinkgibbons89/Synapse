import Foundation
import SWXMLHash
import CoreData

/// FeedReader provides the interface between XML data and Channel models. It maps XML elements to Channel attributes.
/// It's primarily used with `saveChannelWithItems(:)`
class FeedReader {
	
	//MARK: Initializer
	/// `data` should be XML data. `context` defaults to the standard UI context.
	internal init(data: Data, context: NSManagedObjectContext = CoreData.shared.viewContext) {
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
	
	/// The channel is cached so that the context isn't polluted with duplicate `Channel` objects.
	private lazy var cachedChannel: Channel = {
		let channel = Channel(context: context)
		channel.title = channelElement["title"].element?.text
		channel.link = channelElement["link"].element?.text
		channel.desc = channelElement["description"].element?.text
		channel.url = atom()
		channel.language = channelElement["language"].element?.text
		channel.subscribeDate = Date()
		channel.lastUpdate = Date()
		return channel
	}()

	//MARK: Methods
	@discardableResult
	/// Exposes the private `cachedChannel` and makes it discardable.
	/// (The result is frequently not needed because the `Channel` is inserted into a Core Data context upon initialization.)
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
	
	@discardableResult
	public func items(after limitDate: Date) -> [Item] {
		var results: [Item] = []
		for itemElement in itemElements {
			let pubDate = try? DateManager.parse(itemElement["pubDate"].element?.text ?? "")
			if pubDate! > limitDate {
				let item = self.item(from: itemElement)
				results.append(item)
			}
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
		return item
	}
	
	/// Establishes an inverse relationship in Core Data between a Channel and its items.
	private func attach(channel: Channel, to items: [Item]) {
		for item in items {
			item.channel = channel
		}
	}
	
	/// Builds a new channel with attached items and saves the associated context.
	public func saveNewChannelWithItems() {
		attach(channel: channel(), to: items())
		do {
			try context.save()
		} catch {
			print("Error saving context w/channel and items: \(error)")
		}
	}
}


//MARK: - Convenience Methods

extension FeedReader {
	
	//MARK: Subscribing
	/// Downloads the XML data from the given path and calls `saveNewChannelWithItems(:)`
	public static func subscribe(to channelPath: String, completion: ((Channel) -> Void)? = nil) {
		Networking().download(channelPath) { data in
			let feedReader = FeedReader(data: data)
			feedReader.saveNewChannelWithItems()
			DispatchQueue.main.async {
				completion?(feedReader.channel())
			}
		}
	}
	
	//MARK: Updating
	/// Downloads and saves only the new items for the given `Channel`.
	public static func getNewItems(for channel: Channel, completion: @escaping () -> Void) {
		guard let path = channel.url else {
			print("Couldn't unwrap URL for channel \(channel)"); return
		}
		
		Networking().download(path) { (data) in
			let feedReader = FeedReader(data: data)
			
			if let mostRecent = channel.mostRecentDate {
				let items = feedReader.items(after: mostRecent)
				feedReader.attach(channel: channel, to: items)
			} else {
				let items = feedReader.items()
				feedReader.attach(channel: channel, to: items)
			}
			
			CoreData.shared.saveContext()
			completion()
		}
	}
	
	//MARK: Debugging
	/// For debugging. Prints a description of the channel and items from the given path.
	public static func analyze(_ channelPath: String) {
		Networking().download(channelPath) { (data) in
			let feedReader = FeedReader(data: data)
			let items = feedReader.items()
			for item in items {
				print(item)
			}
		}
	}
	
	/// For debugging. Downloads the data from the given path and passes the XMLIndexer object to the completion block.
	public static func xml(for channelPath: String, completion: @escaping (XMLIndexer) -> Void) {
		Networking().download(channelPath) { (data) in
			let xmlResult = SWXMLHash.parse(data)
			completion(xmlResult)
		}
	}
}

