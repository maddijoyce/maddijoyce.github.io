---
layout: post
title:  "An Exploration in Ember- Specifically, Addons"
date:   2014-09-05 11:30:00
categories: programming ember
---

I've been mucking around with Ember.js for about 6 months now and seriously enjoy working with it. The whole product is really easy to use (admittedly, once you get your head around it) and it's fantastic. The product I'm working on at the moment consists of a 3 part system;
* API- A rails based JSON api. The rails app doesn't have any views, but does use [Active Model Serializers](https://github.com/rails-api/active_model_serializers) to generate the correct JSON. Ember.js has the Active Model Adapter built in, so it's brilliantly easy to configure the 2 systems together.
* Admin- An Ember based administration web application.
* Web- An Ember based, customer facing web application.

I decided to keep the admin and web components completely separate so they could be extricated later on if need be, but about 3 months in I realized I was duplicating a hell of a lot of code. In some situations, I was copy-pasting entire files because there was so much crossover.

I considered rolling the two ember apps into one, but it still didn't make sense to the way the apps are designed. I wanted them kept completely separate so I was going to make sure they were. My initial attempts included;
* Making the folder structure fit both applications- Don't even bother. This was an absolute nightmare.
* Using symbolic links- I thought I'd hit the jackpot here, but there were 2 issues. 1. I do have some files that I only need on one site or the other, and 2. Node doesn't like symbolic links.

Next I turned to Github, and had [an answer](https://github.com/stefanpenner/ember-cli/issues/1814) within minutes. Robert Jackson to the rescue with ember addons.

So, I followed a couple of tutorials and instructions but there was nothing that fit exactly what I was doing, so it was a bit of trial and error. Anyway, without further ado, this is how it went.

### My resources:
* [Dockyard Blog Article](http://reefpoints.dockyard.com/2014/06/24/introducing_ember_cli_addons.html)
* [HashRocket Blog Article](http://hashrocket.com/blog/posts/building-ember-addons)

### Step 1- Creating the Addon
The easiest way to setup an addon is using NPM, which worried me until I realized private NPM packages exist and are easy to setup. So, I created my folder 'shared' and added a couple of files:
#### package.json
```json
{
  "name": "shared-addon",
  "version": "0.0.1",
  "keywords": [
    "ember-addon"
  ],
  "private": true,
  "devDependencies": {}
}
```
The important aspects here are you must include the keywords 'ember-addon' and, if you don't want to publish your code, set 'private'.

#### .bowerrc
```json
{
  "directory": "vendor"
}
```
#### bower.json
```json
{
  "name": "shared-addon",
  "dependencies": {
    "momentjs": "~2.8.2"
  }
}

```
These files aren't specifically required, but I found I was using a lot of the same vendor code, so to manage dependencies, I pulled all of them back to the shared module and, to fit with ember's settings, set the bower directory to 'vendor'.

#### index.js
```javascript
// This code from http://hashrocket.com/blog/posts/building-ember-addons
var path = require('path');
var fs   = require('fs');

function Shared(project) {
  this.project = project;
  this.name    = 'Shared';
}

function unwatchedTree(dir) {
  return {
    read:    function() { return dir; },
    cleanup: function() { }
  };
}

//'shared-addon' below is the same as the name for your node module.
Shared.prototype.treeFor = function treeFor(name) {
  var treePath =  path.join('node_modules', 'shared-addon', name);

  if (fs.existsSync(treePath)) {
    return unwatchedTree(treePath);
  }
};

//Here we add any imported javascript (e.g. momentjs, bootstrap)
Shared.prototype.included = function included(app) {
  this.app = app;

  this.app.import('vendor/momentjs/moment.js');
};

module.exports = Shared;
```
And the Shared Addon is now setup.

### Step 2- Adding some shared files.
The ember addon structure will call 'treeFor' for a number of different files. I got a little confused here because it doesn't match the Ember App setup exactly. As far as I can tell the distinction is based on file type more than anything else. My folder structure looks a little like this.

* /
 * app (_For javascript files_)
   * adapters/
   * components/
   * helpers/
   * mixins/
   * models/
   * serializers/
   * transforms/
   * views/
 * styles (_For SASS files_)
   * _partial.scss
 * templates (_For handlebars files_)
   * components/

This tree gets merged with the application, so my files are available as if they were a part of the original application.

And that's it. You're all setup.

To include your addon in an ember app, it takes just one command:
```
npm install ../shared
```
(You can use a relative or absolute path here.)

### One Last Caveat- Static Assets
Ember static assets are dropped in the 'public' folder, but this folder isn't pulled across by ember addons. To combat that, I dropped my static files in an 'assets' folder in the addon and my 'brocfile.js' looks like this:
```javascript
var mergeTrees = require('broccoli-merge-trees');
var pickFiles = require('broccoli-static-compiler');

var EmberApp = require('ember-cli/lib/broccoli/ember-app');

var app = new EmberApp();

var sharedFonts = pickFiles('node_modules/shared-addon/assets/fonts', {
  srcDir: '/',
  destDir: '/assets/fonts'
});
var sharedImages = pickFiles('node_modules/shared-addon/assets/images', {
  srcDir: '/',
  destDir: '/assets/images'
})

module.exports = mergeTrees([app.toTree(), sharedFonts, sharedImages]);
```
It's a little messy, but it works and I can share my fonts and images between apps.