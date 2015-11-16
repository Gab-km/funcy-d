# Funcy for D

Funcy is the library that offers some useful data types.
funcy-d is a Funcy binding for D language.

## Usage

```dlang
import std.stdio;

import funcy.maybe;

void main()
{
    auto maybe1 = helloWorld1();
    if (maybe1.isJust)
    {
        // Hello world!
        writeln(maybe1.toJust().value);
    }

    auto maybe2 = helloWorld2();
    if (maybe2.isJust)
    {
        // Hello world!
	writeln(maybe2.toJust().value);
    }
}

// nested version
Maybe!string helloWorld1()
{
    Maybe!string f(string hello) {
        string g(string world) {
	    return hello ~ " " ~ world ~ "!";
	}
	return Maybe!string.point("world").fmap!string(&g);
    }
    return Maybe!string.just("Hello").compute(&f);
}

// accumulating version
Maybe!string helloWorld2()
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
    return Maybe!string.point("")
        .compute(&hello)
	.compute(&space)
	.compute(&world)
	.compute(&exclaim);
}
```

## Link

* [Funcy](https://github.com/Gab-km/Funcy)

  Funcy repository

