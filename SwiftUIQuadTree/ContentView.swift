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

struct QuadTree {
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
  
  private mutating func insert(element: QuadTreeElement) {
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
  
  mutating func insert(_ val: CGPoint) -> QuadTreeElement.ID? {
    guard rectangle.contains(val) else { return nil }
    
    // If there are already children, insert value into them
    if !children.isEmpty {
      return (0..<children.count).reduce(nil) { partialResult, index in
        partialResult ?? children[index].insert(val)
      }
    }
    
    // Add new value if rectangle is already below min size or if there are no values
    let isSmallerThanMin = rectangle.size.height < minSize.height || rectangle.size.width < minSize.width
    if values.isEmpty || (isSmallerThanMin)  {
      let newIndex = currentIndex
      self.currentIndex += 1
      values.append(QuadTreeElement(id: newIndex, point: val))
      return newIndex
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
      partialResult ?? children[index].insert(val)
    }
  }
  
  func getVals() -> [QuadTreeElement] {
    return values + children.flatMap { $0.getVals() }
  }
}

extension CGSize {
  static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
    CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
  }
}

struct QuadTreeView: View {
  @State var tree: QuadTree
  
  var body: some View {
    ZStack {
      if !tree.children.isEmpty {
        // Vertical line
        Rectangle()
          .frame(width: 2)
          .foregroundStyle(.black)
        
        // Horizontal line
        Rectangle()
          .frame(height: 2)
          .foregroundStyle(.black)
      }
      
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

extension CGRect: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.origin.x)
    hasher.combine(self.origin.y)
    hasher.combine(self.height)
    hasher.combine(self.width)
  }
}

extension CGPoint: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.x)
    hasher.combine(self.y)
  }
}

extension CGPoint: Identifiable {
  public var id: String { "x: \(x), y: \(y)" }
}

public extension Color {
  static func random(randomOpacity: Bool = false) -> Color {
    Color(
      red: .random(in: 0...1),
      green: .random(in: 0...1),
      blue: .random(in: 0...1),
      opacity: randomOpacity ? .random(in: 0...1) : 1
    )
  }
}

struct ContentView: View {
  @State var tree = QuadTree(
    rectangle: CGRect(origin: .zero, size: .init(width: 500, height: 500)),
    minSize: .init(width: 20, height: 20)
  )
  
  var body: some View {
    QuadTreeView(tree: QuadTree(
      rectangle: CGRect(origin: .zero, size: .init(width: 500, height: 500)),
      minSize: .init(width: 20, height: 20),
      values: [
        .init(x: 40, y: 40),
        .init(x: 300, y: 300),
        .init(x: 200, y: 200)
      ]
    ))
    .background(.gray)
    .frame(width: 600, height: 600)
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
