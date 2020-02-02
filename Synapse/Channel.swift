import Foundation

extension Channel {
	
	/// The data of the most recently published item attached to the channel. From the RSS `pubDate`property.
	var mostRecentDate: Date? {
		let itemSet = self.items as! Set<Item>
		let sorted = itemSet.sorted { (a, b) -> Bool in
			a.pubDate! > b.pubDate!
		}
		return sorted.first?.pubDate
	}
}
