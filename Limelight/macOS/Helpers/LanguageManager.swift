//
//  LanguageManager.swift
//  Moonlight for macOS
//
//  Created by SkyHua on 2024/01/17.
//

import SwiftUI

@objcMembers
@objc(LanguageManager)
public class LanguageManager: NSObject, ObservableObject {
  public static let shared = LanguageManager()

  public override init() {
    super.init()
    updateAppLanguage(postNotification: false)
  }

  @objc(applyAppLanguage) public func applyAppLanguage() {
    updateAppLanguage(postNotification: true)
  }

  private func updateAppLanguage(postNotification: Bool) {
    UserDefaults.standard.set("English", forKey: "appLanguage")
    UserDefaults.standard.set(["en"], forKey: "AppleLanguages")

    guard postNotification else { return }
    NotificationCenter.default.post(name: .init("LanguageChanged"), object: nil)
  }

  private func localizedString(_ key: String, languageCode: String) -> String? {
    guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
      let bundle = Bundle(path: path)
    else {
      return nil
    }

    let val = NSLocalizedString(
      key, tableName: nil, bundle: bundle, value: "___MISSING___", comment: "")
    return val == "___MISSING___" ? nil : val
  }

  public func localize(_ key: String) -> String {
    if let val = en[key] { return val }
    if let val = localizedString(key, languageCode: "en") { return val }
    return key
  }

  private let en: [String: String] = [
    "Stream": "Stream",
    "Video and Audio": "Video and Audio",
    "Input": "Input",
    "App": "App",
    "Legacy": "Legacy",
    "General": "General",
    "Language": "Language",
    "System": "System (Default)",
    "Enable": "Enable",

    "Profile:": "Profile:",
    "Global": "Global",
    "Global (Default)": "Global (Default)",
    "Scope: Global": "Scope: Global",
    "Scope: Profile (%@)": "Scope: Profile (%@)",

    "Resolution and FPS": "Resolution and FPS",
    "Resolution": "Resolution",
    "Match Display": "Match Display",
    "Match Display Resolution hint": "Automatically matches the current screen size.",
    "Custom": "Custom",
    "Custom Resolution": "Custom Resolution",
    "Frame Rate": "Frame Rate",
    "FPS": "FPS",
    "Custom FPS": "Custom FPS",

    "Resolution Scale": "Resolution Scale",
    "Resolution Scale Ratio": "Resolution Scale Ratio",
    "Resolution & Scaling": "Resolution & Scaling",
    "Resolution Scale hint": "Reduces resolution to save bandwidth.",
    "Upscaling": "Upscaling",
    "Scale vs Upscaling hint": "Resolution Scale saves bandwidth. Upscaling improves reconstructed detail on the client.",
    "AI enhancement recommended hint": "Most useful when streaming below native resolution or at lower bitrate.",
    "Resolution Scale + Upscaling hint": "Tip: Lower host scale plus client upscaling can keep the image clearer at the same bandwidth.",
    "MetalFX requires macOS 13 or later.": "Requires macOS 13+.",

    "MetalFX Spatial (Quality)": "MetalFX (Quality)",
    "MetalFX Spatial (Performance)": "MetalFX (Performance)",
    "Auto Adjust Bitrate": "Auto Adjust Bitrate",
    "Ignore Aspect Ratio": "Ignore Aspect Ratio",
    "Show Local Cursor": "Show Local Cursor",
    "Mouse and Cursor": "Mouse & Cursor",
    "Locked Mouse": "Locked Mouse",
    "Free Mouse": "Free Mouse",
    "Control Center": "Control Center",
    "Locked Mouse hint": "Keeps the mouse locked to the stream. Best for games and camera control.",
    "Free Mouse hint": "Lets you switch back to macOS apps and displays more naturally. Best for desktop use.",
    "Current: %@": "Current: %@",
    "Switched to %@": "Switched to %@",

    "Remote Resolution": "Host Render Resolution",
    "Remote Resolution Value": "Host Render Resolution",
    "Remote Custom Resolution": "Host Custom Render Resolution",
    "Remote FPS": "Host Render FPS",
    "Remote FPS Value": "Host Render FPS",
    "Remote Custom FPS": "Host Custom Render FPS",
    "Remote overrides hint": "Forces the host to render at this value.",
    "Remote overrides apply to the host render mode only.":
      "Remote overrides apply to the host render mode only.",
    "Enable Remote Resolution/FPS to override the /launch mode parameter.":
      "Enable Remote Resolution/FPS to override the /launch mode parameter.",

    "Bitrate": "Bitrate",

    "Video": "Video",
    "Video Codec": "Video Codec",
    "Streaming Style": "Streaming Style",
    "Streaming Style detail": "Pick the overall feel first: lower latency, balanced, or smoother video.",
    "Timing": "Timing",
    "Compatibility & Troubleshooting": "Compatibility & Troubleshooting",
    "HDR": "HDR",
    "Frame Pacing": "Frame Pacing",
    "Lowest Latency": "Lower Latency",
    "Smoothest Video": "Smoother Video",

    "Audio": "Audio",
    "Audio Configuration": "Audio Configuration",
    "Stereo": "Stereo",
    "5.1 surround sound": "5.1 surround sound",
    "7.1 surround sound": "7.1 surround sound",
    "7.1.4 surround sound": "7.1.4 surround sound",
    "Sound Mode": "Sound Mode",
    "Default": "Default",
    "Audio Enhancement": "Audio Enhancement",
    "Listening Device": "Listening Device",
    "Automatic": "Automatic",
    "Headphones": "Headphones",
    "Speakers": "Speakers",
    "EQ Detail": "EQ Detail",
    "12-Band": "12-Band",
    "24-Band": "24-Band",
    "EQ Preset": "EQ Preset",
    "Reference": "Reference",
    "Immersive Gaming": "Immersive Gaming",
    "Dialogue Clarity": "Dialogue Clarity",
    "Bass Boost": "Bass Boost",
    "Reverb": "Reverb",
    "Harman Inspired": "Harman Inspired",
    "Music Warmth": "Music Warmth",
    "Vocal Presence": "Vocal Presence",
    "Air & Detail": "Air & Detail",
    "Closest to the stream itself with only light tonal shaping.":
      "Closest to the stream itself with only light tonal shaping.",
    "Wider positional cues with a little extra ambience for games.":
      "Wider positional cues with a little extra ambience for games.",
    "Pushes voices and lead detail forward while trimming boominess.":
      "Pushes voices and lead detail forward while trimming boominess.",
    "Adds fuller low end for music and cinematic impact without going too muddy.":
      "Adds fuller low end for music and cinematic impact without going too muddy.",
    "A tasteful bass shelf and upper-mid lift inspired by popular headphone targets.":
      "A tasteful bass shelf and upper-mid lift inspired by popular headphone targets.",
    "Smoother low mids and gentler highs for relaxed long-session listening.":
      "Smoother low mids and gentler highs for relaxed long-session listening.",
    "Lifts vocals and lead instruments for clearer mids and cleaner focus.":
      "Lifts vocals and lead instruments for clearer mids and cleaner focus.",
    "Opens up treble sparkle and perceived detail with a lighter low end.":
      "Opens up treble sparkle and perceived detail with a lighter low end.",
    "Spatial Intensity": "Spatial Intensity",
    "Soundstage Width": "Soundstage Width",
    "EQ": "EQ",
    "Multi-channel device detected. Use Default for true 5.1/7.1/7.1.4 playback, or Audio Enhancement for headphone/stereo virtualization.":
      "Multi-channel device detected. Use Default for true 5.1/7.1/7.1.4 playback, or Audio Enhancement for headphone/stereo virtualization.",
    "Play Sound on Host": "Play Sound on Host",
    "V-Sync": "V-Sync",
    "Performance Overlay": "Performance Overlay",
    "Performance Overlay (⌃⌥S)": "Performance Overlay (⌃⌥S)",
    "Show Connection Warnings": "Show Connection Warnings",
    "Unlock max bitrate (1000 Mbps)": "Unlock max bitrate (1000 Mbps)",
    "Volume": "Volume",

    "Controller": "Controller",
    "Multi-Controller Mode": "Multi-Controller Mode",
    "Single": "Single",
    "Auto": "Auto",
    "Rumble Controller": "Rumble Controller",
    "Buttons": "Buttons",
    "Swap A/B and X/Y Buttons": "Swap A/B and X/Y Buttons",
    "Emulate Guide Button": "Emulate Guide Button (Start + Select)",
    "Gamepad Mouse Emulation": "Gamepad Mouse Emulation",
    "Gamepad Mouse Hint": "Use the gamepad as a mouse. Right stick moves, A clicks.",
    "Drivers": "Drivers",
    "Advanced": "Advanced",
    "Controller Driver": "Controller Driver",
    "Mouse Driver": "Mouse Driver",
    "HID": "HID",
    "MFi": "MFi",
    "Keyboard": "Keyboard",
    "Capture system keyboard shortcuts": "Capture system keyboard shortcuts",
    "Shortcut Reference": "Stream Shortcuts",
    "Stream Shortcuts": "Stream Shortcuts",
    "Stream shortcut note": "These are your stream shortcuts. You can change the disconnect dialog, direct disconnect, quit, and more here.",
    "Change Shortcut": "Change Shortcut",
    "Press shortcut to record": "Press the shortcut you want to use now.",
    "Shortcut capture note": "Press Esc to cancel. Most actions use two modifiers. Disconnect options and quit can also use one.",
    "Restore Default Shortcut": "Restore Default",
    "Shortcut requires two modifiers": "Use at least two modifier keys for custom stream shortcuts.",
    "Shortcut must include regular key": "This action requires modifiers plus a regular key.",
    "Shortcut modifiers only required": "Release mouse capture only supports modifier-only shortcuts.",
    "Shortcut key unsupported": "Only letter and number keys are supported here.",
    "Shortcut already in use": "That shortcut is already assigned elsewhere.",
    "Shortcut reserved by system": "That shortcut is reserved by macOS or a built-in Moonlight action.",
    "Cancel": "Cancel",
    "Release mouse capture": "Release mouse capture",
    "Toggle performance overlay": "Toggle performance overlay",
    "Toggle mouse mode": "Toggle mouse mode",
    "Toggle fullscreen control ball": "Toggle fullscreen control ball",
    "Open control center": "Open control center",
    "Open control center (fullscreen / borderless only)": "Open control center (fullscreen / borderless only)",
    "Toggle borderless / windowed (advanced)": "Toggle borderless / windowed (advanced)",
    "Toggle blank host output": "Toggle blank host output",
    "Blank Host Output": "Blank Host Output",
    "Open Control Center: %@": "Open Control Center: %@",
    "Release mouse: %@": "Release mouse: %@",

    "Mouse": "Mouse",
    "Optimize mouse for remote desktop": "Optimize mouse for remote desktop",
    "Absolute Mouse Mode hint": "Best used in Remote Desktop mode. Game mode and some mouse drivers fall back to relative movement to avoid pointer lockups.",
    "Pointer Speed": "Pointer Speed",
    "Pointer Speed hint": "Adjusts relative mouse / trackpad speed. Doesn't affect absolute mouse mode.",
    "Swap Left and Right Mouse Buttons": "Swap Left and Right Mouse Buttons",
    "Reverse Mouse Scrolling Direction": "Reverse Mouse Scrolling Direction",
    "Touchscreen Mode": "Touchscreen Mode",
    "Trackpad": "Trackpad",
    "Touchscreen": "Touchscreen",
    "Frame updates paused": "Frame updates paused",
    "No new video frame has arrived for 15 seconds.": "No new video frame has arrived for 15 seconds.",
    "No new frame has arrived for a while.": "No new frame has arrived for a while.",
    "Manual mode won't change your resolution, frame rate, codec, or chroma automatically.":
      "Manual mode won't change your resolution, frame rate, codec, or chroma automatically.",
    "You can keep waiting, reconnect manually, or apply a recommended profile.":
      "You can keep waiting, reconnect manually, or apply a recommended profile.",
    "You can keep waiting or reconnect manually.":
      "You can keep waiting or reconnect manually.",

    "Behaviour": "Behaviour",
    "Default Display Mode": "Default Display Mode",
    "Windowed": "Windowed",
    "Fullscreen": "Fullscreen",
    "Borderless Windowed": "Borderless Windowed",
    "Automatically Fullscreen Stream Window": "Automatically Fullscreen Stream Window",
    "Quit App After Stream": "Quit App After Stream",
    "Visuals": "Visuals",
    "Dim Non-Hovered Apps": "Dim Non-Hovered Apps",
    "Custom Artwork Dimensions": "Custom Artwork Dimensions",

    "Geforce Experience": "Geforce Experience",
    "Optimize Game Settings": "Optimize Game Settings",

    "Mouse Mode On": "Mouse Mode On",
    "Mouse Mode Off": "Mouse Mode Off",

    "Not supported": "Not supported",
    "Settings": "Settings",

    // Connection Details
    "Connection Details": "Connection Details",
    "Basic Info": "Basic Info",
    "Host Name": "Host Name",
    "Status": "Status",
    "Online": "Online",
    "Offline": "Offline",
    "Unknown": "Unknown",
    "Pair State": "Pair State",
    "Paired": "Paired",
    "Unpaired": "Unpaired",
    "Network": "Network",
    "Active Address": "Active Address",
    "Local Address": "Local Address",
    "External Address": "External Address",
    "IPv6 Address": "IPv6 Address",
    "Manual Address": "Manual Address",
    "MAC Address": "MAC Address",
    "System Info": "System",
    "UUID": "UUID",
    "Running Game": "Running Game",
    "Latency": "Latency",
    "Close": "Close",

    // Host Sidebar & Overlays
    "Computers": "Computers",
    "Streaming Active": "Streaming Active",
    "Host: %@": "Host: %@",
    "App: %@": "App: %@",
    "Connected": "Connected",
    "Show Stream Window": "Show Stream Window",
    "Disconnect": "Disconnect",
    "Disconnect Alert": "Disconnect Alert",
    "Disconnect from Stream": "Disconnect from Stream",
    "Close and Quit App": "Close and Quit App",
    "Quit App": "Quit App",
    "%@ is Offline": "%@ is Offline",
    "Sending Wake-on-LAN packets...": "Sending Wake-on-LAN packets...",
    "This computer is currently offline or sleeping.": "This computer is currently offline or sleeping.",
    "Waking...": "Waking...",
    "Wake Host": "Wake Host",
    "Refresh Status": "Refresh Status",
    "Back to Computers": "Back to Computers",
    "Edit Connections": "Edit Connections",
    "Add Host Manually": "Add Host Manually",
    "Could not connect to host. Ensure GameStream is enabled in GeForce Experience on your PC.":
      "Could not connect to host. Ensure GameStream is enabled in GeForce Experience on your PC.",
  ]

}
