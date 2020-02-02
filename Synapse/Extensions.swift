import UIKit

extension UIStoryboard {
	
	/// Returns a typecast view controller with the given identifier from the main `Bundle`
    public static func instantiate<T: UIViewController>(_ name: String, as type: T.Type) -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(identifier: name)
        return vc as! T
    }
}


/// This adds swipe-to-delete support for `UIDiffableDataSource`
class UXDiffableDataSource<S: Hashable, T: Hashable>: UITableViewDiffableDataSource<S, T> {
    // ...
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // ...
}
