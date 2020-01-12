import UIKit

class ItemVC: UIViewController {
	
	//MARK: Properties
	public var item: Item!
	
	//MARK: IBOutlets
	@IBOutlet weak var textView: UITextView!
	
	//MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		textView.text = item.content
	}
}
