import CoreData

class CoreData {
	
	//MARK: Shared Instance
	static var shared = CoreData()
	
	//MARK: Computed Properties
	var viewContext: NSManagedObjectContext {
		persistentContainer.viewContext
	}
	
	public func disposableContext() -> NSManagedObjectContext {
		let newContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		newContext.parent = viewContext
		return newContext
	}
	
	//MARK: Methods
	func deleteAllForEntity<T: NSManagedObject>(type: T.Type) {
		let context = Self.shared.viewContext
		let fetch = T.fetchRequest() as! NSFetchRequest<T>
		fetch.predicate = nil
		fetch.sortDescriptors = []
		let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch as! NSFetchRequest<NSFetchRequestResult>)
		do {
			try context.execute(deleteRequest)
			try context.save()
		} catch {
			print("Error deleting managed objects: \(error)")
		}
	}
	

	lazy var persistentContainer: NSPersistentContainer = {
	    /*
	     The persistent container for the application. This implementation
	     creates and returns a container, having loaded the store for the
	     application to it. This property is optional since there are legitimate
	     error conditions that could cause the creation of the store to fail.
	    */
	    let container = NSPersistentContainer(name: "Synapse")
	    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
	        if let error = error as NSError? {
	            // Replace this implementation with code to handle the error appropriately.
	            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	             
	            /*
	             Typical reasons for an error here include:
	             * The parent directory does not exist, cannot be created, or disallows writing.
	             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
	             * The device is out of space.
	             * The store could not be migrated to the current model version.
	             Check the error message to determine what the actual problem was.
	             */
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
	            // Replace this implementation with code to handle the error appropriately.
	            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	            let nserror = error as NSError
	            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
	        }
	    }
	}
}
