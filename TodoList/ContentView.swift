import SwiftUI

struct TodoCellView: View {
    @StateObject var task: Task

    var body: some View {
        HStack(alignment: .center) {
            Button(action: { task.toggle() }) {
                HStack(alignment: .top) {
                    Image(systemName: task.done ? "checkmark.circle.fill" : "circle").colorScheme(.light)
                    let color: Color = task.done ? .gray : .black
                    Text(task.name)
                        .foregroundColor(color)
                        .strikethrough(task.done, color: .green)
                    Text(String(task.priority))
                        .foregroundColor(color)
                }
            }.buttonStyle(BorderlessButtonStyle())
            Button(action: { task.increasePriority() }) {
                Image(systemName: "arrowtriangle.up.fill")
            }.buttonStyle(BorderlessButtonStyle())
            Button(action: { task.decreasePriority() }) {
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
                TodoCellView(task: task)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}
