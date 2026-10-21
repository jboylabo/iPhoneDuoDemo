# iPhone Duo PJ

折りたたみ iPhone **iPhone Duo** 向けの SwiftUI API（`ArrangementView`、新しい `Tab` / `TabView`、`onHingeChange` など）を試すための学習用リポジトリです。Xcode 27 の **Device Hub** と iPhone Duo シミュレータ上で、レイアウトとヒンジ連動の挙動を確認することを目的にしています。

## 動作検証環境

| 項目 | バージョン |
|------|------------|
| Xcode | 27.2 Release Candidate |
| iOS Simulator | 27.2（**iPhone Duo**） |

通常の iPhone シミュレータではヒンジ API は動作しません。Run 先は必ず **iPhone Duo** を選んでください。

## このリポジトリの構成

| パス | 内容 |
|------|------|
| [iPhoneDuoDemo/ContentView.swift](iPhoneDuoDemo/ContentView.swift) | 現在の実行対象（ヒンジ状態の表示デモ） |
| [docs/app-resizability-skill.md](docs/app-resizability-skill.md) | Apple 公式 **app-resizability** スキルの解説 |
| [docs/iphone-duo-hinge-slider.md](docs/iphone-duo-hinge-slider.md) | Device Hub でヒンジ角度スライダーを出す手順 |
| [.cursor/skills/app-resizability/](.cursor/skills/app-resizability/) | Cursor Agent 用に配置した公式スキル本体 |

## 参考にした動画

海外の iPhone Duo / SwiftUI 解説（コード断片のメモ元）:

https://youtu.be/gn8dLvJ9hx4?si=JiWe_-EDj7jYMxRY

---

## iPhone Duo で押さえておくこと（超要約）

Apple の [Prepare - iPhone Duo](https://developer.apple.com/iphone-duo/prepare/) では、SDK の世代ごとに Duo 上の見え方が変わります。

- **iOS 27.1 SDK 以降**でビルドすると、内側ディスプレイで **タブバー・ツールバーが縦配置**（ステータスバー下）など、Duo 向けに最適化された UI になります。
- 画面サイズは **折りたたみ・展開で実行中に変わる**ため、`UIScreen.main` や端末向きだけに依存したレイアウトは避けるのが原則です（レガシー移行は [app-resizability スキル解説](docs/app-resizability-skill.md) 参照）。

本 README のコードは **API の使い方メモ**です。実際のアプリでは 1 つの `ContentView` に全部を詰め込まず、タブごとに画面を分ける想定です。

---

## ArrangementView

折りたたみ時の **プライマリ / セカンダリ** 2 画面を、size class・向き・Reserved Region（折り目）に応じて並べ替えるコンテナです。

- 公式: [ArrangementView（SwiftUI）](https://developer.apple.com/jp/documentation/swiftui/arrangementview)
- Tech Talk: [Strike a pose with adaptive layouts on iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111463/)

### スタイル

| スタイル | ざっくりした動き |
|----------|------------------|
| **`.overlay`** | 平坦時は Z 方向に重ね、折りたたみ時に横または縦に並べる。メディアプレーヤー（映像 + 上にコントロール）向き |
| **`.split`** | 常に 2 領域に分割（iPad の分割に近いイメージ） |

**注意:** Apple は **`ArrangementView` の内側に `TabView` や `NavigationSplitView` を置かない** こと、逆に **`TabView` の中に `ArrangementView` を入れる** 構成を推奨しています。下の例は「タブの 1 画面の中身」として使う想定です。

### オーバーレイの配置（サンプル）

オーバーレイ配置では、プライマリがセカンダリの **上（手前）** に載ります。全画面メディア + 再生 UI のような関係向けです。

```swift
import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            Tab("Demo", systemImage: "rectangle.split.2x1") {
                ArrangementView {
                    Color.red
                } secondary: {
                    Color.blue
                }
                .arrangementViewStyle(.overlay)
            }
        }
    }
}

#Preview {
    ContentView()
}
```

---

## TabView と Tab（iOS 26+ / Duo 向け）

`Tab("タイトル", systemImage:)`  initializer を **`TabView` の直下** に並べるのが正しい形です。**`TabView` を二重にネストしない** でください（内側のタブバーだけが変な位置に描画され、アイコンが表示されない原因になります）。

### タブを縦向き（Duo デフォルト寄り）

iOS 27.1+ SDK で iPhone Duo 上では、システムが **縦方向のタブバー** を選びやすくなります。修飾子なしの例:

```swift
import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                Text("Home")
            }
            Tab("Favorites", systemImage: "heart") {
                Text("Favorites")
            }
            Tab("Settings", systemImage: "gear") {
                Text("Settings")
            }
        }
    }
}

#Preview {
    ContentView()
}
```

各タブの `{}` が空だとメイン領域が真っ白になります。動作確認時は `Text` など最低限の中身を入れてください。

### タブを横向き（従来に近いタブバー）

縦タブを抑え、横方向のタブバーに近づけたい場合:

```swift
import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                Text("Home")
            }
            Tab("Favorites", systemImage: "heart") {
                Text("Favorites")
            }
            Tab("Settings", systemImage: "gear") {
                Text("Settings")
            }
        }
        .toolbarVerticalBehavior(.disabled)
    }
}

#Preview {
    ContentView()
}
```

---

## ヒンジ API（`onHingeChange` / `DeviceHinge`）

ヒンジの **離散的な状態**（閉 / 部分開き / 全開）と **連続的な角度** をアプリから読めます。SwiftUI では `.onHingeChange`、UIKit では `UIHingeInteraction` が対応 API です。

- Tech Talk: [Leverage multiple displays and scenes on iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111464/)
- Explore SwiftUI 例: [Hinge State](https://exploreswiftui.com/duo?element=249)

| プロパティ | 用途の目安 |
|------------|------------|
| `hinge.status` | レイアウト切替・表示モード（`.closed` / `.partiallyOpen` / `.fullyOpen`） |
| `hinge.angle` | エフェクト・インタラクション（ワーミーバー的な連続値など） |

`DeviceHinge.Status` は enum ではなく struct の静的メンバー比較のため、`switch` には **`default`** を付けます。`hinge == nil` は **ヒンジ非搭載端末**（通常 iPhone や Preview）を意味します。

### リポジトリの実装（ContentView）

現在の [ContentView.swift](iPhoneDuoDemo/ContentView.swift) は次のパターンです。

```swift
import SwiftUI

struct ContentView: View {
    @State private var hinge: DeviceHinge?

    var body: some View {
        VStack {
            if let hinge {
                switch hinge.status {
                case .closed:
                    Text("Closed")
                case .fullyOpen:
                    Text("Fully Open")
                case .partiallyOpen:
                    Text("Partially Open")
                default:
                    Text("Unknown")
                }

                Text("Angle: \(hinge.angle.degrees, specifier: "%.1f")°")
            }
        }
        .onHingeChange { _, newContext in
            hinge = newContext.hinge
        }
    }
}
```

**シミュレータで値が出ないとき**

1. Run 先が **iPhone Duo** か確認する。
2. Device Hub ベゼル下で **Partially Open** を押す、または **Option（⌥）キーを押しながら** 角度スライダーをドラッグする（スライダーは常時表示されません）。詳細は [docs/iphone-duo-hinge-slider.md](docs/iphone-duo-hinge-slider.md)。
3. `onHingeChange` は **変化時** に呼ばれるため、起動直後は `hinge` が `nil` で画面が空に見えることがあります。一度ポーズやスライダーを動かしてください。

---

## Cursor と app-resizability スキル

[Prepare - iPhone Duo](https://developer.apple.com/iphone-duo/prepare/) Step 1 で案内されている **app-resizability** スキルを `.cursor/skills/` に置いてあります。Agent モードで次のように頼むと、UIKit レガシー API のスキャンや Duo 向けリサイズ準備のワークフローが走ります。

- `get my app ready for iPhone Duo`
- `iPhone Duo 向けにリサイズ対応をチェックして`

本リポジトリは SwiftUI 中心のため、**コード修正は少なく設定チェックの報告が中心**になりやすい点は [docs/app-resizability-skill.md](docs/app-resizability-skill.md) に整理しています。

スキルの更新:

```bash
xcrun agent skills export \
  --output-dir /path/to/staging/skills \
  --replace-existing
```

export した `app-resizability` フォルダで `.cursor/skills/app-resizability` を差し替えます。

---

## 公式リンク集

| タイトル | URL |
|----------|-----|
| Prepare - iPhone Duo | https://developer.apple.com/iphone-duo/prepare/ |
| ArrangementView | https://developer.apple.com/jp/documentation/swiftui/arrangementview |
| Interacting with your app in Device Hub | https://developer.apple.com/documentation/xcode/interacting-with-your-app-in-device-hub |

---

**更新:** 2026-10-21（水）
