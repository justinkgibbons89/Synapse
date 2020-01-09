import Foundation

class Networking {
	
	func download(_ path: String, _ completion: @escaping (Data) -> Void) {
		guard let url = URL(string: path) else {
			print("Couldn't construct URL from path: \(path)"); return
		}
		let session = URLSession.shared
		let task = session.dataTask(with: url) { (data, response, error) in
			if let error = error { print("Error: \(error)") }
			if let data = data { completion(data) }
		}
		task.resume()
	}
	
}
