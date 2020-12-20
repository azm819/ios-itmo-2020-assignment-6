import Combine
import SwiftUI

class TodoListViewModel: ObservableObject {
    @Published private(set) var tasks = [Task]()
    @Published var name = "" {
        didSet {
            addTaskIsEnabled = !name.isEmpty
        }
    }
    @Published var addTaskIsEnabled: Bool = false

    private let todoStorage: TodoStorage
    private var cancellables = [AnyCancellable]()
    private var cancellable: AnyCancellable?

    init() {
        self.todoStorage = TodoStorage.shared
        todoStorage.fetchTasks()
            .map { $0 }
            .receive(on: DispatchQueue.main)
            .sink { error in
                print(error)
        }
        receiveValue: { [weak self] tasks in
            self?.tasks = tasks
            self?.sortTasks()
        }
            .store(in: &cancellables)
    }

    private func sortTasks() {
        cancellable?.cancel()
        withAnimation {
            tasks.sort(by: { !$0.done && $1.done ||
                    ($0.done == $1.done && $0.priority > $1.priority) ||
                    ($0.done == $1.done && $0.priority == $1.priority && $0.name ?? "" < $1.name ?? "")
            })
        }
    }

    private func updateTask(withId id: UUID, priority: Int16?, done: Bool?) {
        guard let task = tasks.filter({ $0.id == id }).first else {
            return
        }
        if let priority = priority {
            task.priority = priority
        }
        if let done = done {
            task.done = done
        }
        sortTasks()
    }

    func addTask() {
        defer {
            name = ""
        }
        cancellable = todoStorage.addTask(withName: name)
            .sink(receiveValue: { [weak self] task in
                guard let task = task else {
                    return
                }
                self?.tasks.append(task)
                self?.sortTasks()
            })
    }

    func changeCompleteness(taskId id: UUID) {
        cancellable = todoStorage.changeCompleteness(taskId: id)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("Completeness is changed")
                }
            }, receiveValue: { [weak self] done in
                self?.updateTask(withId: id, priority: nil, done: done)
            })
    }

    func changePriority(taskId id: UUID, increase: Bool) {
        cancellable = todoStorage.changePriority(taskId: id, increase: increase)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("Priority is changed")
                }
            }, receiveValue: { [weak self] priority in
                self?.updateTask(withId: id, priority: priority, done: nil)
            })
    }
}
