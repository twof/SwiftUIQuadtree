import XCTest
@testable import SwiftUIQuadTree

final class QuadTreeViewModelTests: XCTestCase {
  func testAnimatedMove() throws {
    let tree = QuadTree(rectangle: .init(origin: .zero, size: .init(width: 100, height: 100)), minSize: .init(width: 10, height: 10), values: [
      .init(x: 90, y: 90),
      .init(x: 10, y: 10)
    ])
    let vm = QuadTreeViewModel(tree: tree)
    
    vm.animatedMove(QuadTreeElement(id: 1, point: .init(x: 10, y: 10)), newLocation: .init(x: 10, y: 90))
    
    // Moving across a boundary
//    tree.move(element: second, newLocation: .init(x: 10, y: 90))
    
    XCTAssertEqual(tree.allRects.count, 5)
    XCTAssertEqual(tree.allVals.count, 2)
  }
}
