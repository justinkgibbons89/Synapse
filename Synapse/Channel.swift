import Foundation

extension Channel {
	
	var mostRecentDate: Date? {
		let itemSet = self.items as! Set<Item>
		let sorted = itemSet.sorted { (a, b) -> Bool in
			a.pubDate! > b.pubDate!
		}
		return sorted.first?.pubDate
	}
}
