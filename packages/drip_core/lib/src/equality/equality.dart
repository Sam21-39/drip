/// Interface for equality comparison in [DripState].
abstract interface class Equality<T> {
  bool equals(T a, T b);
}

/// Default equality using Dart's == operator.
class DefaultEquality<T> implements Equality<T> {
  const DefaultEquality();

  @override
  bool equals(T a, T b) => a == b;
}

/// Identity equality using [identical].
class IdentityEquality<T> implements Equality<T> {
  const IdentityEquality();

  @override
  bool equals(T a, T b) => identical(a, b);
}

/// Factory for the default equality implementation.
Equality<T> defaultEquality<T>() => DefaultEquality<T>();
