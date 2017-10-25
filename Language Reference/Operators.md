# Operators
An **operator** is a symbolic syntax for a function with one or two parameters, e.g., the operator `&&` in `a && b` instead of `and(a, b)`.

A **symbol** is a sequence of one or more characters (extended grapheme clusters) that denote the operator. In almost all cases, these characters are non-letter and non-numeric.

An operator is defined with an **operator definition**. The definition does not contain type information or an implementation. An **operator function** is a function for a previously defined operator that provides an implementation.

## Prefix & postfix operators
A **prefix operator** is an operator that is applied to one expression (the **operand**) by writing a symbol before the expression. Examples of prefix operators are `!` (Boolean negation) and `-` (numeric negation).

An operator declaration for a prefix operator is written with a `prefix operator` declaration.

	prefix operator !

An operator function for a prefix operator is written with a `prefix operator func` declaration.

	prefix operator func ! (operand: Bool) -> Bool {
		switch operand {
			case false:	return true
			case true:	return false
		}
	}

A **postfix operator** is similar to a prefix operator, except that its symbol written after the operand. Examples are `!` (forced unwrap) and `...` (lower-bounded open range).

	postfix operator !
	postfix operator func ! <Wrapped> (operand: Wrapped?) -> Wrapped where operand != nil {
		guard operand is .some(let value) else { raise UnwrappedNilFailure() }
		return value
	}

A prefix and postfix operator cannot be simultaneously applied on one expression.

	let optionalBoolean: Bool? = …
	let negatedBoolean = !optionalBoolean!	// error: ambiguous use of prefix operator ! and postfix operator !

Parentheses must be used to resolve the ambiguity.

	let negatedBoolean = !(optionalBoolean!)

## Infix operators
An **infix operator** is an operator applied to two operands with a symbol separating the operands. Examples of infix operators are `+` (numeric addition) and `..<` (half-open range).

When multiple infix operators are used in an expression, precedence and associativity rules define how the operators bind their operands. For example, `a + b * c` is equivalent to `a + (b * c)`; `*` has higher **precedence** than `+`. When multiple operators have the same precedence, associativity defines the direction in which the operators are applied. For example, `a + b + c` is equivalent to `(a + b) + c` because `+` is **left-associative**, while `A -> B -> C` is equivalent to `A -> (B -> C)` because `->` is **right-associative**.

Precedence and associativity is defined in terms of groups of operators called **operator classes**, even if a class contains one operator. Every infix operator belongs to exactly one operator class. For example, `+` en `-` are part of the `Additive` operator class.

Precedence relations between operator classes form a strict partial order. That is,

* every operator class has the same precedence as itself (associativity is used to further determine order of operations);
* two distinct operator classes cannot have the same precedence;
* if an operator class `A` has lower precedence than a class `B`, and `B` has lower precedence than a class `C`, then `A` has lower precedence than `C`; and
* two operator classes `A` and `B` may have incomparable precedence (requiring parentheses to disambiguate).

An operator class is defined with an `infix operator class` declaration. Any number of precedence relations can be declared using `lowerThan` and `higherThan`. If associativity is applicable on the operators of the class, it can be declared with `associativity` with either directions `left` or `right`.

	infix operator class Additive {
		lowerThan: Multiplicative
		associativity: left
	}

An infix operator is defined with an `infix operator` declaration, followed by the class after a `:`.

	infix operator + : Additive
	infix operator - : Additive
	infix operator * : Multiplicative
	infix operator / : Multiplicative

An operator function for an infix operator is written with an `infix operator func` declaration.

	infix operator func + (firstTerm: Int, otherTerm: Int) -> Int { … }

## Complex operators
A **complex operator** is an operator that consists of holes (represented by `_`) intertwined with symbols, e.g., the conditional operator `_ ? _ : _` and the subscript operator `_ [ _ ]`.

A complex operator is defined with a `complex operator` declaration.

	complex operator _ ? _ : _

An operator function for a complex operator is defined with a `complex operator func` declaration.

	complex operator func _ ? _ : _ <T> (condition: Bool, trueValue: autoclosure () -> T, falseValue: autoclosure () -> T) -> T {
		if condition {
			return trueValue()
		} else {
			return falseValue()
		}
	}

A complex operator cannot contain any symbol used by a prefix, infix, or postfix operator, nor any symbol that is part of any other complex operator. In addition, every symbol in a complex operator must be unique within the operator.

	complex operator _ ~ _ >>>		// error: symbol ~ conflicts with prefix operator ~
	complex operator _ ?? _ -- _		// error: symbol ?? conflicts with infix operator ??
	complex operator _ -- _ -- _		// error: multiple uses of symbol --

A complex operator must contain at least two symbols.

	complex operator _ ++			// error: prefix operator ++ defined as complex operator
	complex operator ++ _			// error: infix operator ++ defined as complex operator
	complex operator _ ++ _			// error: postfix operator ++ defined as complex operator

A complex operator must contain at least one hole.

	complex operator ++				// error: complex operator with no holes

A complex operator must one hole between two symbols, and no two consecutive holes.

	complex operator ++ --			// error: missing hole between symbols ++ and --
	complex operator ++ _ _ --		// error: missing symbol between hole 1 and 2

## Type operator functions
A **type operator function** is a type function that is associated with an operator. They're defined with `type operator func` declarations.

	infix type operator func -> (Argument: Any.Type, Result: Any.Type) -> Functor<from: Argument, to: Result, throws: false> { … }
	infix type operator func throws -> (Argument: Any.Type, Result: Any.Type) -> Functor<from: Argument, to: Result, throws: true> { … }
	postfix type operator func ? (Value: Any.Type) -> Optional<Value> { … }