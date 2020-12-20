//
//  TodoStorage.swift
//  TodoList
//
//  Created by Azamat on 20.12.2020.
//

import Combine
import CoreData
import Foundation

class TodoStorage {
    private static let maxPriority: Int16 = 10
    private static let minPriority: Int16 = 1

    static private(set) var shared: TodoStorage = {
        let instance = TodoStorage()
        return instance
    }()

    @Published private var container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (descriprion, error) in
            if let error = error {
                print(error)
            }
            print(descriprion)
        })
    }

    func fetchTasks() -> CDPublisher<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.done, ascending: true),
                                   NSSortDescriptor(keyPath: \Task.priority, ascending: false),
                                   NSSortDescriptor(keyPath: \Task.name, ascending: true)]
        return CDPublisher(request: request, context: container.viewContext)
    }

    private func fetchTask(byId id: UUID) -> CDPublisher<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return CDPublisher(request: request, context: container.viewContext)
    }

    func addTask(withName name: String) -> AnyPublisher<Task?, Never> {
        $container
            .map {
                let task = Task(context: $0.viewContext)
                task.name = name
                task.id = UUID()
                do {
                    try $0.viewContext.save()
                    return task
                } catch {
                    print(error)
                    return nil
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func changeCompleteness(taskId id: UUID) -> AnyPublisher<Bool?, Error> {
        return fetchTask(byId: id)
            .receive(on: DispatchQueue.main)
            .map {
                guard let task = $0.first else {
                    return nil
                }
                let done = !task.done
                task.setValue(done, forKey: "done")
                return done
            }
            .eraseToAnyPublisher()
    }

    func changePriority(taskId id: UUID, increase: Bool) -> AnyPublisher<Int16?, Error> {
        return fetchTask(byId: id)
            .receive(on: DispatchQueue.main)
            .map {
                guard let task = $0.first else {
                    return nil
                }
                let newPriority = increase ? min(TodoStorage.maxPriority, task.priority + 1) : max(TodoStorage.minPriority, task.priority - 1)
                task.setValue(newPriority, forKey: "priority")
                return newPriority
            }
            .eraseToAnyPublisher()
    }
}
