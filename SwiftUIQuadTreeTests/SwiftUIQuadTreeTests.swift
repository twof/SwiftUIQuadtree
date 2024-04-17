import XCTest
@testable import SwiftUIQuadTree

final class SwiftUIQuadTreeTests: XCTestCase {
  func testMove() throws {
    let tree = QuadTree(rectangle: .init(origin: .zero, size: .init(width: 100, height: 100)), minSize: .init(width: 10, height: 10))
    
    _ = tree.insert(.init(x: 90, y: 90))
    let second = tree.insert(.init(x: 10, y: 10))!
    XCTAssertEqual(tree.allRects.count, 5)
    XCTAssertEqual(tree.allVals.count, 2)
    
    // Moving across a boundary
    tree.move(element: second, newLocation: .init(x: 10, y: 90))
    XCTAssertEqual(tree.allRects.count, 5)
    XCTAssertEqual(tree.allVals.count, 2)
  }
  
  func testAnimatedMove() throws {
    let tree = QuadTree(rectangle: .init(origin: .zero, size: .init(width: 100, height: 100)), minSize: .init(width: 10, height: 10))
    
    _ = tree.insert(.init(x: 90, y: 90))
    let second = tree.insert(.init(x: 10, y: 10))!
    XCTAssertEqual(tree.allRects.count, 5)
    XCTAssertEqual(tree.allVals.count, 2)
    
    // Moving across a boundary
    tree.animatedMove(element: second, newLocation: .init(x: 10, y: 90))
    XCTAssertEqual(tree.allRects.count, 5)
    XCTAssertEqual(tree.allVals.count, 2)
  }
}
