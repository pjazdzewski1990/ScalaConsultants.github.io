---
comments: true
date: 2015-04-15 10:10:00
layout: post
slug: quick-poll
title: Quick Poll - Create a web application in 10 minutes  
summary: In this post we explore possibilities of rapid prototyping in our favourite programming language with Skinny framework 
author: Patryk Jażdżewski
tags:
- Scala
- Skinny
---

When considering web application development with Scala you probably think about Play! framework. It's a great library for creating fully fledged enterprise grade applications, but creating something big isn't always necessary. Sometimes small, but with fast time to market is the thing you need. I stumbled into this problem some time ago when doing prototyping and [Skinny](http://skinny-framework.org/) saved me a lot of work. This post is a quick introduction to Skinny, hopefully helping you with getting started. As an example we will develop an application that gathers applicant data. 

## <a name="code" href="#code">Coding quick-poll in 10 minutes</a>

![Skinny](http://skinny-framework.org/images/logo.png)

First make sure you have all the needed software installed. You will need [node.js](https://nodejs.org/), [npm](https://www.npmjs.com/) and [Yeoman](http://yeoman.io/). You can also install them all by doing 

{% highlight bash %}
brew install node --with-npm
npm install -g yo
npm install -g generator-skinny
{% endhighlight %}

Now we can create the app

{% highlight bash %}
mkdir quick-poll && cd quick-poll/
yo skinny
{% endhighlight %}

Next, let's create Employee Roles

{% highlight bash %}
./skinny g scaffold employeeRoles employeeRole name:String technology:String responsibilities:String minExperience:Int
./skinny db:migrate
{% endhighlight %}

Now we are ready to run the server. Open a new console tab and type

{% highlight bash %}
./skinny run
{% endhighlight %}

Now if you go to `http://localhost:8080/employee_roles` you should see a tables with role to choose from, but it's empty now so let's add some fixtures. (At this point it's good to import the code into an sbt compliant IDE) So go to `src/main/scala/ScalatraBootstrap.scala` and add this code:

{% highlight scala %}
  def createFixtures() = {
    if(EmployeeRole.countAllModels() == 0) {
      EmployeeRole.createWithAttributes(
        'name -> "Scala Hakker",
        'technology -> "Scala, Akka, Play, JVM",
        'responsibilities -> "Create awesome things!",
        'minExperience -> 1
      )
    }
  }
{% endhighlight %}

also make sure it's called inside `initSkinnyApp`. Ater refresh you should have Scala Hakker visible. Let's move now to the poll result model.

{% highlight bash %}
./skinny g model pollResults pollResult name:String email:String description:String role:Long
./skinny db:migrate
{% endhighlight %}

Now another route should be available `http://localhost:8080/poll_results` This is where our candidates will enter their data. 

The role field should be a dropdown with the role name and email should be validated to contain an email address. Let's tweak the default site a bit... 

Open `src/main/scala/controller.PollResultsController.scala` and modify the line defining email

{% highlight scala %}
  paramKey("email") is required & maxLength(512) & email,
{% endhighlight %}

Now go to `src/main/webapp/WEB-INF/pollResults/_form.html.ssp` and substitute the html for role field with this

{% highlight scala %}
  <%@val roles: Seq[model.EmployeeRole] = model.EmployeeRole.findAll() %>
<div class="form-group">
<label class="control-label" for="role">
  ${s.i18n.getOrKey("pollResult.role")}
</label>
<div class="controls row">
  <div class="${if(keyAndErrorMessages.hasErrors("role")) "has-error" else ""}">
    <div class="col-xs-12">
      <select name="role">
        #for (r <- roles)
          <option value="${r.id}">${r.name}</option>
        #end
      </select>
    </div>
  </div>
  #if (keyAndErrorMessages.hasErrors("role"))
    <div class="col-xs-12 has-error">
    #for (error <- keyAndErrorMessages.getErrors("role"))
      <label class="control-label">${error}</label>
    #end
    </div>
  #end
</div>
</div>
{% endhighlight %}

Now a final touch, modify `src/main/webapp/WEB-INF/root/index.html.ssp` to contain a link to poll

{% highlight scala %}
  <%@val s: skinny.Skinny %>
<p>
    <a href="${s.url(Controllers.pollResults.newUrl)}">Fill the survey</a>
</p>
{% endhighlight %}

## <a name="explain" href="#explain">Quick-poll explained</a>

Creating good software is more than just typing code, so let's go though the whole thing again slowly and explain it step by step.  

{% highlight bash %}
yo skinny
{% endhighlight %}

Nothing special here. We use the Yeoman scaffolding tool for creating applications backbone. Although Yeoman istself is written in Javascript the generated project is compliant with sbt, so you shouldn't have any problems with importing it.

{% highlight bash %}
./skinny g scaffold employeeRoles employeeRole name:String technology:String responsibilities:String minExperience:Int
./skinny db:migrate
{% endhighlight %}

Few thing to notice here. First of all we use `skinny` helper script which is convenient wrapper over sbt. The `g` option is a shorthand for `generate.` The next argument is what to create. We can create a `model`, `migration` or `controller`. By putting `scaffold` we tell Skinny to generate everything. After each db change done by Skinny we should issua a `db:migrate` so our local db will be updated. In this case we use a local H2. You can see sql generated by this command as .sql files in `task/src/main/resources/db/migration` directory

{% highlight scala %}
  def createFixtures() = {
    if(EmployeeRole.countAllModels() == 0) {
      EmployeeRole.createWithAttributes(
        'name -> "Scala Hakker",
        'technology -> "Scala, Akka, Play, JVM",
        'responsibilities -> "Create awesome things!",
        'minExperience -> 1
      )
    }
  }
{% endhighlight %}

The code above ilustrates few useful concepts. First of all it takes place in `ScalatraBootstrap` class which can be used to run code at startup (as we use it), to mount controller routes, start workers and much more. Secondly, it uses the power of [Skinny ORM](http://skinny-framework.org/documentation/orm.html#useful-apis-by-skinny-orm)

{% highlight scala %}
  paramKey("email") is required & maxLength(512) & email,
{% endhighlight %}

Skinny comes with a [validation](http://skinny-framework.org/documentation/validator.html) module which we use above. After marking the field as above Skinny will make sure that this param is given, it's length is shorter than 512 and matches a email regexp. Neat

{% highlight scala %}
  <%@val roles: Seq[model.EmployeeRole] = model.EmployeeRole.findAll() %>
<div class="form-group">
<label class="control-label" for="role">
  ${s.i18n.getOrKey("pollResult.role")}
</label>
<div class="controls row">
  <div class="${if(keyAndErrorMessages.hasErrors("role")) "has-error" else ""}">
    <div class="col-xs-12">
      <select name="role">
        #for (r <- roles)
          <option value="${r.id}">${r.name}</option>
        #end
      </select>
    </div>
  </div>
  #if (keyAndErrorMessages.hasErrors("role"))
    <div class="col-xs-12 has-error">
    #for (error <- keyAndErrorMessages.getErrors("role"))
      <label class="control-label">${error}</label>
    #end
    </div>
  #end
</div>
</div>
{% endhighlight %}

In the [view](http://skinny-framework.org/documentation/view-templates.html) layer Skinny uses Scalate templating system to render the content. That's why we have `${}` for interpolating values in html, `#if/#for` for looping and branching and `<%@` for declaring parameters. We could use a different system by passing a specific param to `./skinny` script

## <a name="improvements" href="#improvements">Possible improvements</a>

This quick application surely is far from perfect. Here are some pointers to consider when moving forward.

Role field in PollResult is simple `Long` value, that we happen to treat as a ForeignKey pointing to EmployeeRole table. It might be beneficial to make the relationship explicit by using Skinny's built-in [associations](http://skinny-framework.org/documentation/orm.html#associations)  

Another code smell that might become a pain is doing a db query `model.EmployeeRole.findAll()` inside a form template. I did that to make the example as short as possible, but more suitable place for that is the controller. To set `roles` param in controller we will have to override the paths first. Here's how to do than on example of create path. First modify `src/main/scala/controller/Controllers` object to include 

{% highlight scala %}
object pollResults extends _root_.controller.PollResultsController with Routes {
    val fillForm = get("/poll_results/new")(fillAction).as('customCreate)
  }
{% endhighlight %}

path declaration and define the action itself in `src/main/scala/controller/PollResultsController`

{% highlight scala %}
def fillAction = {
	set("roles" -> EmployeeRole.findAll())
   render("/pollResults/new")
  }
{% endhighlight %}

Last thing to consider is forbidding users from deleting resources just like that. You could either setup some kind of [authorization](http://skinny-framework.org/documentation/oauth.html) or remove the delete path by overriding it (as shown above) with action method using `haltWithBody(error code)`

## <a name="summary" href="#summary">Summary</a>

In my opinion Skinny is a great tool for creating prototypes and in situations when time to market is the most crucial factor. Im' looking forward to see how will it develop in the future. Also ... at Scalac we like Skinny's > logo :)

## <a name="links" href="#links">Links</a>

- [http://skinny-framework.org/documentation/getting-started.html](http://skinny-framework.org/documentation/getting-started.html)
