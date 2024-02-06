//
//  DataController.swift
//  Journal
//
//  Created by Brandon Johns on 2/4/24.
//

import CoreData


class DataController: ObservableObject {
    ///Contains Core Data infomation and syncs it will iCloud
    let container: NSPersistentCloudKitContainer
    
    /// Default selection for filtering options 
    @Published var selectedFilter: Filter? = Filter.all
    
    /// Issue selected from the list in ContentView 
    @Published var selectedIssue: Issue?
    
    
    /// Pre-made data controller for previewing data in SwiftUI views
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    
    /// Writes data in memory
    /// - Parameter inMemory: true: creates the memory in memory
    ///                       false: writes the memory  on disk
    init(inMemory: Bool = false ) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        /// Modify the containers first url to write to nowhere
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        /// Automatically updates changes to the view
        ///  so the user does not have to close the app to get updates
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        
        ///Combines changes local and remote changess
        /// This merging perfers local in memory changes over remote changes
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        ///Notifiy after any write to  persistent store
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        /// Call remoteStoreChange anytime a change has happened
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator, queue: .main, using: remoteStoreChanged)
        
        
        ///Loads the database onto disk or creates it if it doesnt exist
        container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    /// Tells CoreData to watch for any updates to the persistent storage
    /// and send a notification to the UIs to update because there has been change
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
    /// Creates 5 tags and 10 issues for each tag
    func createSampleData() {
        /// viewContext holds all active objects in memory as we wrote with them
        /// only writes them to storage when asked
        let viewContext = container.viewContext
        
        /// In order to create Tag and Issue instances
        /// we must tell core data what context (containder.viewContext)
        /// Tags and Issues also have default data
        for tagCounter in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(tagCounter)"
            
            for issueCounter in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(tagCounter)-\(issueCounter)"
                issue.content = "Description goes here"
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }
        /// Tells Core Data to save and write these all as new objects
        /// in this example dev/null means it wont last long
        try? viewContext.save()
    }
    
    
    /// Saves changes to the data if another part of the app makes changes
    /// this helps save extra from so core data is not constantly saving
    /// the container will declare if there has been changes or not
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    
    /// Deletes specific Tag or Issue from the viewContext
    /// This is passed directly into viewContexts delete() method
    /// Core Data and (Issue and Tag Classes genereated automatically) inherit fro m NSManagedObject
    /// - Parameter object: Issue  or Tag that is the referenced to viewContext object to be deleted
    func delete(_ object: NSManagedObject) {
        ///objectWillChange.send() == Telling container whats about to be deleted
        objectWillChange.send()
        ///Actual deleting of the object from the container
        container.viewContext.delete(object)
        save()
    }

    
    /// BatchDelete used for testing to delete all data. This is called with CreateSampleData()
    /// This uses a fetchRequest() on the Issue Class created by xCode
    /// Deletes everythig on the ViewContext
    /// - Parameter fetchRequest: Looks for Issues  without specifying a type of filter
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
            /// the fetchRequest  item to be deleted
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        /// send back the object IDs of what was deleted
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        ///Execute the request and send back the BatchDeleteResult
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            /// Changes  creates a dictionary  of NSDeletedObjectKey as the keys
            ///  delete.result (.resultType) is what was deleted  which is a (NSMangedObjectID)
            ///  or an empty array if something fails
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            
            /// Updates the viewContext by merging changes and the persistant store
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
    
    
    /// Find and delete all Issues and Tags
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)

        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)

        save()
    }
    
   

}




/*
 Core Data
    will automatically creates classes
    based on the attributes we have created
    in this case them means issue and tags
 
 Core Data stack will create and save these automatically
 
 let viewContext = container.viewContext
    holds all the active objects in memory
 
 .save()
    saves data for as long as the app is on the phone
    and it will sync it with icloud
 
 */
