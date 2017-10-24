// swift-tools-version:4.0
// Lift © 2017 The Imaginary Lift Committee

import PackageDescription

let package = Package(
	
	name: "Lift",
	
	products: [
		
		// The Lift library contains the full Lift compiler.
		.library(name: "Lift", targets: ["Lift"])
		
	],
	
	dependencies: [
		.package(url: "https://github.com/ctxppc/DepthKit.git", from: "0.4.0")
	],
	
	targets: [
		.target(name: "Lift", dependencies: ["DepthKit"], path: "Sources"),
		.testTarget(name: "Lift Tests", dependencies: ["Lift"], path: "Tests"),
	]
	
)
