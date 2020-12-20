import SwiftUI

class TodoListViewModel: ObservableObject {
    @Published private(set) var tasks: [Task]
    @Published var name = "" {
        didSet {
            addTaskIsEnabled = !name.isEmpty
        }
    }
    @Published var addTaskIsEnabled: Bool = false
    private let todoStorage: TodoStorage

    init() {
        self.todoStorage = TodoStorage.shared
        self.tasks = todoStorage.fetchTasks()
        sortTasks()
    }

    private func sortTasks() {
//        withAnimation {
//            tasks.sort(by: { !$0.done && $1.done ||
//                    ($0.done == $1.done && $0.priority > $1.priority) ||
//                    ($0.done == $1.done && $0.priority == $1.priority && $0.name ?? "" < $1.name ?? "")
//            })
//        }
    }

    private func updateTasks() {
        tasks = todoStorage.fetchTasks()
        sortTasks()
    }

    func addTask() {
        guard let task = todoStorage.addTask(withName: name) else {
            return
        }
        tasks.append(task)
        print(tasks)
        sortTasks()
        name = ""
    }

    func changeCompleteness(taskId id: NSUUID, isDone done: Bool) {
        todoStorage.changeCompleteness(taskId: id, isDone: done)
        updateTasks()
    }

    func increasePriority(taskId id: NSUUID) {
        todoStorage.increasePriority(taskId: id)
        updateTasks()
    }

    func decreasePriority(taskId id: NSUUID) {
        todoStorage.decreasePriority(taskId: id)
        updateTasks()
    }
}
