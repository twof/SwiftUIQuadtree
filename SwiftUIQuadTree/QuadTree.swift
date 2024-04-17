import SwiftUI

struct QuadTreeElement: Identifiable, Equatable, Codable {
  let id: Int
  let point: CGPoint
}

@Observable final class QuadTree {
  let rectangle: CGRect
  var children: [QuadTree]
  let minSize: CGSize
  var values: [QuadTreeElement]
  
  private var currentIndex = 0
  
  init(rectangle: CGRect, minSize: CGSize, values: [CGPoint] = []) {
    self.rectangle = rectangle
    self.children = []
    self.minSize = minSize
    self.values = []
    
    for value in values {
      _ = self.insert(value)
    }
  }
  
  private func insert(element: QuadTreeElement) {
    guard rectangle.contains(element.point) else {
      return
    }
    
    if !children.isEmpty {
      for index in (0..<children.count) {
        children[index].insert(element: element)
      }
    }
    
    print("Value \(element) shifted down to", rectangle)
    values.append(element)
  }
  
  func insert(_ val: CGPoint) -> QuadTreeElement? {
    guard let element = self.insert(val, id: currentIndex) else {
      return nil
    }
    currentIndex += 1
    return element
  }
  
  private func insert(_ val: CGPoint, id: QuadTreeElement.ID) -> QuadTreeElement? {
    guard rectangle.contains(val) else { return nil }
    
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
      print("new element", newElement, "inserted into", rectangle)
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
    
    print("rectangle sectioned", rectangle)
    
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
  
  var allVals: [QuadTreeElement] {
    return values + children.flatMap { $0.allVals }
  }
  
  var allRects: [CGRect] {
    return [rectangle] + children.flatMap { $0.allRects }
  }
  
  func remove(element: QuadTreeElement) {
    guard rectangle.contains(element.point) else {
      return
    }
    
    if !values.isEmpty {
      values.removeAll { 
        let isMatch = $0.id == element.id
        if isMatch {
          print("deleting \(element) from \(rectangle)")
        }
        return isMatch
      }
    } else {
      for index in (0..<children.count) {
        children[index].remove(element: element)
      }
    }
    
    // TODO: Inefficient
    let vals = self.allVals
    
    if vals.count <= 1 {
      self.values = vals
      print("shifted up", vals)
      self.children = []
    }
  }
  
  func move(element: QuadTreeElement, newLocation: CGPoint) {
    // Remove
    self.remove(element: element)
    
    // Insert at new location
    _ = self.insert(newLocation, id: element.id)
  }
}

extension QuadTree {
  func animatedMove(element: QuadTreeElement, newLocation: CGPoint) {
    let xdiff = newLocation.x - element.point.x
    let ydiff = newLocation.y - element.point.y
    let distance = element.point.distance(to: newLocation)
    let stages = Int(ceil(distance / minSize.width))
    
    let xStageDiff = xdiff / CGFloat(stages)
    let yStageDiff = ydiff / CGFloat(stages)
    
//    var lastElement = element
    
////    print("stages", stages)
//    
////        withAnimation(.linear(duration: 1)) {
//    for stage in (0...stages) {
////      print("points", self.allVals.count)
////      print("rects", self.allRects)
//      let nextPoint = CGPoint(x: element.point.x + CGFloat(stage) * xStageDiff, y: element.point.y + CGFloat(stage) * yStageDiff)
////      print("next point", nextPoint)
//      withAnimation(.linear(duration: 1)) {
//        self.move(element: lastElement, newLocation: nextPoint)
//      } completion: {
//        <#code#>
//      }
//      
//      lastElement = QuadTreeElement(id: element.id, point: nextPoint)
//      print()
//      print()
//      print()
//      print()
//    }
//        }
    
    animatedMove(
      lastElement: element,
      nextPoint: element.point,
      currentStage: 0,
      endStage: stages,
      xStageDiff: xStageDiff,
      yStageDiff: yStageDiff
    )
    
    //    for stage in (0...stages) {
    //      let nextPoint = CGPoint(x: element.point.x + CGFloat(stage) * xStageDiff, y: element.point.y + CGFloat(stage) * yStageDiff)
    //      print("next point", nextPoint)
    //      withAnimation(.linear) {
    //        self.move(element: element, newLocation: nextPoint)
    //      }
    //    }
  }
  
  func animatedMove(lastElement: QuadTreeElement, nextPoint: CGPoint, currentStage: Int, endStage: Int, xStageDiff: CGFloat, yStageDiff: CGFloat) {
    withAnimation(.linear) {
      self.move(element: lastElement, newLocation: nextPoint)
    } completion: { [weak self] in
      guard let self, currentStage < endStage else {
        return
      }
      
      print()
      print()
      print()
      print()
      let last = QuadTreeElement(id: lastElement.id, point: nextPoint)
      let next = CGPoint(x: nextPoint.x + xStageDiff, y: nextPoint.y + yStageDiff)
      
      self.animatedMove(
        lastElement: last,
        nextPoint: next,
        currentStage: currentStage + 1,
        endStage: endStage,
        xStageDiff: xStageDiff,
        yStageDiff: yStageDiff
      )
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
