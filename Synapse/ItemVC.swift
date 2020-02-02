import UIKit
import Combine

class ItemVC: UIViewController {
	
	//MARK: Properties
	public var item: Item!
	private var cancellables: [AnyCancellable] = []
	
	//MARK: IBActions
	@IBAction func bookmarkButtonTapped(_ sender: Any) {
		item.isBookmarked.toggle()
		CoreData.shared.saveContext()
	}
	
	//MARK: IBOutlets
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var bookmarkButton: UIBarButtonItem!
	
	//MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		textView.text = item.content
		
		// Attach view to view model
		item.publisher(for: \.isBookmarked)
			.map(mapBookmarkToImage)
			.sink { self.bookmarkButton.image = $0 }
			.store(in: &cancellables)
	}
	
	//MARK: ViewModel Mapping
	private let mapBookmarkToImage: (Bool) -> UIImage = { isFavorite in
		if isFavorite {
			return UIImage(systemName: "bookmark.fill")!
		} else {
			return UIImage(systemName: "bookmark")!
		}
	}
}
