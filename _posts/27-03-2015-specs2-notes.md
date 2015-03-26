---
comments: true
date: 2015-03-27 16:10:00
layout: post
slug: specs2-notes
title: Notes on Specs2
summary: A bunch of notes on using Specs2
author: Patryk Jażdżewski
tags:
- Scala
- Specs2
- Testing
---

Hi. [Specs2](http://etorreborre.github.io/specs2/) is one of the most popular Scala libraries for testing, but definitely not a simple one. That's why I decided to create a blog post with a few tricks how to make working with Specs2 much easier. The examples are 100% artificial, but their purpose is only to demonstrate capabilities of Specs2.

## Basic example

Ok, so let's start with a basic example 

{% highlight scala %}
import org.specs2.mutable.Specification

class MathSpec extends Specification {
  "Math" should {
    "add" in {
      1+2 === 3
    }
  }
}
{% endhighlight %}

## Pass data into the tests

We can do this in (at least) two ways. Just pass the data as regular variables

{% highlight scala %}
import org.specs2.mutable.Specification

class MathSpec extends Specification {
  "Math" should {
    val pi = 3.14
    "multiply" in {
      2*pi === 6.28
    }
  }
}
{% endhighlight %}

or pass them as a scope

{% highlight scala %}
import org.specs2.mutable.Specification
import org.specs2.specification.Scope

class MathSpec extends Specification {

  class Context extends Scope {
    val pi = 3.14
  }

  "Math" should {
    "multiply" in new Context {
      2*pi === 6.28
    }
  }
}
{% endhighlight %}

The first option is very straightforward and works well for small tests, but is impractical for bigger ones or when you want to (for some reason) share the variables.

## Implement custom Setup and Teardown

Now let's say that we need to perform some important operations before and after every single test case. How can we achieve that? It's simple. We can use Contexts again.

First we need to create an helper for local setup and Teardown. We can do it like this

{% highlight scala %}
trait Context extends BeforeAfter {
  var bar : Option[String] = Some("bar")

  def before: Any = println("Doing setup")
  def after: Any = println("Done. Cleanup")
}
{% endhighlight %}

now we can do 

{% highlight scala %}
import org.specs2.mutable.{BeforeAfter, Specification}

class MathSpec extends Specification {

  /**
   * Helper for creating test with custom setup/teardown functions
   */
  trait Context extends BeforeAfter {
    var bar : Option[String] = Some("bar")

    def before: Any = println("Doing setup")
    def after: Any = println("Done. Cleanup")
  }

  "Math" should {
    "subtract" in new Context  {
      8-2 === 6
    }
  }
}
{% endhighlight %}

## Implement custom Setup and Teardown for all test cases

The example above works good but only for single test cases, now lets write something for the whole test suite.  

{% highlight scala %}
trait BeforeAllAfterAll extends Specification {
  override def map(fragments: => Fragments) =
    Step(beforeAll) ^ fragments ^ Step(afterAll)

  protected def beforeAll()
  protected def afterAll()
}
{% endhighlight %}

{% highlight scala %}
import org.specs2.mutable.Specification
import org.specs2.specification.{Step, Fragments}

trait BeforeAllAfterAll extends Specification {
  override def map(fragments: => Fragments) =
    Step(beforeAll) ^ fragments ^ Step(afterAll)

  protected def beforeAll()
  protected def afterAll()
}

class MathSpec extends Specification with BeforeAllAfterAll {

  def beforeAll() {
    println("Starting MathSpec")
  }

  def afterAll() {
    println("Ending MathSpec")
  }

  "Math" should {
    "divide" in {
      8/2 === 4
    }
  }
}
{% endhighlight %}

## Random thoughts 

1. Watch out for static configuration and methods, they might cause tests to break from time to time.
2. When using Specs2 try not to mix sub-packages. Some mixins from org.specs2.mutable might not work those from org.specs2.specification and so one. Even worse they might just fail silently.
3. As you probably noticed already Contexts can be classes, traits and objects.

