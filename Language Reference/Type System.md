# The type system
Lift's main focus of improvement over many other languages is the type system. It's designed to remain minimally present in code yet to be deeply immersed in the meaning of the code. The type system tries to contain as much static information as it can in every variable of the program. This can be as simple as a simple type (e.g., `Int` for integers) to as advanced as a constructed dependent type (e.g., `Vector<of: String, length: 6>` for a list of 6 strings). This section summarily discusses values, types, and kinds in the Lift type system.

## Values
### Constants
A **constant** is a symbol that is assigned to a fixed value. They're defined outside of a type or function and their value must be computable at compile-time.

	let π = 3.141592
	let minimalNumberOfPlayers = 6

### Parameters
A **type parameter** is a symbol in a type definition that is assigned to a value that depends on the *type*. In the example below, two vector types may have different lengths; hence `length` is a type parameter of `Vector`. The length of a vector is an intrinsic property of a vector type, unlike arrays which are of variable length.

	struct Vector {
		type let length: Int
	}

A type parameter's value must be fixed at type construction, i.e., within a `type init`.

An **instance parameter**, or *property*, is a symbol in a type definition that is assigned to a value that depends on the *instance*. In the example below, two people may have different names; hence `name` is a type parameter of `Person`.

	struct Person {
		let name: String
	}

An instance parameter's value must be fixed at instance construction, i.e., within an `init`.

A **variable instance parameter**, or *instance variable* or *variable property*, is a instance parameter that can be assigned to a different value after initialisation. Reassignment is syntactic sugar for creating a different value in place with the new argument, given Lift's value semantics.

	struct Message {
		var title: String
		var content: String
		var author: String
	}

A **computed instance parameter** is defined as an expression that depends on other parameters of the instance.

	struct Message {
		…
		var fullBody = """
			\(title)
			\(author)
			==========
			\(content)
			"""
	}

If the expression uses constants, the computed parameter can be specified using `let`.

A **function parameter** (or method parameter) is a symbol in a function (or method) definition that is assigned to a value when the function (or method) is invoked.

	func sum(firstTerm: Int, secondTerm: Int) -> Int {
		…
	}

The actual value of a type, instance, function, or method parameter is referred to as the **argument**.

### Constrained parameters
Every parameter can be constrained with a `where` clause after the type; each constraint separated by a comma.

Constraints on type parameters are statically checked; an unsatisfied type constraint is a compile-time error.

	struct Vector {
		type init(of Element: Any.Type, length: Int)
		type let Element: Any.Type
		type let length: Int where length >= 0
	}
	
	let vector: Vector<of: String, length: -1>	// error: unsatisfiable constraint length >= 0

Constraints on instance parameters are dynamically checked; the compiler may provide a warning if it can determine that a constraint cannot be met in any circumstance.

	struct Person {
		type init(name: String) where name.count > 0
		var name: String where name.count > 0
	}
	
	var person = Person(name: "John")
	person.name = ""								// runtime failure: unsatisfied constraint name.count > 0

Constraints on function and method parameters are checked statically for type functions and dynamically for other functions, and analogous to type and instance parameter constraints.

	operator func / (dividend: Int, divisor: Int) -> Int where divisor != 0
	
	let quotient = 5 / 0							// runtime failure: unsatisfied constraint divisor != 0

Statically checked constraints, i.e., constraints on type parameters and type functions, may only refer to other type parameters and only invoke type and static functions.

### Variables
A **variable** is a symbol in a function definition that is assigned to a value that can vary. A variable can be assigned and re-assigned a value using the `=` operator. The value does not change between two assignments. Variables are not supported outside of functions due to Lift's value semantics. The value of the variable can be left undetermined until its first use.

	var score: Int
	score = 50
	leadingScores.insert(score)
	score = 60
	// leadingScores contains 50

An initial value can also be assigned during definition. In that case, the type can be inferred, just like in constants.

	var score = 50

### `self`
Within a method, the special value `self` refers to the subject of the method invocation. `self` is always of type `Self` (see below).

	struct Transaction {
		var amount: DecimalNumber
		mutating func doubleAmount() {
			self.amount *= 2
		}
	}

## Types
A **type** describes a set of all possible values (the **instances** of the type) a constant, variable, or parameter can take. The type is written after `:` in a constant, variable, or parameter declaration, unless it is to be inferred by the type system. A program must be well-defined for every possible value in every constant, variable, and parameter in the program, for every code path. For values that the program can't be meaningfully defined, it must define alternative actions such as throwing an error or raising a failure.

In the following example, the `/` operator function raises a failure for `denominator == 0`.

	let denominator: Int
	let result = 5 / denominator

### Type definitions
A **type definition** defines a new type, or set of types (see: protocols, parametric types), for use in the program. A type definition must have an identifier that is unique within the module; this symbol can be used anywhere in the rest of the module (as well as importing modules) to refer to the type definition.

A **structure type definition** defines a (set of) types with zero or more properties. The types defined by such a definition are essentially product types, since all possible values are formed by the Cartesian multiplication of all possible values of every property.

	struct Account {
		let number: Int
		var amount: DecimalNumber
	}

An **enumeration type definition** defines a (set of) types by explicitly listing its possible instances in the form of **cases**. A **simple case** has no parameters and represents one value, while a **parametric case** has a number of parameters. The types defined by an enumeration type definition are essentially sum types.

	enum Direction {
		case up
		case down
		case left
		case right
		case other(degrees: Number)
	}

### Parametric types
A **simple type definition** is a type definition with no type parameters. Such type definitions define exactly one type and can be used as is.

	enum Bool {
		case false
		case true
	}
	
	let truth: Bool

A **parametric type definition** is a type definition with at least one type parameter. Such definitions define multiple types (one for each possible value of every type parameter). To use a parametric type, it must be constructed using a type initialiser (`type init`) using the `Type<arguments>` syntax.

	struct Vector {
		type init(of Element: Any.Type, length: Int)
		type let Element: Any.Type
		type let length: Int
	}
	
	let voxel: Vector<of: Float, length: 3>

A type initialiser without (required) arguments can be invoked without `<arguments>`.

	struct Int {
		type init()
		type let numberOfWords: Int
	}
	
	let count: Int

A **first-order type parameter** is a type parameter whose arguments are values. A **second-order type parameter** is a type parameter whose arguments are types. In `Vector`, `length` is a first-order parameter and `Element` a second-order one. Conventionally, identifiers of type definitions and second-order type parameters are capitalised whereas identifiers of constants, variables, cases, functions, methods, and first-order parameters are not.

### `Self`
The special `Self` type within a type definition refers to the current type, with all the currently assigned type arguments.

	struct Array {
		…
		func appending(_ elements: Element) -> Self
		func appending(contentsOf array: Self) -> Self
		func removing(at index: Index) -> Self
	}

In a protocol (see below), `Self` refers to the current concrete type (which conforms to the protocol).

## Protocols
A **protocol** is a type definition that contains a lexical and semantical specification for **concrete type definitions** (i.e., structure en enumeration type definitions) to implement. Protocols enable powerful polymorphism by hiding concrete implementations behind an abstract specification.

A protocol is similar to a structure type definition, except that no implementation is provided.

	protocol Scalable {
		func scaled(by factor: Double) -> Self
	}

Conformance to one or more protocols is declared in concrete type definitions with `:`.

	struct Font : Scalable {
		var family: String
		var size: Int
		func scaled(by factor: Double) -> Self {
			return Font(family: family, size: size * factor)
		}
	}

Conformance can also be added in an extension.

	struct Rectangle : Scalable {
		var origin: Point
		var size: Vector<of: Int, length: 2>
	}
	
	extension Rectangle : Scalable {
		func scaled(by factor: Double) -> Self {
			return Rectangle(origin: origin, size: Vector(size[0] * factor, size[1] * factor))
		}
	}

A protocol can be used in a second-order type parameter to constrain the possible types that it can be assigned to.

	struct ScalableList {
		type let Element: Scalable.Type	
		// or type let Element: Any.Type where Element : Scalable
		let elements: Array<of: Element>
	}
	
	extension ScalableList : Scalable {
		func scaled(by factor: Double) -> Self {
			let scaledElements = elements.map { $0.scaled(by: factor) }
			return Self(elements: scaledElements)
		}
	}

A protocol can also be used in a parametric function.

	let helvetica = Font(family: "Helvetica Neue", size: 12)
	let table = Rectangle(origin: Point(0, 0), size: Vector(120, 60))
	
	func doubled<T : Scalable>(_ thing: T) -> T {
		return thing.scaled(by: 2)
	}
	
	let bigHelvetica = doubled(helvetica)	// Helvetica Neue, 24 pt
	let bigTable = doubled(table)			// origin: (0, 0), size: (240, 120)

## Existentials
(…)