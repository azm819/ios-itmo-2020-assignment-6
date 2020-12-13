import SwiftUI

struct TodoListView: View {
    @StateObject var viewModel = TodoListViewModel()
    
    var body: some View {
        
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}

Identifiable
