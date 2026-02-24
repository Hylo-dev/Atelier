import SwiftUI

// MARK: - Generic Liquid Category Bar
struct LiquidCategoryBarView: View {
    
    @Bindable
    var state: TabFilterState
    
    @Namespace
    private var categoryNamespace
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(self.state.items, id: \.self) { item in
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                self.state.selection = item
                            }
                            
                        } label: {
                            Text(item)
                                .font(.callout)
                                .fontWeight(self.state.selection == item ? .semibold : .regular)
                                .frame(width: 120)
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .id(item)
                    }
                }
                .background(alignment: .leading) {
                    GeometryReader { proxy in
                        let size = proxy.size
                        let count = CGFloat(self.state.items.count)
                        let capsuleWidth = count > 0 ? size.width / count : 0
                        
                        Capsule()
                            .glassEffect(.clear)
                            .padding(4)
                            .frame(width: capsuleWidth)
                            .offset(x: self.state.progress * (size.width - capsuleWidth))
                    }
                }
                .padding(.horizontal, 5)
            }
            .fixedSize(horizontal: false, vertical: true)
            .onChange(of: self.state.selection) { _, newValue in
                if let newValue {
                    withAnimation(.snappy) {
                        scrollProxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
    }
}

// MARK: - Generic Paging View
struct LiquidPagingView<T: Hashable, Content: View>: View {
    
    
    
    @Binding
    var selection: T?
    
    var onProgressChange: (CGFloat) -> Void
    
    var items: [T]
    var isEnabled: Bool
    
    @ViewBuilder
    var content: (T) -> Content
    
    init(
        selection           : Binding<T?>,
        onProgressChange    : @escaping (CGFloat) -> Void,
        items               : [T],
        isEnabled           : Bool = true,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self._selection       = selection
        self.onProgressChange = onProgressChange
        self.items            = items
        self.isEnabled        = isEnabled
        self.content          = content
    }
    
    var body: some View {
        let itemsCount = max(1, self.items.count - 1)
        
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                
                Group {
                    if self.isEnabled {
                        ForEach(self.items, id: \.self) { item in
                            self.content(item)
                                .id(item)
                        }
                        
                    } else if let first = self.items.first {
                        self.content(first)
                            .id(first)
                    }
                }
                .containerRelativeFrame(.horizontal)
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: self.$selection)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollClipDisabled()
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            let width = geometry.containerSize.width
            guard width > 0 else { return 0 }
                        
            let rawProgress = geometry.contentOffset.x / (width * CGFloat(itemsCount))
            return (rawProgress * 1000).rounded() / 1000
            
        } action: { oldValue, newValue in
            let clamped = max(min(newValue, 1), 0)
            
            self.onProgressChange(clamped)
        }
    }
}

#Preview {
    
    @Previewable
    @State
    var selection: String? = ""
    
    @Previewable
    @State
    var progress: CGFloat = .zero
    
    let items = ["pisnello", "culo", "palle", "Gratta"]
    
    ZStack {
        
        LiquidPagingView(
            selection: $selection,
            onProgressChange: { val in
                if progress != val {
                    progress = val
                }
            },
            items: items
        ) { item in
            ScrollView {
                LazyVStack {
                    
                    ForEach(0...10, id: \.self) { _ in
                        Text("Si ")
                    }
                    
                }
            }
        }
        
//        LiquidCategoryBarView(selection: $selection, tabProgress: $progress, items: items, titleProvider: { $0 })
    }
    
}
