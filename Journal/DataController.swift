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
    
    /// For searching by text
    @Published var filterText = ""
    
    /// For storing active tags
    @Published var filterTokens = [Tag]()
    
    ///New Save Task optional
    ///Wont  return a value but might throw an Error
    private var saveTask: Task<Void, Error>?
    
    
    
    /// Pre-made data controller for previewing data in SwiftUI views
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    
    /// Sort by Tags
    var suggestedFilterTokens: [Tag] {
       
        /// removes the # symbol
        let trimmedFilterText = String(filterText).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()

        if trimmedFilterText.isEmpty == false {
            
            /// Only search if we have some Tag to search for
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }

        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    
    
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
    
    /// Task waits three seconds before calling a save
    func queueSave() {
        saveTask?.cancel()
        
        /// If changes happen within the  three seconds
        /// Then the clock starts over.
        /// @MainActor means it must run on the main thread
        saveTask = Task { @MainActor in
            print("Queuing Save")
            try await Task.sleep(for: .seconds(3))
            save()
            print("Saved!")
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
    
    
    /// All Issues that  are not assigned to this tag
    /// - Parameter issue: not assigned to any tag
    /// - Returns: array of Tags the Issue its missing
    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        
        let allTagsSet = Set(allTags)
        ///Whats in allTagsSet but not in issueTags
        let difference = allTagsSet.symmetricDifference(issue.issueTags)
        
        return difference.sorted()
    }
    
    
    /// Filters Issues so if there is a Tag use if not find issues and sort
    func issuesForSelectedFilter() -> [Issue] {
        /// Filter is the selected filter if not defaults to .all
        let filter = selectedFilter ?? .all
        
        var predicates = [NSPredicate]()
        
        ///Filter issues by  Tag or Date
        if let tag = filter.tag {
            /// Search for the Tag  Predicate  and does this contain this particular Tag
            /// provide those Issues relating to that Tag
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            /// Adding Tag search result to the  predicate array
            predicates.append(tagPredicate)
            
        } else {
            ///Search for the Tag based on the modification date
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            ///Adding the date search result to the predicate array
            predicates.append(datePredicate)
        }
        
        /// Removing white spaces
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

        
        if trimmedFilterText.isEmpty == false {
            
            //Contains[c] case insensitive
            
            /// Issue title search
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            
            /// Issue content
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            
            /// Does the Issue contain either the title or the content
            /// Add the Combined title or content result
            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            
            /// Add combinedPredicate to the  Predicate array
            predicates.append(combinedPredicate)
        }
        
        
        /// Returning All tags
        if filterTokens.isEmpty == false {
            for filterToken in filterTokens {
                let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterToken)
                predicates.append(tokenPredicate)
            }
        }
        
        /// Fetch all issues relating to predicate array
        let request = Issue.fetchRequest()
        
        /// Every Predicate gets added to the predicate array
        /// This creates a single predicate search
        /// So each result is filtered byased on Tag, Date, Title, and Content
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        /// allIssues is now the NSCompoundPredicate search results
        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        
        return allIssues.sorted()
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
 
 
 lazy way loads all issues then just throws them away
 /// Filters Issues so if there is a Tag use if not find issues and sort
 func issuesForSelectedFilter() -> [Issue] {
 /// Filter is the selected filter if not defaults to .all
 let filter = selectedFilter ?? .all
 
 var allIssues: [Issue]
 
 ///Tag attached to filter then filter by Tag first
 if let tag = filter.tag {
 ///Add the Tag issues to the array
 allIssues = tag.issues?.allObjects as? [Issue] ?? []
 
 } else {
 
 /// No Tags then fetch all issues if no issues then an empty array
 let request = Issue.fetchRequest()
 
 ///Requesting Issues based on the modificationDate based on the filter that is currently active
 request.predicate = NSPredicate(
 format: "modificationDate > %@",
 filter.minModificationDate as NSDate
 )
 allIssues = (try? container.viewContext.fetch(request)) ?? []
 }
 let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
 
 if trimmedFilterText.isEmpty == false {
 allIssues = allIssues.filter { $0.issueTitle.localizedCaseInsensitiveContains(filterText) || $0.issueContent.localizedCaseInsensitiveContains(filterText) }
 }
 
 
 return allIssues.sorted()
 }
 
 /// OR approach to returning tags select each one 
 if filterTokens.isEmpty == false {
     let tokenPredicate = NSPredicate(format: "ANY tags IN %@", filterTokens)
     predicates.append(tokenPredicate)
 }
 
 */
