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


{% highlight bash %}
//install software
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

## <a name="summary" href="#summary">Summary</a>

In my opinion Skinny is a great tool for creating prototypes and in situations when time to market is the most crucial factor. Im' looking forward to see how will it develop in the future. Also ... at Scalac we like Skinny's logo :)

## <a name="links" href="#links">Links</a>

- [http://skinny-framework.org/documentation/getting-started.html](http://skinny-framework.org/documentation/getting-started.html)
