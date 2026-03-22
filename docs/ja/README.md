<div align="center">
  <img src="../../assets/icon.svg" alt="Cleanlock icon" width="64">

# Cleanlock

**macOS向けのミニマルな画面クリーニングツール**

Cleanlock を起動すると画面が真っ黒になり、キーボード入力も一時的に無効化されるため、MacBook の画面やキーボードを誤操作せずに拭き取れます。

[**English**](../../README.md) | [**简体中文**](../zh-CN/README.md) | [**日本語**]

---

</div>

## 画面イメージ

![Interface](../../assets/interface.png)

## 動作環境

macOS Tahoe 26.0 以降

Liquid Glass が大好きです d(^_^o)

## ダウンロード

最新バージョンは [Releases](https://github.com/bailitaotao/cleanlock/releases) ページからダウンロードできます。

また、最低 macOS 12 まで対応した旧環境向けビルドも用意していますが、今後は更新や保守を行わず、使用感もやや劣ります：
[Cleanlock.1.1.0-legacy.dmg](https://github.com/bailitaotao/cleanlock/releases/download/v1.1.0/Cleanlock.1.1.0-legacy.dmg)

## 旧バージョンの macOS で自分でビルドする

macOS がそこまで古くなくても、Liquid Glass スタイルを使いたくない場合は、少し修正して自分でビルドできます。

> 1. 次の 3 ファイルを開きます:
> - `ContentView.swift`
> - `CleaningOverlayView.swift`
> - `AccessibilityPermissionView.swift`
> 2. 古い macOS でも使えるボタンスタイルに変更します:
>    - `.buttonStyle(...)` 内で使っている `glass` をすべて `bordered` に置き換えます
> 3. Xcode 左側の **Project Navigator** でプロジェクト（`cleanlock`）を選択します
> 4. **General** タブを開き、**Minimum Deployments** を対象の macOS バージョンに変更します

## ライセンス

このプロジェクトは MIT License のもとで公開されています。詳しくは [LICENSE](../../LICENSE) を参照してください。
