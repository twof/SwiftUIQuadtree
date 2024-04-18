import SwiftUI

struct RegionsView: View, Animatable {
  @State var tree: QuadTree
  
  var body: some View {
    tree.stroke(Color.blue, lineWidth: 4)
  }
}

@Observable
class QuadTreeViewModel {
  var tree: QuadTree
  @ObservationIgnored private var actions: [Action] = []
  @ObservationIgnored private var isProcessing = false
  @ObservationIgnored private var colorsCache: [CGRect: Color] = [:]
  
  var rectangle: CGRect {
    tree.rectangle
  }
  
  var allVals: [QuadTreeElement] {
    tree.allVals
  }
  
  var allRects: [CGRect] {
    tree.allRects
  }
  
  init(tree: QuadTree) {
    self.tree = tree
  }
  
  func getColor(for rect: CGRect) -> Color {
    if let color = colorsCache[rect] {
      return color
    }
    let newColor = Color.random()
    colorsCache[rect] = newColor
    return newColor
  }
  
  func animatedMove(_ element: QuadTreeElement, newLocation: CGPoint) {
    let xdiff = newLocation.x - element.point.x
    let ydiff = newLocation.y - element.point.y
    let distance = element.point.distance(to: newLocation)
    let stages = Int(ceil(distance / tree.minSize.width))
    
    let xStageDiff = xdiff / CGFloat(stages)
    let yStageDiff = ydiff / CGFloat(stages)
    
    actions.append(.queue((0..<stages).reduce(into: (last: element, list: [Action]()), { partialResult, stage in
      let (lastElement, _) = partialResult
      let nextLocation = CGPoint(x: lastElement.point.x + xStageDiff, y: lastElement.point.y + yStageDiff)
      partialResult.list.append(.move(partialResult.last, newLocation: nextLocation))
      
      partialResult.last = QuadTreeElement(id: lastElement.id, point: nextLocation)
    }).list[...]))
    
    processActions()
  }
  
  func processActions() {
    // If already processing, no need to process more
    guard !isProcessing else {
      return
    }
    
    self.isProcessing = true
    internalProcessActions()
  }
  
  private func internalProcessActions() {
    let remainingQueues: [Action] = self.actions.compactMap {
      if case let .queue(array) = $0, array.count > 1 {
        return .queue(array.suffix(from: array.startIndex.advanced(by: 1)))
      }
      
      return nil
    }
    
    let actionsToProcess: [Action] = self.actions.compactMap {
      switch $0 {
      case let .queue(array):
        guard let first = array.first else {
          return nil
        }
        return first
      case .move:
        return $0
      }
    }
    
    self.actions = []
    
    withAnimation(.linear(duration: 0.3)) {
      for action in actionsToProcess {
//        print("Processing:", action)
        switch action {
        case let .move(element, newLocation):
          tree.move(element: element, newLocation: newLocation)
        case .queue:
          fatalError()
        }
      }
    } completion: { [weak self] in
      guard let self else { return }
      actions.append(contentsOf: remainingQueues)
      
      if actions.isEmpty {
        isProcessing = false
      } else {
        internalProcessActions()
      }
    }

  }
}

extension QuadTreeViewModel {
  enum Action {
    case queue(ArraySlice<Action>)
    case move(QuadTreeElement, newLocation: CGPoint)
  }
}

struct QuadTreeView: View {
  var vm: QuadTreeViewModel
  
  var body: some View {
    ZStack {
      // Draw children
      GridView(rects: vm.allRects, colorGenerator: vm.getColor)
      
      // Draw points
      PositionsView(elements: vm.allVals)
    }
    .frame(width: vm.rectangle.width, height: vm.rectangle.height)
  }
}

struct PositionsView: View, Equatable {
  let elements: [QuadTreeElement]
  
  var body: some View {
    ForEach(elements) { element in
      PositionView(position: element.point)
        .id(element.id)
    }
  }
}

struct GridView: View, Equatable {
  let rects: [CGRect]
  let colorGenerator: (CGRect) -> Color
  
  var body: some View {
    ForEach(rects) { child in
      RectangleView(color: colorGenerator(child), rect: child)
        .id(child.id)
    }
  }
  
  static func == (lhs: GridView, rhs: GridView) -> Bool {
    return lhs.rects == rhs.rects
  }
}

struct PositionView: View, Equatable {
  let position: CGPoint
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Circle()
          .frame(width: 10, height: 10)
          .foregroundStyle(.red)
          .padding(.leading, position.x)
          .padding(.top, position.y)
        Spacer(minLength: 0)
      }
      Spacer(minLength: 0)
    }
  }
}

struct RectangleView: View, Equatable {
  let color: Color
  let rect: CGRect
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Rectangle()
          .foregroundStyle(color)
          .padding(.top, rect.minY)
          .padding(.leading, rect.minX)
        
        Spacer(minLength: 0)
      }
      Spacer(minLength: 0)
    }
  }
}

#Preview {
  QuadTreeView(vm: QuadTreeViewModel(tree: QuadTree(
    rectangle: CGRect(origin: .zero, size: .init(width: 500, height: 500)),
    minSize: .init(width: 20, height: 20),
    values: [
      .init(x: 40, y: 40),
      .init(x: 200, y: 200),
      .init(x: 25, y: 400),
      .init(x: 400, y: 25),
      .init(x: 300, y: 300)
    ]
  )))
  .frame(width: 750, height: 750)
}

