/**
 * funcy.either
 *
 * Either/Left/Right types ported from Funcy.
 *
 * Example:
 * ----
 * auto either = Either!(string, int).("It's left value.");
 * if (either.isRight) {
 *   writefln("Right(%d)", either.value);
 * } else {
 *   writefln("Left(%s)", either.value);
 * }
 * ----
 *
 * Copyright: Copyright Kazuhiro Matsushima 2015-.
 * License:   <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>.
 * Authors:   Kazuhiro Matsushima
 */
module funcy.either;

/**
 * Either
 *
 * Abstract base class for Left and Right.
 * It also does as factory class for those classes.
 */
abstract class Either(TLeft, TRight)
{
  /**
   * Create Left!(TLeft, TRight) value.
   *
   * Returns:
   *  a TLeft value enveloped in Left!(TLeft, TRight).
   */
  static Left!(TLeft, TRight) left(TLeft value)
  {
    return new Left!(TLeft, TRight)(value);
  }

  /**
   * Create Right!(TLeft, TRight) value.
   *
   * Returns:
   *  a TRight value enveloped in Right!(TLeft, TRight).
   */
  static Right!(TLeft, TRight) right(TRight value)
  {
    return new Right!(TLeft, TRight)(value);
  }

  @property abstract bool isLeft();
  @property abstract bool isRight();

  /**
   * Cast to Left!(TLeft, TRight) class.
   *
   * Returns:
   *  Left!(TLeft, TRight) if &#36;this is Left!(TLeft, TRight), otherwise &#36;null.
   */
  Left!(TLeft, TRight) toLeft()
  {
    return cast(Left!(TLeft, TRight)) this;
  }

  /**
   * Cast Right!(TLeft, TRight) class.
   *
   * Returns:
   *  Right!(TLeft, TRight) if &#36;this is Right!(TLeft, TRight), otherwise &#36;null.
   */
  Right!(TLeft, TRight) toRight()
  {
    return cast(Right!(TLeft, TRight)) this;
  }

  mixin template Functor()
  {
    Either!(TLeft, R) fmap(R)(R function(TRight) f)
    {
      if (this.isRight) {
	return Either!(TLeft, R).right(f(this.toRight().value));
      } else {
	return Either!(TLeft, R).left(this.toLeft().value);
      }
    }
  }
  mixin Functor;
}

// test Either sound
unittest
{
  { // Left
    auto left = Either!(string, int).left("left");
    assert(left.isLeft == true);
    assert(left.isRight == false);
    assert(left.value == "left");
  }
  { // Right
    auto right = Either!(string, int).right(42);
    assert(right.isLeft == false);
    assert(right.isRight == true);
    assert(right.value == 42);
  }
  { // Left as Either
    Either!(string, int) either = Either!(string, int).left("hoge");
    assert(either.isLeft);
    assert(!either.isRight);
    assert(either.toLeft().value == "hoge");
    assert(either.toRight() is null);
  }
  { // Right as Either
    Either!(string, int) either = Either!(string, int).right(42);
    assert(!either.isLeft);
    assert(either.isRight);
    assert(either.toLeft() is null);
    assert(either.toRight().value == 42);
  }
}

// test Functor over Either
unittest
{
  alias either = Either!(string, int);
  import std.conv;
  { // Left
    auto left = either.left("hoge");
    auto sut = left.fmap!(string)((i) => to!string(i) ~ "!");
    assert(sut.isRight == false);
    assert(sut.isLeft == true);
    assert(sut.toLeft().value == "hoge");
  }
  { // Right
    auto right = either.right(10);
    auto sut = right.fmap!(string)((i)=> to!string(i));
    assert(sut.isRight == true);
    assert(sut.isLeft == false);
    assert(sut.toRight().value == "10");
  }
}

/**
 * Left
 *
 * This class represents one of two choices, which is mostly used as an error result.
 */
class Left(TLeft, TRight) : Either!(TLeft, TRight)
{
  override @property bool isLeft() { return true; }
  override @property bool isRight() { return !isLeft; }

  /**
   * a value this class has.
   */
  @property TLeft value() { return _value; }
  
  this(TLeft value) {
    _value = value;
  }

 private:
  TLeft _value;
}

// test Left
unittest
{
  auto sut = new Left!(string, int)("hoge");
  assert(sut.value == "hoge");
  assert(sut.isLeft == true);
  assert(sut.isRight == false);
}

/**
 * Right
 *
 * This class represents the other one of two choices, which is mostly used as a normal result.
 */
class Right(TLeft, TRight) : Either!(TLeft, TRight) {
  override @property bool isLeft() { return false; }
  override @property bool isRight() { return !isLeft; }

  /**
   * a value this class has.
   */
  @property TRight value() { return _value; }
  
  this(TRight value) {
    _value = value;
  }

 private:
  TRight _value;
}

// test Right
unittest
{
  auto sut = new Right!(string, int)(10);
  assert(sut.isLeft == false);
  assert(sut.isRight == true);
  assert(sut.value == 10);
}
