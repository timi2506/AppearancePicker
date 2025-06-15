import SwiftUI

public struct AppearancePicker<ItemType: Hashable, Style: ShapeStyle, L: Layout, Content: View>: View {
    public init(
        selection: Binding<ItemType>,
        imageHeight: CGFloat = 175,
        selectionStroke: Style = Color.accentColor,
        cornerRadius: CGFloat = 10,
        animation: Animation? = .default,
        layout: L = HStackLayout(spacing: 25),
        needsScrolling: Bool = false,
        scrollAxes: Axis.Set = .horizontal,
        @AppearanceItemsBuilder<ItemType, Content> values: @escaping () -> [AppearanceItem<ItemType, Content>]
    ) {
        self._selection = selection
        self.height = imageHeight
        self.selectionStroke = selectionStroke
        self.values = values()
        self.animation = animation
        self.layout = layout
        self.needsScroll = needsScrolling
        self.scrollAxes = scrollAxes
        self.cornerRadius = cornerRadius
    }

    @Binding var selection: ItemType
    @AppearanceItemsBuilder<ItemType, Content> var values: [AppearanceItem<ItemType, Content>]
    @Namespace var namespace
    var animation: Animation?
    var layout: L
    var height: CGFloat
    var selectionStroke: Style
    var needsScroll: Bool
    var scrollAxes: Axis.Set
    var cornerRadius: CGFloat

    public var body: some View {
        layout {
            ForEach(values) { value in
                VStack {
                    value.image
                        .resizable()
                        .scaledToFit()
                        .frame(height: height)
                        .cornerRadius(cornerRadius)
                        .padding(2.5)
                        .overlay {
                            if selection == value.value {
                                RoundedRectangle(cornerRadius: cornerRadius + 2.5)
                                    .stroke(selectionStroke, lineWidth: 2.5)
                                    .matchedGeometryEffect(id: "pickerValue", in: namespace)
                            }
                        }
                    value.label
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selection = value.value
                }
                .padding(5)
            }
        }
        .animation(.spring, value: selection)
        .conditionalModifier(condition: needsScroll, modifier: ScrollableModifier(axes: .horizontal))
    }
}

public struct ScrollableModifier: ViewModifier {
    var axes: Axis.Set
    public func body(content: Content) -> some View {
        ScrollView(axes, showsIndicators: false, content: { content })
    }

    public init(axes: Axis.Set) {
        self.axes = axes
    }
}

extension View {
    func conditionalModifier<Modifier: ViewModifier>(condition: Bool, modifier: Modifier) -> some View {
        self.modifier(ConditionalModifier(condition: condition, modifier: modifier))
    }
}

struct ConditionalModifier<Modifier: ViewModifier>: ViewModifier {
    var condition: Bool
    var modifier: Modifier

    public init(condition: Bool, modifier: Modifier) {
        self.condition = condition
        self.modifier = modifier
    }

    public func body(content: Content) -> some View {
        if condition {
            content.modifier(modifier)
        } else {
            content
        }
    }
}

public struct AppearanceItem<ItemType: Hashable, Content: View>: Identifiable {
    public init(value: ItemType, image: Image, @ViewBuilder label: () -> Content) {
        self.value = value
        self.label = label()
        self.image = image
    }

    public init(_ title: String, systemImage: String, value: ItemType, image: Image) where Content == Label<Text, Image> {
        self.value = value
        self.label = Label(title, systemImage: systemImage)
        self.image = image
    }

    public init(_ title: String, value: ItemType, image: Image) where Content == Text {
        self.value = value
        self.label = Text(title)
        self.image = image
    }

    public var id = UUID()
    public var value: ItemType
    public var label: Content
    public var image: Image
}

public extension Animation {
    static let none: Animation? = nil
}

@resultBuilder
public struct AppearanceItemsBuilder<ItemType: Hashable, Content: View> {
    public static func buildBlock(_ parts: AppearanceItem<ItemType, Content>...) -> [AppearanceItem<ItemType, Content>] {
        return parts
    }
}
