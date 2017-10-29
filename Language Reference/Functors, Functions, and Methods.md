# Functors, functions, and methods
Lift is fundamentally a functional language. Almost everything is defined in terms of values that take arguments and return results. Lift prohibits (visible) side-effects and thus the result of every function is completely dependent on its arguments.

A **functor** is a value that takes an **argument**, performs some computation on it, and produces a **result**. Every functor is an instance of a concrete type that conforms to `Functor<from: Argument, to: Result, throws: failable>` where `Argument` is the type of the argument, `Result` is the type of the result, and `failable` is a Boolean value indicating whether the functor can throw an error instead of producing a result.

Concrete types of functors are functions, methods, property accessors, property mutators, subscript accessors, and subscript mutators. These types are briefly discussed in this document.

## Function
A **function** is a functor that is implemented as a series of operations. A function is defined with a `func` declaration outside of any type declaration.

	func sum(_ firstTerm: Int, _ secondTerm: Int) -> Int {
		return firstTerm + secondTerm
	}

## Method
A **method** is similar to a function but part of a type definition. Methods are **invoked on** a **subject**.