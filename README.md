<div align="center">
    <img src="https://logsnag.com/og-image.png" alt="LogSnag"/>
    <br>
    <h1>LogSnag Swift</h1>
    <p>Get notifications and track your project events.</p>
    <a href="https://discord.gg/dY3pRxgWua"><img src="https://img.shields.io/discord/922560704454750245?color=%237289DA&label=Discord" alt="Discord"></a>
    <a href="https://docs.logsnag.com"><img src="https://img.shields.io/badge/Docs-LogSnag" alt="Documentation"></a>
    <br>
    <br>
</div>


## Installation

### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/LinusGeffarth/logsnag-swift.git`
- Select "Up to Next Major" with "1.0.0"

## Usage

### Import Library

```swift
import LogSnag
```

### Initialize Client

```swift
let logsnag = LogSnagClient(
    project: "my-sass",
    token: "7f568d735724351757637b1dbf108e5"
)
```

### Publish Event

#### `async/await`

```swift
let success = try await logsnag.asyncPublish(
    options: PublishOptions(
        channel: "waitlist",
        event: "User Joined",
        icon: "🎉",
        notify: true,
        tags: [
            "source": "social_media"
        ]
    )
)
```

#### Combine

```swift
logsnag.publish(
    options: PublishOptions(
        channel: "waitlist",
        event: "User Joined",
        icon: "🎉",
        notify: true,
        tags: [
            "source": "social_media"
        ]
    )
)
.sink(
    receiveCompletion: { _ in },
    receiveValue: { _ in }
)
.store(in: &cancellables)
```

