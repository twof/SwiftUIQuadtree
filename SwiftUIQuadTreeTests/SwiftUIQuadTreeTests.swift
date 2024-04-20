import XCTest
@testable import SwiftUIQuadTree

final class SwiftUIQuadTreeTests: XCTestCase {
  func testMove() throws {
    var tree = QuadTree(rectangle: .init(origin: .zero, size: .init(width: 100, height: 100)), minSize: .init(width: 10, height: 10))
    
    _ = tree.insert(.init(x: 90, y: 90))
    let second = tree.insert(.init(x: 10, y: 10))!
    XCTAssertEqual(tree.allRects.count, 5)
    XCTAssertEqual(tree.allVals.count, 2)
    
    // Moving across a boundary
    _ = tree.move(element: second, newLocation: .init(x: 10, y: 90))
    XCTAssertEqual(tree.allRects.count, 5)
    XCTAssertEqual(tree.allVals.count, 2)
  }
  
  func testRemove() throws {
    // Realistic example from manual tests
    let exampleElement = QuadTreeElement(id: 9, point: CGPoint(x: 123.0, y: 485.0))
    let examplePoints = [
      QuadTreeElement(id: 2, point: CGPoint(x: 128.63636363636363, y: 37.95454545454545)),
      QuadTreeElement(id: 6, point: CGPoint(x: 269.8095238095238, y: 63.23809523809524)),
      QuadTreeElement(id: 4, point: CGPoint(x: 263.0, y: 214.25)),
      QuadTreeElement(id: 5, point: CGPoint(x: 142.58333333333334, y: 276.5833333333333)),
      QuadTreeElement(id: 1, point: CGPoint(x: 242.0, y: 398.0)),
      QuadTreeElement(id: 7, point: CGPoint(x: 233.0, y: 459.0)),
      QuadTreeElement(id: 3, point: CGPoint(x: 329.0, y: 334.0)),
      QuadTreeElement(id: 8, point: CGPoint(x: 279.0, y: 431.0)),
      QuadTreeElement(id: 0, point: CGPoint(x: 341.0, y: 409.0))
    ]
    var tree = QuadTree(
      rectangle: .init(origin: .zero, size: .init(width: 500, height: 500)),
      minSize: .init(width: 20, height: 20),
      values: (examplePoints + [exampleElement]).sorted { $0.id < $1.id }.map { $0.point }
    )
    
    print()
    
    let (didRemove, remaining) = tree.remove(
      element: exampleElement
    )
    
    XCTAssertTrue(didRemove)
    XCTAssertEqual(tree.allVals.count, 9)
    XCTAssertEqual(remaining.count, 9)
    XCTAssertEqual(Set(examplePoints), Set(remaining))
  }
}
