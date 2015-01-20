---
comments: true
date: 2015-01-21 16:10:00
layout: post
slug: specs2-notes
title: Notes on Specs2 (with joda)
summary: A bunch of notes on using Specs2
author: Patryk Jażdżewski
tags:
- Scala
- Specs2
- Testing
---

Hi. [Specs2](http://etorreborre.github.io/specs2/) is one of the most popular Scala libraries for testing, but definitely not a simple one. That's why I decided to create a blog post with a few tricks how to make working with Specs2 much easier. In this example we will be working with another cool libary [Joda Time](http://www.joda.org/joda-time/).

## Basic example

Ok, so let's start with a basic example 

~~~ scala
class TimeUtilsSpec extends Specification {
	"TimeUtils" should {
			"create date in correct timezone from a Timestamp" in {
      	createFormattedDate(new Timestamp(1234L)) === new DateTime(1234L, DateTimeZone.UTC)
    	}
	}
}
~~~

## Pass data into the tests

We can do this in (at least) two ways. Just pass the data as regular variables

~~~ scala
class TimeUtilsSpec extends Specification {
	val ts = 1234L
	"TimeUtils" should {
			"create date in correct timezone from a Timestamp" in {
      	createFormattedDate(new Timestamp(ts)) === new DateTime(ts, DateTimeZone.UTC)
    	}
	}
}
~~~

or pass them as a scope

~~~ scala
class Context extends Scope {
	val ts = 1234L
}
~~~

~~~ scala
class TimeUtilsSpec extends Specification {
	"TimeUtils" should {
			"create date in correct timezone from a Timestamp" in new Context {
      	createFormattedDate(new Timestamp(ts)) === new DateTime(ts, DateTimeZone.UTC)
    	}
	}
}
~~~

The first option is very straightforward and works well for small tests, but is impractical for bigger tests or when you want to (for some reason) share the variables.

## Implement custom Setup and Teardown

Now let's try to compare dates in a different way. Instead of creating them via passing timestamps, we will use their other constructors. The problem is that the parameterless contructor by default creates a date for this instant, so each time you call it dates will be different. How can we fix that? ... We can use [DateTimeUtils](http://joda-time.sourceforge.net/apidocs/org/joda/time/DateTimeUtils.html) to freeze then unfreeze time.

First we need to create an helper for local setup and teardown. We can do it like this

~~~ scala
def around[T : AsResult, X, Y](before: () => X, after: () => Y)(t: => T) {
    // before logic
    before()
    val result = AsResult.effectively(t)
    // after logic
    after()
    result
}
~~~

It might seem a bit unwieldy at first, but we can wrap it in a elegant way using partial application so it meets our purpose

~~~ scala
def withTime[T] = around[T, Unit, Unit](
    () => { DateTimeUtils.setCurrentMillisFixed(1234L) },
    () => { DateTimeUtils.setCurrentMillisSystem() }
) _
~~~

now we can do 

~~~ scala
class TimeUtilsSpec extends Specification {
	"TimeUtils" should {
			"make sure both ways of creating dates are valid" in withTime {
      	new DateTime(DateTimeZone.UTC) === new DateTime().toDateTime(DateTimeZone.UTC)
    	}
	}
}
~~~

## Implement custom Setup and Teardown for all test cases

The example above works good, but for single test cases. When used with many cases in might lead to race conditions (since tools from DateTimeUtils are static). In order to fix that we will have to stop time when the first cases starts and bring it back on when the last one finished. As far as I know Specs2 don't have a build in tool for that, so we will create one.

~~~ scala
trait BeforeAllAfterAll extends Specification {
  override def map(fragments: =>Fragments) =
    Step(beforeAll) ^ fragments ^ Step(afterAll)

  protected def beforeAll()
  protected def afterAll()
}
~~~

~~~ scala
class TimeUtilsSpec extends BeforeAllAfterAll {
  def beforeAll() {
    DateTimeUtils.setCurrentMillisFixed(1234L)
  }

  def afterAll() {
    DateTimeUtils.setCurrentMillisSystem()
  }

	"TimeUtils" should {
			"make sure both ways of creating dates are valid" in withTime {
      	new DateTime(DateTimeZone.UTC) === new DateTime().toDateTime(DateTimeZone.UTC)
    	}
	}
}
~~~

## Random thoughts 

1. Watch out for static configuration and methods, they might cause tests to break from time to time
2. When using Specs2 try not to mix subpackages. Some mixins from org.specs2.mutable might not work those from org.specs2.specification and so one. Even worse they might just fail silently.

