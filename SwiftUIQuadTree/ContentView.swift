import SwiftUI

struct ContentView: View {
  @State var vm = QuadTreeViewModel(tree: QuadTree(
    rectangle: CGRect(origin: .zero, size: .init(width: 500, height: 500)),
    minSize: .init(width: 20, height: 20),
    values: (0..<100).map { _ in
        .init(x: Int.random(in: (0..<500)), y: Int.random(in: (0..<500)))
    }
  ))
  
  var body: some View {
    QuadTreeView(vm: vm)
    .background(.gray)
    .frame(width: 600, height: 600)
    .task {
      for index in (0..<100) {
        vm.animatedMove(vm.tree.allVals[index], newLocation: .init(x: Int.random(in: (0..<500)), y: Int.random(in: (0..<500))))
      }
    }
//    .drawingGroup()
  }
}

#Preview {
  ContentView()
}
