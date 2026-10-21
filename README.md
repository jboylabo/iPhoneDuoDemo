# iPhone Duo PJ

* 動作検証環境
  * Xcode 27.2 Release Candidate
  * iOS 27.2

学習の参考にした海外動画
https://youtu.be/gn8dLvJ9hx4?si=JiWe_-EDj7jYMxRY

## ArrangementView

環境に適応するレイアウトを使用して、プライマリおよびセカンダリコンテンツを配置するビュー。

https://developer.apple.com/jp/documentation/swiftui/arrangementview

**オーバーレイの配置**
オーバーレイ配置は、zオーダーでプライマリビューをセカンダリビューの上に重ねるものです。このレイアウトは、再生コントロールがビデオサーフェス上にオーバーレイ表示されるメディアプレーヤーなどのフルスクリーンエクスペリエンスに適しています

```swift
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            ArrangementView {
                Color.red
            } secondary: {
                Color.blue
            }
        }
    }
}

#Preview {
    ContentView()
}
```

**タブを縦向きで配置する**

```swift
import SwiftUI

struct ContentView: View {

var body: some View {
    TabView {
            Tab.init("Home", systemImage: "house") {
                
            }
            
            Tab.init("Favorites", systemImage: "suit.heart") {
                
            }
            
            Tab.init("Settings", systemImage: "gear") {
                
            }
        }
    }
}

#Preview {
    ContentView()
}
```

**タブを横向きで配置する**

```swift
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
                Tab.init("Home", systemImage: "house") {
                    
                }
                
                Tab.init("Favorites", systemImage: "suit.heart") {
                    
                }
                
                Tab.init("Settings", systemImage: "gear") {
                    
                }
            }
        .toolbarVerticalBehavior(.disabled)
        }
}1

#Preview {
    ContentView()
}
```

ヒンジを操作するAPI

```swift

```

**@20261021 WED**