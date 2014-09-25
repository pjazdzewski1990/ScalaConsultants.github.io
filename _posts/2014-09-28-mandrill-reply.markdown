---
comments: true
date: 2014-01-13 14:10:22
layout: post
slug: about-add
title: About API driven development
summary: Today I'm going to tell you few things about API driven development that I learned while working on my last project, where we relied heavily on the API not only as a way of getting the apps working, but also as a central point of development process.
author: Patryk Jażdżewski
tags:
- API
- API driven development
- ADD
---

Today I'm going to tell you few things about API driven development that I learned while working on my last project, where we relied heavily on the API not only as a way of getting the apps working, but also as a central point of development process.

##What is API driven development? 
API driven development is a programming methodology that puts API in the center of attention and development effort. In this case, the API helps with:

- running the app – pretty self explanatory, we use the API to get data from server to frontend app, which is responsible for handling and displaying it to the user
- communication – the API is not only a contract between frontenders and backenders, but also a bridge that joins them. In this case, a clear separation between front- and backend work may lead to working in silos, with developers from one group having little or no knowledge about the other group. The back has to effectively query the DB and format the data for return. The frontend people on the other hand have to handle and display the data properly. With ADD even the slightest change in the contract has to been consulted between people on both sides. In order to do it properly they have to talk to each other and negotiate a solution that is satisfactory for both sides
- signalling requirements – the API specifies what behaviour and return data is expected from the backend system
- keeping it all together – having the API, schema, its description and usage examples in one place helps your developers to be up to date with requirements 
- testing – having a clear and well defined schema helps you test your software 
- opening your app to the world – when the contract is fixed and respected, other developers from outside are able to operate using your API and create applications you have never even dreamed about

##Our approach
I was working on an app that uses [AngularJS](http://angularjs.org/) for UI and Scala in the backend. In order to be up to date with all API requirements we created an automatic test suite that tested our return data against external schema for JSON response. We made sure that all the needed keys are present in the response, the type of each field matches and that the whole JSON structure is what we expect. Basically, this test suite became a constraint that caught bugs and prevented reckless API changes and mistakes from being applied in the code. 
Every time there was a need for a new API call, the frontender in need would negotiate with backender in charge of the implementation. After they both agreed on a solution that would fit the frontend needs and would be efficient on the backend side, the frontender would update the doc in [Apiary](http://apiary.io/) and the backender would create a test for that. Then they would both proceed with the implementation.

##Lessons learned
During the development I learned a few things, some of which are pretty obvious (although still worth mentioning), some fresh and new.

- Communicate! Communicate! Communicate! Don't live in a silo. Try to think not only about your targets and constraints, but also about the other side of the API
- When you know how the problem looks on both sides – negotiate to find the best solution
- Keep the important information about your system in one place that is easy to find. This will help keep things clear during development
- Provide examples – they explain more than plain text
- The API is too important to have sloppy tests or no tests at all
- Negotiation is about finding compromises. If the backend side is dominating, the API might end up with insufficient data for frontend to operate freely. If frontend always has the last word, the API might end up returning a huge blob of mostly unused data that was returned just in case. 

##Want more?
Some resources for further reading 

- [http://apiary.io/](http://apiary.io/) a great tool for specifying and testing your API, we used it a lot
- [http://developers.helloreverb.com/swagger/](http://developers.helloreverb.com/swagger/) toolbox similar to Apiary
- [http://www.infoq.com/presentations/api-driven-development](http://www.infoq.com/presentations/api-driven-development) Apiary CEO talks about API driven development
- [https://speakerdeck.com/kennethreitz/api-driven-development](https://speakerdeck.com/kennethreitz/api-driven-development) ADD at Heroku
- [https://github.com/ScalaConsultants/jsonComparator](https://github.com/ScalaConsultants/jsonComparator) a small tool what might help you in testing your API against a given schema

