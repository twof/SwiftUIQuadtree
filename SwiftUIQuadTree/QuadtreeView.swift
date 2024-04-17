import SwiftUI

struct RegionsView: View, Animatable {
  @State var tree: QuadTree
  
  var body: some View {
    //    ZStack {
    //      ForEach(tree.allRects) { child in
    //        VStack(spacing: 0) {
    //          HStack(spacing: 0) {
    //            Rectangle()
    //              .foregroundStyle(Color.random())
    //              .padding(.top, child.minY - tree.rectangle.minY)
    //              .padding(.leading, child.minX - tree.rectangle.minX)
    //            Spacer(minLength: 0)
    //          }
    //          Spacer(minLength: 0)
    //        }
    //      }
    //    }
    tree.stroke(Color.blue, lineWidth: 4)
  }
}

struct QuadTreeView: View {
  @State var tree: QuadTree
  
  var body: some View {
    ZStack {
      // Draw children
      //      RegionsView(tree: tree)
      ForEach(tree.allRects) { child in
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            Rectangle()
              .foregroundStyle(Color.random())
              .padding(.top, child.minY - tree.rectangle.minY)
              .padding(.leading, child.minX - tree.rectangle.minX)
            Spacer(minLength: 0)
          }
          Spacer(minLength: 0)
        }
      }
      
      // Draw points
      ForEach(tree.allVals) { element in
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            Circle()
              .frame(width: 10, height: 10)
              .foregroundStyle(.red)
              .padding(.leading, element.point.x - tree.rectangle.minX)
              .padding(.top, element.point.y - tree.rectangle.minY)
            Spacer(minLength: 0)
          }
          Spacer(minLength: 0)
        }
      }
    }
    .frame(width: tree.rectangle.width, height: tree.rectangle.height)
  }
}

#Preview {
  QuadTreeView(tree: QuadTree(
    rectangle: CGRect(origin: .zero, size: .init(width: 500, height: 500)),
    minSize: .init(width: 20, height: 20),
    values: [
      .init(x: 40, y: 40),
      .init(x: 200, y: 200),
      
        .init(x: 25, y: 400),
      .init(x: 400, y: 25),
      .init(x: 300, y: 300)
    ]
  ))
  .frame(width: 750, height: 750)
}

