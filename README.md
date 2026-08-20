# Dozy

Objective-C dylib (`Mrzefv/`). Swizzles `UIWindow.makeKeyAndVisible` to:
- show a "piracy.digital / Mrzefv" onboarding splash once per install (local device info only — model, iOS version, arch, a random session id)
- attach a 2-finger tap anywhere in the app -> secret menu: pinned posts list + a "⋯" dev-tools sheet (Local P2P stub, Device Info)

No backend, nothing fetched or uploaded — everything is hardcoded.

## Build
Push to `main` or run the workflow manually from the Actions tab. GitHub Actions (macos-14) compiles `MRvEKUplink.dylib` from every `.m` file in `Mrzefv/`, fakesigns it with `ldid`, and uploads it as a build artifact.

Insert into a target app the same way as your other overlay dylibs — add the load command at resign time, `@rpath/MRvEKUplink.dylib`.
