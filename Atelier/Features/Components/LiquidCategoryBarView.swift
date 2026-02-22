import SwiftUI

// MARK: - Generic Liquid Category Bar
struct LiquidCategoryBarView<T: Hashable>: View {
    @Binding var selection: T
    @Binding var tabProgress: CGFloat
    
    let items: [T]
    let titleProvider: (T) -> String
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(self.items, id: \.self) { item in
                        Button {
                            withAnimation(.snappy) {
                                self.selection = item
                            }
                            
                        } label: {
                            Text(self.titleProvider(item))
                                .font(.callout)
                                .fontWeight(self.selection == item ? .semibold : .regular)
                                .frame(width: 120)
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                                
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background {
                    GeometryReader { proxy in
                        let size = proxy.size
                        
                        let capsuleWidth = items.isEmpty ? 0 : (size.width / CGFloat(items.count))
                        
                        let safeProgress = tabProgress.isNaN ? 0 : tabProgress
                        
                        Capsule()
                            .padding(3)
                            .frame(width: capsuleWidth)
                            .glassEffect(.clear)
                            .offset(x: items.isEmpty ? 0 : safeProgress * (size.width - capsuleWidth))
                    }
                }
                .padding(.horizontal, 5)
            }
            .fixedSize(horizontal: false, vertical: true)
            .onChange(of: selection) { _, newSelection in
                withAnimation(.snappy) {
                    scrollProxy.scrollTo(newSelection, anchor: .center)
                }
            }
        }
    }
}

// MARK: - Generic Paging View
struct LiquidPagingView<T: Hashable, Content: View>: View {
    @Binding
    var selection: T?
    
    @Binding
    var tabProgress: CGFloat
    
    let items: [T]
    @ViewBuilder let content: (T) -> Content
    
    var body: some View {
        let itemsCount = max(1, self.items.count - 1)
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(self.items, id: \.self) { item in
                    self.content(item)
                        .containerRelativeFrame(.horizontal)
                        .id(item)
                }
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
            
            return geometry.contentOffset.x / (width * CGFloat(itemsCount))
        } action: { oldValue, newValue in
            self.tabProgress = max(min(newValue, 1), 0)
        }
    }
}
