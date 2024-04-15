//
//  ContentView.swift
//  SwiftUIQuadTree
//
//  Created by fnord on 4/15/24.
//

import SwiftUI

struct QuadTreeElement: Identifiable, Equatable, Codable {
  let id: Int
  let point: CGPoint
}

@Observable class QuadTree {
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
    
    // Move all values to children
    for index in (0..<children.count) {
      for value in values {
        children[index].insert(element: value)
      }
    }
    
    self.values = []
    
    return (0..<children.count).reduce(nil) { partialResult, index in
      partialResult ?? children[index].insert(val, id: id)
    }
  }
  
  func getVals() -> [QuadTreeElement] {
    return values + children.flatMap { $0.getVals() }
  }
  
  func remove(element: QuadTreeElement) {
    guard rectangle.contains(element.point) else {
      return
    }
    
    if !values.isEmpty {
      values.removeAll { $0.id == element.id }
    } else {
      for index in (0..<children.count) {
        children[index].remove(element: element)
      }
    }
    
    let vals = self.getVals()
    
    if vals.count <= 1 {
      self.values = vals
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

struct QuadTreeView: View {
  @State var tree: QuadTree
  
  var body: some View {
    ZStack {
//      if !tree.children.isEmpty {
//        // Vertical line
//        Rectangle()
//          .frame(width: 2)
//          .foregroundStyle(.black)
//        
//        // Horizontal line
//        Rectangle()
//          .frame(height: 2)
//          .foregroundStyle(.black)
//      }
      
      // Draw children
      ForEach(tree.children, id: \.rectangle) { child in
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            QuadTreeView(tree: child)
              .background(Color.random())
              .padding(.top, child.rectangle.minY - tree.rectangle.minY)
              .padding(.leading, child.rectangle.minX - tree.rectangle.minX)
            Spacer(minLength: 0)
          }
          Spacer(minLength: 0)
        }
      }
      
      // Draw points
      ForEach(tree.values) { element in
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
      withAnimation(.linear(duration: 10)) {
        tree.move(element: tree.getVals()[0], newLocation: .init(x: 20, y: 400))
//        tree.remove(element: tree.getVals()[0])
      }
    }
  }
}

#Preview {
  ContentView()
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
