import SwiftUI

struct QuadTreeElement: Identifiable, Equatable, Codable {
  let id: Int
  let point: CGPoint
}

struct QuadTree {
  let rectangle: CGRect
  var children: [QuadTree]
  let minSize: CGSize
  var values: [QuadTreeElement.ID: QuadTreeElement]
  
  private var currentIndex = 0
  
  init(rectangle: CGRect, minSize: CGSize, values: [CGPoint] = []) {
    self.rectangle = rectangle
    self.children = []
    self.minSize = minSize
    self.values = [:]
    
    for value in values {
      _ = self.insert(value)
    }
  }
  
  private mutating func insert(element: QuadTreeElement) {
    guard rectangle.contains(element.point) else {
      return
    }
    
    if !children.isEmpty {
      for index in (0..<children.count) {
        children[index].insert(element: element)
      }
    }
    
//    print("Value \(element) shifted down to", rectangle)
    values[element.id] = element
  }
  
  mutating func insert(_ val: CGPoint) -> QuadTreeElement? {
    guard let element = self.insert(val, id: currentIndex) else {
      return nil
    }
    currentIndex += 1
    return element
  }
  
  private mutating func insert(_ val: CGPoint, id: QuadTreeElement.ID) -> QuadTreeElement? {
    guard rectangle.contains(val) else {
      return nil
    }
    
    // If there are already children, insert value into them
    if !children.isEmpty {
      return (0..<children.count).reduce(nil) { partialResult, index in
        partialResult ?? children[index].insert(val, id: id)
      }
    }
    
    // Add new value if rectangle is already below min size or if there are no values
    let isSmallerThanMin = rectangle.size.height < minSize.height || rectangle.size.width < minSize.width
    if values.isEmpty || (isSmallerThanMin)  {
      let newElement = QuadTreeElement(id: id, point: val)
//      print("new element", newElement, "inserted into", rectangle)
      values[newElement.id] = newElement
      
      return newElement
    }
    
    // Insert value into child, but first section rectangle if needed
    let subSize = rectangle.size / 2.0
    let topLeft = CGRect(origin: rectangle.origin, size: subSize)
    let topRight = CGRect(
      origin: CGPoint(
        x: rectangle.origin.x + subSize.width,
        y: rectangle.origin.y
      ),
      size: subSize
    )
    let bottomLeft = CGRect(
      origin: CGPoint(x: rectangle.origin.x, y: rectangle.origin.y + subSize.height),
      size: subSize
    )
    let bottomRight = CGRect(
      origin: CGPoint(
        x: rectangle.origin.x + subSize.width,
        y: rectangle.origin.y + subSize.height
      ),
      size: subSize
    )
    
    children = [topLeft, topRight, bottomLeft, bottomRight].map {
      QuadTree(rectangle: $0, minSize: minSize)
    }
    
//    print("rectangle sectioned", rectangle)
    
    // Move all values to children
    for index in (0..<children.count) {
      for value in values.values {
//        print("attempting to shift value down", value)
        children[index].insert(element: value)
      }
    }
    
    self.values = [:]
    
    return (0..<children.count).reduce(nil) { partialResult, index in
      partialResult ?? children[index].insert(val, id: id)
    }
  }
  
  var allVals: [QuadTreeElement] {
    return values.values + children.flatMap { $0.allVals }
  }
  
  var allRects: [CGRect] {
    return [rectangle] + children.flatMap { $0.allRects }
  }
  
  // Returns the remaining values after deletion
  mutating func remove(element: QuadTreeElement) -> [QuadTreeElement] {
    guard rectangle.contains(element.point) else {
      return Array(values.values)
    }
    
    var subTreeValues = [QuadTreeElement]()
    
    if values[element.id] == nil {
      for index in (0..<children.count) {
        subTreeValues += children[index].remove(element: element)
      }
    } else {
      values.removeValue(forKey: element.id)
      subTreeValues += Array(values.values)
    }
    
//    // TODO: Inefficient
//    let vals = self.allVals
    
    if subTreeValues.count <= 1 {
      self.values = subTreeValues.reduce(into: [:]) { partialResult, element in
        partialResult[element.id] = element
      }
//      print("shifted up", vals)
      self.children = []
    }
    
    return subTreeValues
  }
  
  // only delete the element if it needs to move from one square to another
  // A few possibilities:
  // - The item moves within a square. Most moves should be this type.
  // - The item moves from one square where it was the sole element to a square where it is not the sole element which requires sectioning
  // - The item moves from one square where it was not the sole element to any other square, which may require deletion of a subtree
  mutating func move(element: QuadTreeElement, newLocation: CGPoint) {
    if simpleMove(element: element, newLocation: newLocation) {
      print("simple")
      return
    }
    print("complex")
    
    // Remove
    self.remove(element: element)
    
    // Insert at new location
    _ = self.insert(newLocation, id: element.id)
  }
  
  // Returns true if element was moved
  private mutating func simpleMove(element: QuadTreeElement, newLocation: CGPoint) -> Bool {
    // If the rect contains the new location
    guard rectangle.contains(newLocation) else {
      return false
    }
    
    // If the current node contains the element we're looking for, move the element within the square
    if values[element.id] != nil {
      values[element.id] = QuadTreeElement(id: element.id, point: newLocation)
      return true
    }
    
    var didMove = false
    
    for index in (0..<children.count)  {
      didMove = didMove || children[index].simpleMove(element: element, newLocation: newLocation)
    }
    
    return didMove
  }
}

extension QuadTree: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    var queue = [self]
    
    while let current = queue.popLast() {
      queue.insert(contentsOf: current.children, at: 0)
      
      path.addRect(current.rectangle)
      for value in current.values.values {
        path.addEllipse(in: .centeredOn(value.point, size: 10))
      }
      
    }
    
    return path
  }
}
