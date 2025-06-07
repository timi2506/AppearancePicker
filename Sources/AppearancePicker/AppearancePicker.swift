import SwiftUI

public struct AppearancePicker<ItemType: Hashable>: View {
    public init(
        selection: Binding<ItemType>,
        imageHeight: CGFloat = 175,
        selectionStroke: AnyShapeStyle = AnyShapeStyle(Color.accentColor),
        cornerRadius: CGFloat = 10,
        animation: Animation? = .default,
        layout: some Layout = HStackLayout(spacing: 25),
        needsScrolling: Bool = false,
        scrollAxes: Axis.Set = .horizontal,
        @AppearanceItemsBuilder<ItemType> values: @escaping () -> [AppearanceItem<ItemType>]
    ) {
        self._selection = selection
        self.height = imageHeight
        self.selectionStroke = selectionStroke
        self.values = values()
        self.animation = animation
        self.layout = AnyLayout(layout)
        self.needsScroll = needsScrolling
        self.scrollAxes = scrollAxes
        self.cornerRadius = cornerRadius
    }

    public init(
        selection: Binding<ItemType>,
        imageHeight: CGFloat = 175,
        selectionStroke: some ShapeStyle = Color.accentColor,
        cornerRadius: CGFloat = 12.5,
        animation: Animation? = .default,
        layout: some Layout = HStackLayout(spacing: 25),
        needsScrolling: Bool = false,
        scrollAxes: Axis.Set = .horizontal,
        @AppearanceItemsBuilder<ItemType> values: @escaping () -> [AppearanceItem<ItemType>]
    ) {
        self._selection = selection
        self.height = imageHeight
        self.selectionStroke = AnyShapeStyle(selectionStroke)
        self.values = values()
        self.animation = animation
        self.layout = AnyLayout(layout)
        self.needsScroll = needsScrolling
        self.scrollAxes = scrollAxes
        self.cornerRadius = cornerRadius
    }

    @Binding var selection: ItemType
    @AppearanceItemsBuilder<ItemType> var values: [AppearanceItem<ItemType>]
    @Namespace var namespace
    var animation: Animation?
    var layout: AnyLayout
    var height: CGFloat
    var selectionStroke: AnyShapeStyle
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
                    withAnimation(animation) {
                        selection = value.value
                    }
                }
                .padding(5)
            }
        }
        .conditionalModifier(condition: needsScroll, modifier: ScrollableModifier(axes: .horizontal))
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

public struct AppearanceItem<ItemType: Hashable>: Identifiable {
    public init(value: ItemType, image: Image, label: @escaping () -> some View) {
        self.value = value
        self.label = AnyView(label())
        self.image = image
    }

    public init(_ title: String, systemImage: String? = nil, value: ItemType, image: Image) {
        self.value = value
        if let systemImage {
            self.label = AnyView(Label(title, systemImage: systemImage))
        } else {
            self.label = AnyView(Text(title))
        }
        self.image = image
    }

    public var id = UUID()
    public var value: ItemType
    public var label: AnyView
    public var image: Image
}

public extension Animation {
    static let none: Animation? = nil
}

@resultBuilder
public struct AppearanceItemsBuilder<ItemType: Hashable> {
    public static func buildBlock(_ parts: AppearanceItem<ItemType>...) -> [AppearanceItem<ItemType>] {
        return parts
    }
}
