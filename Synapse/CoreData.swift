import CoreData

class CoreData {
	
	//MARK: Shared Instance
	static var shared = CoreData()
	
	/// The default context for managed objects in the UI.
	var viewContext: NSManagedObjectContext {
		persistentContainer.viewContext
	}
	
	/// A context for editing, caching or other discarable changes. Changes aren't committed to the persistent store until it's parent, `viewcontext` also saved.
	public func disposableContext() -> NSManagedObjectContext {
		let newContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		newContext.parent = viewContext
		return newContext
	}
	
	
	//MARK: Methods
	
	/// Deletes all entities for specified type.
	func deleteAllForEntity<T: NSManagedObject>(type: T.Type) {
		let context = Self.shared.viewContext
		let fetch = T.fetchRequest() as! NSFetchRequest<T>
		fetch.predicate = nil
		fetch.sortDescriptors = []
		let deleteRequest = NSBatchDeleteRequest(
			fetchRequest: fetch as! NSFetchRequest<NSFetchRequestResult>
		)
		
		do {
			try context.execute(deleteRequest)
			try context.save()
		} catch {
			print("Error deleting managed objects: \(error)")
		}
	}
	
	//MARK: Core Support
	lazy var persistentContainer: NSPersistentContainer = {
	    let container = NSPersistentContainer(name: "Synapse")
		
	    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
	        if let error = error as NSError? {
	            fatalError("Unresolved error \(error), \(error.userInfo)")
	        }
	    })
	    return container
	}()

	// MARK: - Core Data Saving support
	func saveContext () {
	    let context = persistentContainer.viewContext
	    if context.hasChanges {
	        do {
	            try context.save()
	        } catch {
	            let nserror = error as NSError
	            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
	        }
	    }
	}
}
