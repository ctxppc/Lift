// Lift © 2017 The Imaginary Lift Committee

import Foundation
import DepthKit

/// A container of compilation units.
public final class LexicalModule : Codable {
	
	/// Creates a lexical module from a persistent representation.
	///
	/// - Parameter representationURL: An absolute URL to the directory containing the module's persistent representation.
	public init(contentsOf representationURL: URL) {
		TODO.unimplemented
	}
	
	/// The URL to the directory containing the module's persistent representation, if such a representation is associated with the lexical module.
	///
	/// - Invariant: If set, `representationURL` is an absolute URL.
	public var representationURL: URL?
	
	/// The compilation units in the module.
	public private(set) var compilationUnits: [CompilationUnit]
	
}
