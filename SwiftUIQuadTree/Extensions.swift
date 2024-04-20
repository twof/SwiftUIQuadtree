import Foundation
import SwiftUI

extension CGRect: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.origin.x)
    hasher.combine(self.origin.y)
    hasher.combine(self.height)
    hasher.combine(self.width)
  }
}

extension CGRect: Identifiable {
  public var id: String {
    "x: \(origin.x), y: \(origin.y), height: \(height), width: \(width)"
  }
}

extension CGRect {
  static func centeredOn(_ point: CGPoint, size: CGFloat) -> CGRect {
    CGRect(
      origin: CGPoint(x: point.x - (size / 2.0), y: point.y - (size / 2)),
      size: CGSize(width: size, height: size)
    )
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

extension CGPoint {
  func distance(to point: CGPoint) -> CGFloat {
    return sqrt(pow((point.x - x), 2) + pow((point.y - y), 2))
  }
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

extension CGSize {
  static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
    CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
  }
}

// XOR operator
extension Bool {
  static func ^ (left: Bool, right: Bool) -> Bool {
    return left != right
  }
}

infix operator ||=
func ||=(lhs: inout Bool, rhs: Bool) { lhs = (lhs || rhs) }


