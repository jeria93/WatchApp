# 📱 WatchApp

**WatchApp** is an iPhone app built with **SwiftUI**.  
It shows movies from **TMDB** (The Movie Database) and lets users sign in with **Google** using **Firebase**.

> **Recommended setup:** Xcode **15.3** + iOS **17.4** (simulator and device) for the smoothest experience.

---

## What You Need Before You Start

| File you must add | Where to put it | Why you need it |
|-------------------|-----------------|-----------------|
| `Secrets.plist` | `WatchApp/Secrets.plist` | Stores your TMDB keys |
| `GoogleService-Info.plist` | `WatchApp/GoogleService-Info.plist` | Connects the app to your Firebase project |

> Both files are **ignored by Git** so they never reach GitHub.

---

## 🔗 Helpful Links

- **Trello board:** <https://trello.com/b/etXPclGH/scrum-board>  
- **Figma design:** <https://www.figma.com/design/R5LEJ8xC6wOMzuFNyiA1Gj>  
- **Firebase console:** <https://console.firebase.google.com/project/watchapp-ae584/overview>

---

## Step‑by‑Step Setup (Xcode only)

### 1 — Add `Secrets.plist`

1. Open the project in **Xcode 15.3**.  
2. In the left panel, right‑click **`WatchApp` -> New File… -> Property List**.  
3. Name the file **Secrets.plist**.  
4. Right‑click the new file → **Open As -> Source Code** and paste:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>TMDB_API_KEY</key>
    <string>PUT‑YOUR‑API‑KEY‑HERE</string>
    <key>TMDB_BEARER_TOKEN</key>
    <string>PUT‑YOUR‑BEARER‑TOKEN‑HERE</string>
</dict>
</plist>
```

*(Save it inside the **`WatchApp` folder**, not at project root.)*

### 2 — Add `GoogleService-Info.plist`

1. In **Firebase Console -> Project settings -> General -> Your apps** download the file.  
2. Drag‑and‑drop the file into the **`WatchApp` folder** in Xcode.  
3. Tick **“Copy items if needed”** and press **Finish**.

That’s it! Press **▶︎ Run** (or **⌘ R**) to build and launch the app.

---

## How Google Sign‑In Works (quick overview)

1. Google Sign‑In is enabled in Firebase Console.  
2. The app shows a Google login sheet (via **GoogleSignIn SDK**).  
3. After login, Google returns secure tokens.  
4. The app sends those tokens to Firebase to sign in the user.

```swift
let cred = GoogleAuthProvider.credential(withIDToken: idToken,
                                         accessToken: accessToken)
Auth.auth().signIn(with: cred) { result, error in
    // You are now signed in!
}
```

Keep `GoogleService-Info.plist` inside **`WatchApp/`** at all times.

---

## Run the App
1. Choose a simulator running **iOS 17.4** (e.g. **iPhone 15**).  
2. Press **⌘ R**. Enjoy!
