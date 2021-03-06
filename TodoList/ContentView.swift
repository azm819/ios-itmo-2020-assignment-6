import SwiftUI

struct TodoCellView: View {
    @StateObject var task: Task
    let viewModel: TodoListViewModel

    var body: some View {
        guard let taskId = task.id else {
            fatalError("Task has no ID")
        }
        return HStack(alignment: .center) {
            Button(action: { viewModel.changeCompleteness(taskId: taskId) }) {
                HStack(alignment: .top) {
                    Image(systemName: task.done ? "checkmark.circle.fill" : "circle").colorScheme(.light)
                    let color: Color = task.done ? .gray : .black
                    Text(task.name ?? "Undefined")
                        .foregroundColor(color)
                        .strikethrough(task.done, color: .green)
                    Text(task.priority.description)
                        .foregroundColor(color)
                }
            }.buttonStyle(BorderlessButtonStyle())
            Button(action: { viewModel.changePriority(taskId: taskId, increase: true) }) {
                Image(systemName: "arrowtriangle.up.fill")
            }.buttonStyle(BorderlessButtonStyle())
            Button(action: { viewModel.changePriority(taskId: taskId, increase: false) }) {
                Image(systemName: "arrowtriangle.down.fill")
            }.buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct TodoListView: View {
    @StateObject var viewModel = TodoListViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                TextField("Task name", text: $viewModel.name, onEditingChanged: { _ in }, onCommit: {
                    viewModel.addTask()
                })
                Button(action: { viewModel.addTask() }) {
                    Image(systemName: "plus.circle")
                }.disabled(!viewModel.addTaskIsEnabled)
            }
            List(viewModel.tasks) { task in
                TodoCellView(task: task, viewModel: viewModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}
