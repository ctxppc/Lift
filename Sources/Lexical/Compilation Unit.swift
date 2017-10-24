// Lift © 2017 The Imaginary Lift Committee

import Foundation
import DepthKit

/// A container of lexical tokens, compiled as part of a lexical module.
///
/// A lexical compilation unit is the lexical module equivalent of a source file, except that a compilation unit doesn't require a persistent representation. A compilation unit can also be created from a string.
///
/// A compilation unit has no knowledge beyond what a context-free grammar can describe. It can distinguish between keywords, operators, and identifiers but it does not form syntactical units such as declarations or expressions.
public final class CompilationUnit : Codable {
	
	/// Creates a blank compilation unit.
	///
	/// - Parameter module: The lexical module wherein the compilation unit is contained.
	internal init(module: LexicalModule) {
		self.module = module
		self.representationURL = nil
	}
	
	/// Creates a compilation unit from a persistent representation.
	///
	/// This initialiser does not load automatically. Call `loadPersistentRepresentation()` after initialisation to load.
	///
	/// - Parameter representationURL: The URL to the file containing the unit's persistent representation.
	/// - Parameter module: The lexical module wherein the compilation unit is contained.
	internal init(at representationURL: URL, in module: LexicalModule) {
		self.module = module
		self.representationURL = representationURL
	}
	
	/// The lexical module wherein the compilation unit is contained.
	public unowned let module: LexicalModule
	
	/// The URL to the file containing the unit's persistent representation, if such a representation is associated with the compilation unit.
	///
	/// URLs are resolved relative to the lexical module's persistent representation URL. If the lexical module has no associated persistent representation, the value of this property is ignored.
	///
	/// - Note: Changing this property does not automatically update the compilation unit's internal representation. Call `loadPersistentRepresentation()` after changing this property to update it.
	///
	/// - Invariant: If set, `representationURL` is a relative URL.
	public var representationURL: URL?
	
	/// The lexical representation, if any.
	///
	/// A compilation unit's representation typically mirrors the contents of the physical representation if one is assigned to the unit, but clients of the lexical module can modify the compilation unit's representation.
	public private(set) var representation: String?
	
	/// Loads the persistent representation, replacing the current representation.
	///
	/// This method opportunistically invalidates any references to the compilation unit that may become invalid. No references are invalidated if the persistent and loaded representations are equal.
	///
	/// - Throws: An error if the persistent representation couldn't be loaded or if no representation URL has been set on the compilation unit.
	public func loadPersistentRepresentation() throws {
		TODO.unimplemented
	}
	
	/// Replaces the current representation.
	///
	/// This method opportunistically invalidates any references to the compilation unit that may become invalid. No references are invalidated if the new representation is equal to the current.
	public func replaceRepresentation(with newRepresentation: String) {
		TODO.unimplemented
		representation = newRepresentation
	}
	
	/// Removes the representation and invalidates all references to the compilation unit's content.
	public func removeRepresentation() {
		TODO.unimplemented
		representation = nil
	}
	
}
