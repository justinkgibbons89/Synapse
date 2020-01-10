import UIKit

extension UIStoryboard {
    public static func instantiate<T: UIViewController>(_ name: String, as type: T.Type) -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(identifier: name)
        return vc as! T
    }
}

class UXDiffableDataSource<S: Hashable, T: Hashable>: UITableViewDiffableDataSource<S, T> {
    // ...
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // ...
}
