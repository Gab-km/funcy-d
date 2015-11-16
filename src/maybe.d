/**
 * funcy.maybe
 *
 * Maybe/Just/Nothing types ported from Funcy.
 *
 * Example:
 * ----
 * auto maybe = Maybe!int.just(42);
 * if (maybe.isJust) {
 *   writefln("We got %d!", maybe.value);
 * } else {
 *   writeln("We got nothing yey...");
 * }
 * ----
 *
 * Copyright: Copyright Kazuhiro Matsushima 2015-.
 * License:   <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>.
 * Authors:   Kazuhiro Matsushima
 */
module funcy.maybe;

/**
 * Maybe
 *
 * Abstract base class for Just and Nothing.
 * It also does as factory class for those classes.
 */
abstract class Maybe(T)
{
  /**
   * Create Just!T value.
   *
   * Returns:
   *  a T value enveloped in Just!T.
   */
  static Just!T just(T value)
  {
    return new Just!(T)(value);
  }

  /**
   * Create Nothing!T value.
   *
   * Returns:
   *  a Nothing!T value.
   */
  static Nothing!T nothing()
  {
    return new Nothing!(T)();
  }

  @property abstract bool isJust();
  @property abstract bool isNothing();

  /**
   * Cast to Just!T class.
   *
   * Returns:
   *  Just!T if &#36;this is Just!T, otherwise &#36;null.
   */
  Just!T toJust()
  {
    return cast(Just!T) this;
  }

  /**
   * Cast to Nothing!T class.
   *
   * Returns:
   *  Nothing!T if &#36;this is Nothing!T, otherwise &#36null.
   */
  Nothing!T toNothing()
  {
    return cast(Nothing!T) this;
  }

  mixin template Functor()
  {
    Maybe!R fmap(R)(R function(T) f)
    {
      if (this.isJust) {
	return Maybe!(R).just(f(this.toJust().value));
      } else {
	return Maybe!(R).nothing();
      }
    }
    Maybe!R fmap(R)(R delegate(T) f)
    {
      if (this.isJust) {
	return Maybe!(R).just(f(this.toJust().value));
      } else {
	return Maybe!(R).nothing();
      }
    }
  }
  mixin Functor;

  mixin template Computations()
  {
    static Maybe!T point(T value)
    {
      return Maybe!T.just(value);
    }
    Maybe!R compute(R)(Maybe!R function(T) f)
    {
      if (isJust) {
	return f(this.toJust().value);
      } else {
	return Maybe!R.nothing();
      }
    }
    Maybe!R compute(R)(Maybe!R delegate(T) f)
    {
      if (isJust) {
	return f(this.toJust().value);
      } else {
	return Maybe!R.nothing();
      }
    }
  }
  mixin Computations;
}

// test Maybe sound
unittest
{
  { // Just
    auto just = Maybe!(string).just("hoge");
    assert(just.isJust == true);
    assert(just.isNothing == false);
    assert(just.value == "hoge");
  }
  { // Nothing
    auto nothing = Maybe!(int).nothing();
    assert(nothing.isJust == false);
    assert(nothing.isNothing == true);
  }
  { // Just as Maybe
    Maybe!int maybe = Maybe!int.just(10);
    assert(maybe.isJust);
    assert(!maybe.isNothing);
    assert(maybe.toJust().value == 10);
    assert(maybe.toNothing() is null);
  }
  { // Nothing as Maybe
    Maybe!string maybe = Maybe!string.nothing();
    assert(!maybe.isJust);
    assert(maybe.isNothing);
    assert(maybe.toJust() is null);
    assert(maybe.toNothing() !is null);
  }
}

// test Functor over Maybe
unittest
{
  { // Just
    auto just = Maybe!(int).just(10);
    auto sut = just.fmap!(int)((i) => i * 2);
    assert(sut.isJust == true);
    assert(sut.isNothing == false);
    assert(sut.toJust().value == 20);
  }
  { // Nothing
    import std.conv;
    auto nothing = Maybe!(string).nothing();
    auto sut = nothing.fmap!(int)((s) => to!int(s));
    assert(sut.isJust == false);
    assert(sut.isNothing == true);
  }
}

// test Computations over Maybe
unittest
{
  { // point
    auto sut = Maybe!int.point(3);
    assert(sut.isJust);
    assert(!sut.isNothing);
    assert(sut.toJust().value == 3);
  }
  auto f = (int i) => Maybe!int.point(i * 2);
  { // compute && just
    auto just = Maybe!int.just(10);
    auto sut = just.compute(f);
    assert(sut.isJust);
    assert(!sut.isNothing);
    assert(sut.toJust().value == 20);
  }
  { // compute && nothing
    auto nothing = Maybe!int.nothing();
    auto sut = nothing.compute(f);
    assert(!sut.isJust);
    assert(sut.isNothing);
  }
}

// hello world
unittest
{
  {
    Maybe!string f(string hello) {
      string g(string world) {
	return hello ~ " " ~ world ~ "!";
      }
      return Maybe!string.point("world").fmap!string(&g);
    }
    auto maybe = Maybe!string.just("Hello").compute(&f);
    assert(maybe.isJust);
    assert(maybe.toJust().value == "Hello world!");
  }
  {
    Maybe!string hello(string sp) {
      if (sp == "")
	return Maybe!string.point(sp ~ "Hello");
      else
	return Maybe!string.nothing();
    }
    Maybe!string space(string hl) {
      if (hl == "Hello")
	return Maybe!string.point(hl ~ " ");
      else
	return Maybe!string.nothing();
    }
    Maybe!string world(string hs) {
      if (hs[$-1..$] == " ")
	return Maybe!string.point(hs ~ "world");
      else
	return Maybe!string.nothing();
    }
    Maybe!string exclaim(string hw) {
      if (hw[$-5..$] == "world")
	return Maybe!string.point(hw ~ "!");
      else
	return Maybe!string.nothing();
    }
    auto maybe = Maybe!string.point("")
      .compute(&hello)
      .compute(&space)
      .compute(&world)
      .compute(&exclaim);
    assert(maybe.isJust);
    assert(maybe.toJust().value == "Hello world!");
  }
}

/**
 * Just
 *
 * This class represents that there may be a value.
 */
class Just(T) : Maybe!T
{
  override @property bool isJust() { return true; }
  override @property bool isNothing() { return !isJust; }

  /**
   * a value this class has.
   */
  @property T value() { return _value; }
  
  this(T value) {
    _value = value;
  }

 private:
  T _value;
}

// test Just
unittest
{
  auto sut = new Just!(int)(10);
  assert(sut.value == 10);
  assert(sut.isJust == true);
  assert(sut.isNothing == false);
}

/**
 * Nothing
 *
 * This class represents that there may not be a value.
 */
class Nothing(T) : Maybe!T
{
  override @property bool isJust() { return false; }
  override @property bool isNothing() { return !isJust; }
}

// test Nothing
unittest
{
  auto sut = new Nothing!string;
  assert(sut.isJust == false);
  assert(sut.isNothing == true);
}
