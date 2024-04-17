import SwiftUI

struct ContentView: View {
  @State var tree = QuadTree(
    rectangle: CGRect(origin: .zero, size: .init(width: 500, height: 500)),
    minSize: .init(width: 20, height: 20),
    values: [
      .init(x: 40, y: 40),
      .init(x: 300, y: 300),
      .init(x: 200, y: 200)
    ]
  )
  
  var body: some View {
    QuadTreeView(tree: tree)
    .background(.gray)
    .frame(width: 600, height: 600)
    .task {
      tree.animatedMove(element: tree.allVals[0], newLocation: .init(x: 20, y: 400))
      tree.animatedMove(element: tree.allVals[1], newLocation: .init(x: 10, y: 10))
//      withAnimation(.linear(duration: 2)) {
//        tree.move(element: tree.allVals[0], newLocation: .init(x: 20, y: 400))
////        tree.remove(element: tree.allVals[0])
//      }
    }
  }
}

#Preview {
  ContentView()
}
