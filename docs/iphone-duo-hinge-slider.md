# iPhone Duo シミュレータでヒンジ角度スライダーを出す

## はじめに

Xcode 27 以降、従来の **Simulator.app** 単体ではなく **Device Hub** 上で iPhone Duo を操作します。デモ動画でよく見る **0°〜180° のヒンジスライダー（ゲージ）** は Device Hub に組み込まれていますが、**通常は非表示**で、**Option（⌥）キー** を押している間だけポーズボタンがスライダーに切り替わります。

この記事は、スライダーの出し方、3 つのポーズボタンとの違い、アプリ側（`onHingeChange`）で値が更新されないときの切り分けをまとめた **docs 用テキスト** です。

**動作検証環境（本リポジトリ）:** Xcode 27.2 RC、iOS 27.2、iPhone Duo シミュレータ

---

## 前提条件

| 項目 | 必要な状態 |
|------|------------|
| Xcode | **27.1 以降**（27.2 RC 可） |
| シミュレータ | **iPhone Duo**（通常の iPhone 16 等ではヒンジなし） |
| UI | **Device Hub** のキャンバス（アプリ Run 後に表示） |
| アプリ API | `onHingeChange` / `DeviceHinge` は **iOS 27.1+** |

SwiftUI Preview や iPhone Duo 以外の端末では、ヒンジは常に `nil` です。

---

## ヒンジスライダーを表示する手順

1. Xcode でターゲット **iPhone Duo · iOS 27.x** を選び **Run** する。
2. **Device Hub** が開き、シミュレータ画面がキャンバスに表示される。
3. 画面ベゼルの**下**にある **デバイスポーズ用のボタン列** を確認する（回転ボタンの近く）。
4. Device Hub / シミュレータウィンドウに **フォーカス** を置く。
5. そのボタン列の上にポインタを置いたまま **`Option（⌥）` キーを押し続ける**。
6. **Closed / Partially Open / Open** の 3 ボタンが **角度スライダー** に変わる。
7. スライダーを **ドラッグ** して 0°（閉）〜 180°（平坦）の任意角度にする。
8. **`Option` を離す**と、再び 3 つのポーズボタンに戻る。

Apple の Device Hub ドキュメントでも、iPhone Duo ではベゼル下のポーズ操作のほか、**Option を押しながらベゼル下をドラッグして任意角度に折る**操作が説明されています。

- [Interacting with your app in Device Hub](https://developer.apple.com/documentation/xcode/interacting-with-your-app-in-device-hub)（iPhone Duo シミュレータの項）

公式 UI ではスライダーは常時表示されないため、動画と見え方が違うと感じる場合は **⌥ キー** の有無が第一の確認ポイントです。

---

## 3 つのポーズボタン（スライダーなし）

スライダーを使わなくても、同じバー上のボタンで離散的な状態を試せます。

| ボタン | おおよその意味 |
|--------|----------------|
| **Closed** | 閉じた状態（外側ディスプレイ寄りの体験） |
| **Partially Open** | 部分開き（ヒンジ `status` が `.partiallyOpen` になりやすい） |
| **Open** | 全開（平坦・内側ディスプレイ寄り） |

連続的な角度変化や `DeviceHinge.angle` の細かいテストには **Option + スライダー** を使います。

---

## スライダーやボタンが見えない・効かないとき

### Device Hub の表示

- コントロールが小さい場合は **「Expand to view all controls」** で拡大表示する。
- メニュー **View → Show Bezels** でベゼルと下の操作バーが表示されているか確認する。

### デバイスとフォーカス

- サイドバー・ウィンドウ左上が **iPhone Duo** になっているか確認する。
- **Option** は Device Hub がアクティブな状態で押す（他アプリにフォーカスがあると効かないことがある）。

### Xcode 27 のキーボードショートカット

Device Hub ではショートカットの取り込み方が Simulator 時代と異なります。外観切替（`⇧⌘A`）などと同様、フォーカスや表示モードの影響を受けることがあります。ヒンジ操作自体は **マウス + Option + スライダー** が基本です。

---

## アプリ側：`onHingeChange` で画面が真っ白・角度が動かない

本リポジトリの [ContentView.swift](../iPhoneDuoDemo/ContentView.swift) は次のパターンです。

```swift
.onHingeChange { _, newContext in
    hinge = newContext.hinge
}
```

### ヒンジが `nil` のまま

- **iPhone Duo 以外**で Run している。
- **Preview** のみで見ている。
- **`onHingeChange` は変化時に呼ばれる** — 起動直後は一度も来ず、`hinge` が `nil` のまま UI が空になることがある。

**対処:** Device Hub で **Partially Open** を押すか、**Option + スライダー** で角度を動かして最初のイベントを発生させる。ヒンジ非対応時用に `else` で「Hinge Unavailable」等を表示しておくと切り分けしやすい。

### スライダーは動くがアプリの数値が変わらない

- シミュレータのポーズは変えているが、**Option スライダー** ではなくボタンのみ、など — 角度の連続更新はスライダー側で試す。
- ビルドターゲットの **Deployment Target** が 27.1 未満になっていないか確認する。

### `status` と `angle` の使い分け（実装のヒント）

Apple の Tech Talk では、ヒンジの **離散的な状態**（closed / partially open / fully open）は `status`、**連続的な効果**（アニメーションやピッチベンドなど）に `angle` を使う例が示されています。

- [Leverage multiple displays and scenes on iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111464/)

シミュレータでは、角度と `status` の対応が操作の仕方（ドラッグ vs クリック）で変わる、という実測メモも公開されています。**レイアウトの分岐は `angle` の閾値より `status` とシーンサイズを優先**する設計が安全です。

---

## 角度の目安（スライダー）

| 角度（目安） | イメージ |
|--------------|----------|
| **0°** | 閉じた状態 |
| **90° 付近** | 半開き（テスト用の中間） |
| **180°** | 全開・平坦 |

`DeviceHinge.Status` は enum ではなく struct の静的メンバー比較のため、`switch` には **`default`** を残すのが一般的です。

---

## CLI で角度を送る（参考）

Device Hub のスライダーに公式の `simctl` 一発コマンドはありません。スクリプトや CI 向けに、コミュニティ製の **`hinge` CLI** で同種の HID イベントを送る方法があります（Xcode 27.1 + ブート済み iPhone Duo が前提）。

- [artemnovichkov/hinge](https://github.com/artemnovichkov/hinge)

```bash
hinge 120      # 120° に設定
hinge get      # 現在角度を表示
hinge sweep 180 0 2   # 2 秒かけて 180° → 0°
```

**注意:** 非公開プロトコル依存のため、Xcode / ランタイム更新で動かなくなる可能性があります。日常の UI 確認は **Device Hub + Option スライダー** を優先してください。

---

## チェックリスト（最短）

1. Run 先は **iPhone Duo** か
2. **Device Hub** のベゼル**下**にポーズバーがあるか（Expand / Show Bezels）
3. バー上で **⌥ を押したまま** スライダーが出るか
4. スライダーをドラッグしたあと、アプリの **Angle / status** が変わるか
5. 変わらなければ **Partially Open** ボタンで `onHingeChange` が一度でも走るか

---

## 関連ドキュメント

| 内容 | リンク |
|------|--------|
| 本リポジトリ README（ヒンジ API メモ） | [../README.md](../README.md) |
| app-resizability スキル解説 | [app-resizability-skill.md](./app-resizability-skill.md) |
| Prepare - iPhone Duo | https://developer.apple.com/iphone-duo/prepare/ |
| Explore SwiftUI — Hinge State 例 | https://exploreswiftui.com/duo?element=249 |

---

*記事用テキスト — iPhoneDuoDemo / Device Hub ヒンジスライダー*
