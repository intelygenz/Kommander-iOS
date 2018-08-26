import PackageDescription

let package = Package(
  name: "Kommander",
  products: [
    .library(
        name: "Kommander",
        targets: ["Kommander"])
    ],
  dependencies : [],
  exclude: ["Major", "Major watchOS", "Major watchOS Extension", "MajorUITests", "KommanderTests"],
  targets: [
    .target(
        name: "Kommander",
        dependencies: []),
    .testTarget(
        name: "KommanderTests",
        dependencies: []),
    ]
)
