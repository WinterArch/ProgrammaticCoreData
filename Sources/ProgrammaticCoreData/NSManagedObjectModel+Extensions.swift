//  Created by Axel Ancona Esselmann on 2/24/24.
//

import CoreData

public extension NSManagedObjectModel {

    convenience init(_ entities: [any SelfDescribingCoreDataEntity.Type]) {
        self.init()
        let descriptions = entities.map { $0.entityDescription }
        RelationshipRegistry.shared.resolveRelationships(using: entities)
        self.entities = descriptions
    }

    convenience init(_ entities: any SelfDescribingCoreDataEntity.Type...) {
        self.init(entities)
    }

    @discardableResult
    func append(_ entities: [NSEntityDescription]) -> Self {
        self.entities += entities
        return self
    }

    func createContainer(
        name: String,
        location: NSPersistentContainer.Location
    ) async throws -> NSPersistentContainer {
        try await NSPersistentContainer.create(
            name: name,
            model: self,
            location: location
        )
    }

    func createContainerSync(
        name: String? = nil,
        location: NSPersistentContainer.Location
    ) throws -> NSPersistentContainer {
        try NSPersistentContainer.createSync(
            name: prefixName(name),
            model: self,
            location: location
        )
    }
    
    func createCloudContainer(
        name: String,
        cloudContainerIdentifier: String,
        options: CloudOptions
    ) throws -> NSPersistentContainer {
        try NSPersistentCloudKitContainer(
            name: name,
            managedObjectModel: self,
            cloudContainerIdentifier: cloudContainerIdentifier,
            options: options
        )
    }
    
    func createLocalContainer(name: String? = nil, path: URL) -> NSPersistentContainer {
        NSPersistentContainer(name: prefixName(name), managedObjectModel: self, path: path)
    }

    func createLocalContainer(name: String? = nil, subdirectory: String?) throws -> NSPersistentContainer {
        try NSPersistentContainer(name: prefixName(name), managedObjectModel: self, subdirecotry: subdirectory)
    }

    func createInMemoryContainer(name: String) throws -> NSPersistentContainer {
        let container = NSPersistentContainer(name: name, managedObjectModel: self)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        return container
    }

    /// Be lazy to type names, provide a basically unique prefix for naming.
    func prefixName(_ name: String?) -> String {
        if let name = name { name } else {
            Self.prefix + String(describing: Self.self)
        }
    }
    
    private static let prefix: String = "ProgrammaticCoreData."
}
