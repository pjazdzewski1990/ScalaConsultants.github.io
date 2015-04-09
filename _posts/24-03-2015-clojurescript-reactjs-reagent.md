---
comments: true
date: 2015-04-02 14:00:00
layout: post
slug: {functional-programming-on-frontend-with-react-clojurescript-reagent}
title: Functional programming on frontend with React & ClojureScript
summary: Lately all of my frontend work at ScalaC projects was done mostly using React. Recently lot of companies started to adopt this powerful framework. Since we are Scala shop and fans of functional approach as well as interested in using other functional languages I decided to give a try to ClojureScript and see how it might play together with React. In fact, those 2 technologies are playing together very nicely and enable you to build scalable and well performing UIs in functional way.
author: Marek Tomas
tags:
- ClojureScript
- JavaScript
- Frontend
---

## <a name="introduction" href="#introduction">Introduction</a>
I have been working and evaluating popular JavaScript frameworks such as AngularJS, Polymer, Ember and also emerging WebComponents for quite some time. In this blog post I will show advantages of React way of building scalable and well performing web applications with taste of functional programming. In this tutorial we will introduce basics of ClojureScript as well and show how React plays nicely with ClojureScript through one of its wrappers called Reagent. Working app is included as well.

## <a name="what-makes-ui-hard" href="#what-makes-ui-hard">What makes UI hard ?</a>

One of the biggest and most common problems (not only) in the frontend web development is *state management*. In order to manage state of UI developers and frameworks have to come up with strategies for keeping DOM in sync with its view and DOM representation. Since users can interact with web app UI in many ways, managing state transitions is quite a challenging task to be done right when we have to consider good user experience, performance and keeping complexity of underlying codebase as low as possible. Growing complexity comes up with more bugs which are mostly direct result of managing changes in application state. Such codebase is also harder to test and reason about which adds up to development costs.


## <a name="react-high-level-overview" href="#react-high-level-overview">React - high level overview</a>

### <a name="what-is-react" href="#what-is-react">What is React ?</a>
React is addressing the aforementioned challenges in a very neat and profound way. React authors define it as a **JavaScript library for creating UIs and addressing problem of building large applications with data that changes over time**. As already stated, mutable state is very complex thing to manage and reason about. So how is React approach to managing UI state different compared to others frameworks and libraries out there ?

### <a name="functional-programming-to-the-rescue" href="#functional-programming-to-the-rescue">Functional programming to the rescue</a>
React brings the very basic essence of functional programming to the table. It provides abstractions such as components which are basically (pure) functions and get you away from imperatively touching the DOM.

Basically, in terms of functional programming, you write [idempotent](http://en.wikipedia.org/wiki/Idempotence), composable functions. Data is coming to your functions as input which emit tree like representations as return values. When data changes, functions are re-run again with new data as input. React diffs the result of previous function call with new one and it effectively calculates the difference between the tree structures. From higher level perspective, React is a function which takes two DOMs and generates a list of DOM operations to be applied to the DOM, i.e., it is [referentially transparent](http://en.wikipedia.org/wiki/Referential_transparency_%28computer_science%29).

### <a name="react-basics" href="#react-basics">React basics</a>
Now let's see what React does in the browser with DOM. Diffing between tree representations is done internally by React through *indirection mechanism* called virtual DOM which mirrors the real DOM. Every time when input data changes new virtual DOM is generated and **only** differences between them are translated into batch operations applied to real DOM, in the most effective way possible. This results in higher performance and sheds you away from touching the DOM by hand, which might results in bugs.

In React you work with [Components](http://facebook.github.io/react/docs/tutorial.html#your-first-component) which are reusable, basic building blocks of UI. You simply update component internal state and then its UI is re-rendered accordingly. You do not have to deal with programming state transitions by hand which results in reduction of code complexity. Let's see some practical code example to explain the idea of React components little bit more.

### <a name="react-code-sample" href="#react-code-sample">React - JavaScript code sample</a>

{% highlight javascript %}

var Timer = React.createClass({

  getDefaultProps: function() {
    return {label: "Timer"}
  },

  getInitialState: function() {
    return {secondsElapsed: 0};
  },

  tick: function() {
    this.setState({secondsElapsed: this.state.secondsElapsed + 1});
  },

  componentDidMount: function() {
    this.interval = setInterval(this.tick, 1000);
  },

  componentWillUnmount: function() {
    clearInterval(this.interval);
  },

  render: function() {
    return (
      <div>
      	<strong>{this.props.label}</strong>
        <br/>
	      Seconds Elapsed: {this.state.secondsElapsed}
      </div>
    );
  }
});

React.render(<Timer label={"Sample timer"}/>, mountNode);
{% endhighlight %}

This is example of stateful component. To allow reuse of components each of the components has its own unique state accessed via `this.state`. When using stateful components, initial state is defined through `getInitialState` method. In case component’s state changes (next timer tick in this example), markup will be updated by re-invoking `render()` function. In order to keep up with FP principles and get advantage out of them, this function should be *pure* in general i.e. should not depend on anything other than component state & properties and generate any side effects.

This component renders itself also based on already mentioned properties. Properties are immutable data that turn dull components into configurable interface elements. In component instance they are accessed via `this.props`. Similarly as for state, it is possible to define default properties via `getDefaultProps` method. In this example, properties are passed via JavaScript syntax extension called JSX that looks similar to HTML and can be found at the very bottom of code sample and also in `render` method. React provides tools that translate this JSX syntax into native JavaScript. Reasons for introducing JSX syntax are that it is more familiar for casual developers such as designers and brings natural way of expressing larger trees of components.

Declaring hierarchy of components that should be returned as a result of calling `render` function on some arbitrary component might look for example like this:

{%highlight xml %}
render: function() {
        return  (<Form>
                   <FormRow>
                     <FormLabel />
                     <FormInput />
                   </FormRow>
                 </Form>)
}
{% endhighlight %}

This syntax shows how it is possible to compose component trees in very readable and intuitive way. JSX transformer takes care of replacing XML literals with proper native JavaScript calls.

React API also provides possibility to hook in your code in methods executed at specific points of [component lifecycle](http://facebook.github.io/react/docs/component-specs.html). In case of Timer example we use [getDefaultProps](https://facebook.github.io/react/docs/component-specs.html#getdefaultprops), [getInitialState](http://facebook.github.io/react/docs/component-specs.html#getinitialstate), [componentDidMount](http://facebook.github.io/react/docs/component-specs.html#mounting-componentdidmount), [componentWillUnmount](http://facebook.github.io/react/docs/component-specs.html#unmounting-componentwillunmount) and [render](http://facebook.github.io/react/docs/component-specs.html#render) lifecycle methods.


React makes rendering of UI as simple as defining a function. Since React follows principles of the functional paradigm, it is no surprise that the ClojureScript community has embraced React with open arms. In next chapter of this blog post we will have a look at ClojureScript and one of its React wrappers called Reagent and will get our hands dirty with building sample app.


## <a name="react-meets-clojurescript" href="#react-meets-clojurescript">React meets ClojureScript</a>

For those of you who are not much familiar with ClojureScript, I strongly recommend to read [rationale](https://github.com/clojure/clojurescript/wiki/Rationale) which contains nice summary of what is ClojureScript about:

> ClojureScript seeks to address the weak link in the client/embedded application development story by replacing JavaScript with Clojure, a robust, concise and powerful programming language. In its implementation, ClojureScript adopts the strategy of the Google Closure library and compiler, and is able to effectively leverage both tools, gaining a large, production-quality library and whole-program optimization. ClojureScript brings the rich data structure set, functional programming, macros, reader, destructuring, polymorphism constructs, state discipline and many other features of Clojure to every place JavaScript reaches.

ClojureScript is a simple language that favors a functional style of programing and is based on small numbers of fundamental concepts. For those exposed mostly to imperative, object-oriented languages some of the concepts might seem unfamiliar at first glance. However, learning those concepts gives you another powerful programming tools to your hands.

Another specific thing about ClojureScript is its syntax which mimics Clojure (Lisp dialect). Instead of going through syntax and basics of the language here in this blogpost I rather recommend you to go through this [concise guide of ClojureScript](https://github.com/shaunlebron/ClojureScript-Syntax-in-15-minutes) which I found very helpful.

After grasping basics you should be ready to read and comprehend code samples in the following chapter. ClojureScript syntax actually enables you to write very concise representations of component hierarchies using Reagent library. I found Reagent to be the simplest and most intuitive ClojureScript wrapper to start with. I recommend you to [watch out for Om](https://github.com/omcljs/om) which gets lot of attention these days and bundles few great ideas together as well.


### <a name="reagent-simple-react-wrapper" href="#reagent-simple-react-wrapper">Reagent - simple React wrapper</a>

Reagent is a library that provides minimalistic interface between React and ClojureScript. It allows you to define React UIs of arbitrary complexity using only plain ClojureScript functions & data and describe it using [Hiccup-like syntax](https://github.com/weavejester/hiccup) which is very concise and easy to read. Your application is built together only using bunch of very basic but powerful concepts.

Let's see how to define basic component using Reagent:

{%highlight clojure%}
(defn hello-component []
  (defn hello [name]
    [:div "hello " name]))
{%endhighlight%}

This component can be mount to DOM node like this:

{%highlight clojure%}
(reagent/render [hello-component "Rich"] (.-body js/document))
{%endhighlight%}

Component composition is done in a very easy and concise way. You can also define accompanying CSS classes to components and pass children components as params as you do in React.

{%highlight clojure%}
(defn page [body]
  [:div.page
    [:div.header "Page header"]
    body
    [:div.footer "Page footer"]])
{%endhighlight%}

In ClojureScript, almost everything is immutable. To accomplish mutability ClojureScript uses concept of *atoms*. Atoms are references to objects which needs to be dereferenced in order to obtain object instance. Think about them as similar thing as pointers in C.

Common and viable practice is to define all of your application state in one *atom* which might be done like this.

{%highlight clojure%}
(def state (atom {:data [] :number-of-steps 0}))
{%endhighlight%}

Manipulating atoms is done through side effecting functions (suffixed with !). Reagent uses it's own version of atom. Any component that uses an atom is automagically re-rendered when it's value changes. This allows for more complex binding scenarios than in typical use of React. Distinction between props and state is gone and you are free to use Reagent atoms in any way you prefer. Let's revisit our Timer component - this time little bit simplified.

{%highlight clojure%}
(defn timer-component []
  (let [seconds-elapsed (atom 0)]
    (fn []
      (js/setTimeout #(swap! seconds-elapsed inc) 1000)
      [:div
       "Seconds Elapsed: " @seconds-elapsed])))
{%endhighlight%}

Number of elapsed seconds is kept in its own atom - in this case unique state of component. Most common way to mutate atom value is to use built-in ClojureScript function `swap!`.

Call to `swap!` accepts function as argument that is applied to value of atom and stored.

{%highlight clojure%}
swap! seconds-elapsed inc
{%endhighlight%}

Those are the basic building blocks of Reagent which will enable you to build well performing UIs.

## <a name="a-word-about-performance" href="#word-about-performance">A word about performance</a>

React itself is very fast. Reagent is able to be even faster because of optimizations done in ClojureScript. All of the actions that might trigger re-rendering components (dereferencing atom, changing args passed to component or its state) benefit from fast pointer comparisons between changed ClojureScript data structures and trigger re-rendering of components only when it is really needed. This means you have to care about performance rarely (for example when displaying long list of items) and define UI as you feel fit.

### <a name="sample-app" href="#sample-app">Sample app

By grasping basics and knowing benefits of using ClojureScript and Reagent together you should be ready to understand code of sample basic application Pexeso. Whole source code [can be found on GitHub](https://github.com/mtomas/clojurescript-reagent-pexeso) and you are encouraged to follow and experiment with this example.

You can see working [demo deployed on Heroku](https://cljspexeso.herokuapp.com/) as well.

<iframe width="100%" height="650" src="//jsfiddle.net/dms25way/4/embedded/result,html,css,resources,js" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

## <a name="pexeso-walkthrough" href="#pexeso-walkthrough">Pexeso walkthrough</a>

To showcase Reagent together with ClojureScript I created a sample application Pexeso. This game is also known as *Memory*, in this case simplified and meant to be played by one player. Player in game basically reveals 2 cards with symbols in one step, if symbols match he scores and has to guess other pairs of matching cards. Point of this sample application is to explain basics of working with Reagent & ClojureScript.

In this blogpost I won't go into details of setting up a ClojureScript project. The project requires [Leiningen build tool](http://leiningen.org/) and you will need to have it installed before continuing.

Most convenient option for you (if you are Mac user) might be to install it using *brew* package manager.

{% highlight bash %}
$ brew install leiningen
{% endhighlight %}


I decided to use excellent [Reagent Leiningen template](https://github.com/reagent-project/reagent-template) for projects using Reagent. This template packages everything needed for production ready ClojureScript applications. It comes up with nice development environment that allows you to do instant subsecond builds of your whole app and see them immediately swapped in the browser resulting in very efficient workflow for learning and trying things out.

Whole application logic except template stuff has around ~100 lines of code. Let's go through most important parts of it.


We will start by defining global state that keeps track of cards and value of last revealed card:

{% highlight clojure%}
(def state (atom {:cards [] :last-symbol nil}))
{% endhighlight %}
[\[Source code\]](https://github.com/mtomas/clojurescript-reagent-pexeso/blob/master/src/cljs/react_cljs_blogpost/core.cljs#L15)

`:last-symbol` value is compared to symbol of recently revealed card. If match of symbol occurs, card state atom present in `:cards []` vector is updated.


Card state is represented by map with keys described below. After clicking on card with symbol "M" card state is updated into following map:

{%highlight clojure%}
{:visible false :matched false :symbol "M"}
{%endhighlight%}



Main UI showing cards is very simple, it is basically grid of cards that allows card to be revealed by simple click.

{% highlight clojure%}
(defn home-page []
  [:div.pexeso
    [:h2 "Pexeso"]
    [:div.status (if (= (matched-cards-count) board-size)
        "Game is finished, congratulations !"
    )]
    [:br]

    [:button.button {:onClick start-game} "Restart game"]

    [:div.board
        (doall (for [card-state (@state :cards)] (card card-state)))
    ]])
{% endhighlight %}
[\[Source code\]](https://github.com/mtomas/clojurescript-reagent-pexeso/blob/master/src/cljs/react_cljs_blogpost/core.cljs#L74)


You might wonder about `doall` function that wraps for comprehension. Point here is that we have to eagerly evaluate [lazily generated sequence](http://theatticlight.net/posts/Lazy-Sequences-in-Clojure/) of atoms that hold cards' state. Otherwise Reagent would be unable to dereference them properly which would lead into inconsistencies. State of the card is then passed as an argument to function creating React components. Internals of component can be followed by reading the comments starting with **;**.

{%highlight clojurescript %}
(defn card [card-state]
  (letfn [(handle-card-click! [event]
            ; pair of cards was revealed, now let's go for another pair step
            (if (= (revealed-cards-count) 2)
              (hide-nonmatch!))

            ;reveal next card in step
            (reveal-card! card-state)

            ;if 2 of cards are revealed, we have to check parity
            (if (and (= (revealed-cards-count) 2)
                     (= (:last-symbol @state)
                        (:symbol @card-state)))
              (mark-match! (:symbol @card-state)))

            ;let's remember last symbol to make comparison in subsequent steps
            (swap! state assoc :last-symbol (:symbol @card-state)))]

    [:div.card
     {:onClick handle-card-click!
      :key     (.random js/Math)
      :class   (if (@card-state :matched)
                 "card-matched"
                 "card")}

     [:span.card-value
      {:class (if (@card-state :visible)
                "card-value"
                "card-value-hidden")}
      (:symbol @card-state)]]))
{% endhighlight %}
[\[Source code\]](https://github.com/mtomas/clojurescript-reagent-pexeso/blob/master/src/cljs/react_cljs_blogpost/core.cljs#L38)

That is pretty much all worth elaborating that relates to logic of the game. [Whole source](https://github.com/mtomas/clojurescript-reagent-pexeso) is available and commented throug on GitHub and I encourage you to try to implement some basic features - such as number of steps done to complete the game or even try to come up with feature that enables you to replay steps of finished game.

## <a name="summary" href="#summary">Summary</a>

As you can see picking up the stellar combo ClojureScript + Reagent is very simple and requires very little code to get things done. Things like atoms simplify your life and enable you to create more complex binding schemas. Functional code makes your frontend code easier to reason about and might be even more performing than your current implementations using plain React.

ClojureScript has matured into production-ready language and it allows build better, more reusable and solid frontend code in functional manner and with fewer lines than in native JavaScript.

I believe you might greatly benefit from using those technologies while building sophisticated web applications. If you are interested in ClojureScript and have been looking at it from distance I hope that I piqued your interest and wish you good luck in your learning endeavours.

Feel free to express your questions, comments or opinions in the blog post comments section down below.

## <a name="links" href="#links">Links</a>
- [http://swannodette.github.io/2013/11/07/clojurescript-101/](http://swannodette.github.io/2013/11/07/clojurescript-101/)
- [http://www.mattgreer.org/articles/reagent-rocks/#on-to-reagent](http://www.mattgreer.org/articles/reagent-rocks/#on-to-reagent)
- [http://reagent-project.github.io/](http://reagent-project.github.io/)
- [http://www.slideshare.net/InfoQ/the-immutable-frontend-in-clojurescript?qid=145eca11-81e3-4199-9da6-e67e73420f51&v=default&b=&from_search=1](http://www.slideshare.net/InfoQ/the-immutable-frontend-in-clojurescript?qid=145eca11-81e3-4199-9da6-e67e73420f51&v=default&b=&from_search=1)
- [http://www.lispcast.com/react-another-level-of-indirection](http://www.lispcast.com/react-another-level-of-indirection)
- [http://getprismatic.com/story/1405451329953](http://getprismatic.com/story/1405451329953)
