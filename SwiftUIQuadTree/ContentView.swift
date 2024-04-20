import SwiftUI

struct ContentView: View {
  static let pointCount = 100
  let vm = {
    let tree = QuadTreeViewModel(tree: QuadTree(
      rectangle: CGRect(origin: .zero, size: .init(width: 500, height: 500)),
      minSize: .init(width: 20, height: 20),
      values: (0..<ContentView.pointCount).map { _ in
        .random()
      }
    ))
    print("FINISH INIT")
    return tree
  }()
  
  var body: some View {
    QuadTreeView(vm: vm)
    .background(.gray)
    .frame(width: 600, height: 600)
    .task {
      for index in (0..<ContentView.pointCount) {
        vm.animatedMove(vm.tree.allVals[index], newLocation: .random())
      }
    }
//    .drawingGroup()
  }
}

#Preview {
  ContentView()
}

extension CGPoint {
  static func random() -> CGPoint {
    .init(x: Int.random(in: (10..<490)), y: Int.random(in: (10..<490)))
  }
}
