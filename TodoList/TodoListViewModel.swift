import SwiftUI

protocol TaskDelegate {
    func taskIsUpdated()
}

class Task: Identifiable, ObservableObject {
    private static let MAX_PRIORITY = 10
    private static let MIN_PRIORITY = 1

    private let delegate: TaskDelegate

    @Published private(set) var done: Bool = false {
        didSet {
            if oldValue != done {
                delegate.taskIsUpdated()
            }
        }
    }
    @Published private(set) var priority = Task.MIN_PRIORITY {
        didSet {
            if oldValue != priority {
                delegate.taskIsUpdated()
            }
        }
    }

    var id = UUID()
    var name: String

    init(name: String, delegate: TaskDelegate) {
        self.name = name
        self.delegate = delegate
    }

    func toggle() {
        done.toggle()
    }

    func increasePriority() {
        priority = min(priority + 1, Task.MAX_PRIORITY)
    }

    func decreasePriority() {
        priority = max(priority - 1, Task.MIN_PRIORITY)
    }
}

class TodoListViewModel: ObservableObject {
    @Published private(set) var tasks = [Task]()
    @Published var name = "" {
        didSet {
            addTaskIsEnabled = !name.isEmpty
        }
    }
    @Published var addTaskIsEnabled: Bool = false

    private func sortTasks() {
        withAnimation {
            tasks.sort(by: { !$0.done && $1.done ||
                    ($0.done == $1.done && $0.priority > $1.priority) ||
                    ($0.done == $1.done && $0.priority == $1.priority && $0.name < $1.name)
            })
        }
    }

    func addTask() {
        tasks.append(Task(name: name, delegate: self))
        sortTasks()
        name = ""
    }
}

extension TodoListViewModel: TaskDelegate {
    func taskIsUpdated() {
        sortTasks()
    }
}
