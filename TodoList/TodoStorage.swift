//
//  TodoStorage.swift
//  TodoList
//
//  Created by Azamat on 20.12.2020.
//

import Foundation
import CoreData


class TodoStorage {
    private static let maxPriority: Decimal = 10
    private static let minPriority: Decimal = 0

    static private(set) var shared: TodoStorage = {
        let instance = TodoStorage()
        return instance
    }()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (descriprion, error) in
            if let error = error {
                print(error)
            }
            print(descriprion)
        })
    }

    func fetchTasks() -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.done, ascending: true),
                                   NSSortDescriptor(keyPath: \Task.priority, ascending: false),
                                   NSSortDescriptor(keyPath: \Task.name, ascending: true)]
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print(error)
            return []
        }
    }

    private func fetchTask(byId id: NSUUID) -> NSManagedObject? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        do {
            let tasks = try container.viewContext.fetch(fetchRequest)
            let task = tasks.first as? NSManagedObject
            return task
        } catch {
            print(error)
            return nil
        }
    }

    func addTask(withName name: String) -> Task? {
        let task = Task(context: container.viewContext)
        task.name = name
        task.id = UUID()

        do {
            try container.viewContext.save()
            return task
        } catch {
            print(error)
            return nil
        }
    }

    func changeCompleteness(taskId id: NSUUID, isDone done: Bool) {
        fetchTask(byId: id)?.setValue(done, forKey: "done")
    }

    func increasePriority(taskId id: NSUUID) {
        guard let object = fetchTask(byId: id), let task = object as? Task, let oldPriority = task.priority as Decimal? else {
            return
        }
        object.setValue(min(TodoStorage.maxPriority, oldPriority + 1), forKey: "priority")
    }

    func decreasePriority(taskId id: NSUUID) {
        guard let object = fetchTask(byId: id), let task = object as? Task, let oldPriority = task.priority as Decimal? else {
            return
        }
        object.setValue(max(TodoStorage.minPriority, oldPriority - 1), forKey: "priority")
    }
}
