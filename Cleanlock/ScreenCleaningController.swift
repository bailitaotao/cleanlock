import AppKit
import ApplicationServices
import Combine
import SwiftUI

/// 清洁模式的控制器：
/// - 创建/销毁全屏黑屏窗口
/// - 检查辅助功能权限
/// - 安装低层键盘事件拦截
@MainActor
final class ScreenCleaningController: ObservableObject {
    /// 暴露给 SwiftUI 的状态，用来控制主界面按钮是否可点。
    @Published private(set) var isCleaning = false
    @Published private(set) var hasAccessibilityAccess = false

    /// 承载黑屏界面的 AppKit 窗口。
    private var blackoutWindow: BlackoutWindow?

    /// Quartz 事件 tap，本质上是一个低层输入拦截点。
    private var eventTap: CFMachPort?

    /// 事件 tap 必须挂到 run loop 上才能开始工作。
    private var eventTapSource: CFRunLoopSource?

    init() {
        refreshAccessibilityAccessStatus()
    }

    /// 开启清洁模式。
    /// 这里先过权限，再显示黑屏窗口，最后打开键盘拦截。
    func startCleaning() {
        guard !isCleaning else { return }
        guard hasAccessibilityAccess else { return }
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return }

        let window = BlackoutWindow(screen: screen)
        let rootView = CleaningOverlayView { [weak self] in
            self?.stopCleaning()
        }

        window.contentView = NSHostingView(rootView: rootView)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        blackoutWindow = window
        installEventTap()
        isCleaning = true
    }

    /// 检查辅助功能权限。
    /// 没有这个权限时，普通用户态应用拿不到稳定的低层键盘事件。
    func refreshAccessibilityAccessStatus() {
        hasAccessibilityAccess = AXIsProcessTrusted()
    }

    func requestAccessibilityAccess() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        hasAccessibilityAccess = AXIsProcessTrustedWithOptions(options)
    }

    /// 安装低层事件 tap。
    /// Swift 对象 -> Core Foundation Mach Port -> Run Loop。
    private func installEventTap() {
        stopEventTap()

        // CGEventTap 的回调是 C 风格函数签名，不能直接捕获 Swift 对象，
        // 要把 self 先转成裸指针，通过 userInfo 传进去。
        let userInfo = Unmanaged.passUnretained(self).toOpaque()
        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            guard let userInfo else {
                return Unmanaged.passRetained(event)
            }

            // 再把裸指针还原成 ScreenCleaningController，交给实例方法处理。
            let controller = Unmanaged<ScreenCleaningController>
                .fromOpaque(userInfo)
                .takeUnretainedValue()

            return controller.handleEventTap(type: type, event: event)
        }

        guard let eventTap = makeEventTap(callback: callback, userInfo: userInfo) else {
            return
        }

        // 事件 tap 创建出来后不会自动生效，必须接进主 run loop。
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        self.eventTap = eventTap
        eventTapSource = source
    }

    /// 创建事件 tap。
    /// 这里先尝试更低层的 HID tap，失败后再回退到 session tap。
    /// 原因是 HID tap 更强，但普通用户态不一定总能拿到。
    private func makeEventTap(
        callback: @escaping CGEventTapCallBack,
        userInfo: UnsafeMutableRawPointer
    ) -> CFMachPort? {
        let eventTypes: [CGEventType] = [.keyDown, .keyUp, .flagsChanged]
        let mask = eventTypes.reduce(CGEventMask(0)) { partialResult, type in
            partialResult | eventMask(for: type)
        } | eventMaskForSystemDefined

        // 先尝试更低层的 HID tap；普通用户通常拿不到，再回退到 session tap。
        return CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: userInfo
        ) ?? CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: userInfo
        )
    }

    /// 把某种事件类型转成 event tap 需要的位掩码。
    private func eventMask(for type: CGEventType) -> CGEventMask {
        1 << type.rawValue
    }

    /// 媒体键在 AppKit 里常见为 `systemDefined` 事件。
    /// CoreGraphics 没有直接暴露对应 case，这里使用它的 raw value 14 参与拦截。
    private var eventMaskForSystemDefined: CGEventMask {
        1 << 14
    }

    /// 处理进入 event tap 的每一个低层键盘事件。
    /// 返回 `nil` 表示直接丢弃事件，也就是“禁用这个按键”。
    private func handleEventTap(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        // 某些情况下系统会临时停用 tap，这里检测到后马上重新开启。
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }

            return Unmanaged.passRetained(event)
        }

        guard isCleaning else {
            return Unmanaged.passRetained(event)
        }

        return nil
    }

    /// 退出清洁模式，恢复正常键盘输入并关闭黑屏窗口。
    func stopCleaning() {
        guard isCleaning else { return }
        stopEventTap()
        blackoutWindow?.orderOut(nil)
        blackoutWindow = nil
        isCleaning = false
    }

    /// 卸载事件 tap。
    private func stopEventTap() {
        if let source = eventTapSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
            eventTapSource = nil
        }

        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
        }
    }

    /// 对象释放前主动拆掉事件 tap，避免继续拦截系统输入。
    deinit {
        MainActor.assumeIsolated {
            stopEventTap()
        }
    }
}

/// 黑屏用的无边框窗口。
@MainActor
private final class BlackoutWindow: NSWindow {
    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        setFrame(screen.frame, display: true)
        backgroundColor = .black
        level = .screenSaver
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isOpaque = true
        hasShadow = false
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
    }

    /// 无边框窗口默认不一定能接收键盘输入，这里显式打开。
    override var canBecomeKey: Bool { true }

    /// 允许它成为主窗口，避免部分窗口行为受限。
    override var canBecomeMain: Bool { true }
}
