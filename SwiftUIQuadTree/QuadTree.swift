import SwiftUI
import IdentifiedCollections

struct QuadTreeElement: Identifiable, Equatable, Codable, Hashable {
  let id: Int
  let point: CGPoint
}

struct QuadTree {
  let rectangle: CGRect
  var children: [QuadTree]
  let minSize: CGSize
  var values: IdentifiedArrayOf<QuadTreeElement>
  
  private static var currentIndex = 0
  
  init(rectangle: CGRect, minSize: CGSize, values: [CGPoint] = []) {
    self.rectangle = rectangle
    self.children = []
    self.minSize = minSize
    self.values = []
    
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
    values.append(element)
  }
  
  mutating func insert(_ val: CGPoint) -> QuadTreeElement? {
    guard let element = self.insert(val, id: QuadTree.currentIndex) else {
      return nil
    }
    QuadTree.currentIndex += 1
    return element
  }
  
  private mutating func insert(_ val: CGPoint, id: QuadTreeElement.ID) -> QuadTreeElement? {
    guard rectangle.contains(val) else {
      return nil
    }
    
//    print("Before insert", rectangle, allVals.count, allVals)
//    defer {
//      print("After insert", rectangle, allVals.count, allVals)
//    }
    
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
      values.append(newElement)
      
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
      for value in values {
//        print("attempting to shift value down", value)
        children[index].insert(element: value)
      }
    }
    
    self.values = []
    
    return (0..<children.count).reduce(nil) { partialResult, index in
      partialResult ?? children[index].insert(val, id: id)
    }
  }
  
  var allVals: IdentifiedArrayOf<QuadTreeElement> {
    return values + children.flatMap { $0.allVals }
  }
  
  var allRects: [CGRect] {
    return [rectangle] + children.flatMap { $0.allRects }
  }
  
  // Returns the remaining values after deletion
  mutating func remove(element: QuadTreeElement) -> (didRemove: Bool, remaining: IdentifiedArrayOf<QuadTreeElement>) {
    guard rectangle.contains(element.point) else {
      return (false, allVals)
    }
    
//    print("Before remove", rectangle, allVals.count, allVals)
//    defer {
//      print("After remove", rectangle, allVals.count, allVals)
//    }
    
    var subTreeValues = IdentifiedArrayOf<QuadTreeElement>()
    var didRemove = false
    
    if !values.ids.contains(element.id) {
      for index in (0..<children.count) {
        let removal = children[index].remove(element: element)
        subTreeValues += removal.remaining
        didRemove ||= removal.didRemove
      }
    } else {
      values.remove(id: element.id)
      subTreeValues += Array(values)
      didRemove = true
    }
    
    if subTreeValues.count <= 1 {
      self.values = subTreeValues
//      print("shifted up", subTreeValues)
      self.children = []
    }
    
    return (didRemove, subTreeValues)
  }
  
  // only delete the element if it needs to move from one square to another
  // A few possibilities:
  // - The item moves within a square. Most moves should be this type.
  // - The item moves from one square where it was the sole element to a square where it is not the sole element which requires sectioning
  // - The item moves from one square where it was not the sole element to any other square, which may require deletion of a subtree
  mutating func move(element: QuadTreeElement, newLocation: CGPoint) -> Bool {
    // Traverse down until the new location and the elemement are not in the same rectangle
    guard rectangle.contains(element.point) && rectangle.contains(newLocation) else {
      return false
    }
    
//    print("Before move", rectangle, allVals.count, allVals)
//    defer {
//      print("After move", rectangle, allVals.count, allVals)
//    }
    
    if children.isEmpty {
      // If we're at a leaf node that contains the element to move
      if values.ids.contains(element.id)  {
//        print("moving within node:", element)
        // Move the element within the node
        values[id: element.id] = QuadTreeElement(id: element.id, point: newLocation)
        return true
      } else {
        // Element not found
        return false
      }
    } else {
      // If child contains the element, and a different child contiains the target
      // then we've found the lowest common parent.
      var lowestCommonParent = false
      for index in (0..<children.count) {
        lowestCommonParent ||= (children[index].rectangle.contains(element.point) ^ children[index].rectangle.contains(newLocation))
      }
      
      if lowestCommonParent {
        // Remove
        let (didRemove, _) = self.remove(element: element)
        
        // Insert at new location
        _ = self.insert(newLocation, id: element.id)
        
        return didRemove
      }
      
      // Lowest common parent not yet found, so keep traversing lower into the tree
      var didMove = false
      
      for index in (0..<children.count)  {
        didMove ||= children[index].move(element: element, newLocation: newLocation)
      }
      
      return didMove
    }
  }
}

extension QuadTree: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    var queue = [self]
    
    while let current = queue.popLast() {
      queue.insert(contentsOf: current.children, at: 0)
      
      path.addRect(current.rectangle)
      for value in current.values {
        path.addEllipse(in: .centeredOn(value.point, size: 10))
      }
    }
    
    return path
  }
}
