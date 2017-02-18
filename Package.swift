import PackageDescription

let package = Package(
    name: "NuclearError",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/antitypical/Result.git",
                 majorVersion: 3)
    ]
)