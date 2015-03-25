---
layout: post
title:  "My Very Own Deployments Guide"
date:   2014-09-05 15:53:00
categories: programming rails ubuntu
---

For about the 5th time in the past 3 months, I'm in the process of setting up another deployment server to host my web apps and it's starting to get that repetitive feeling. Every time, I think I should take notes and then everytime I forget to, so here goes.

In case you're wondering, I'm certainly not the first to do this, so I turned to the steadfast wisdom of Lord Google &trade; and read through a few articles. This post is my own concoction, but many chunks of it will feel familiar having read through the resources below.

### My Resources:

* [Jon McCartie's Blog](http://blog.mccartie.com/2014/08/28/digital-ocean.html)
* [Vladi Gleba's 6-Parter](http://vladigleba.com/blog/2014/03/05/deploying-rails-apps-part-1-securing-the-server/)
* [The Flying Developer](http://theflyingdeveloper.com/server-setup-ubuntu-nginx-unicorn-capistrano-postgres/)

### My Stack:

* Ubuntu
* Nginx
* Rbenv
* Unicorn
* Mina

### Step 1- Get Yourself A Server
Hopefully you were expecting that. There's plenty of choices, but I've used [Amazon](http://aws.amazon.com/), [Digital Ocean](https://www.digitalocean.com/) and now [Rackspace](https://www.rackspace.com/). If you're really keen, you could always build it yourself, but I don't have that time on my hands.

Spec-wise, it's really up to you, and you'll obviously need to think about who's using the server, but here's my preference:

* Something with at least 1GB of RAM, for my unicorn workers.
* Storage can be pretty minimal, it only stores the rails app. I hate file uploads, so I tend to use carrierwave + some service (Imgur, CloudFiles, Dropbox, etc.).
* My preferred Server OS is Ubuntu. I've been using it since I was 7, it's easy and I'm yet to find a reason to change. Generally, I'll pick the LTS version, because, you know, it's the LTS version.

I also have a couple of commands I run every time I setup a server, because nano is the bane of my existence:

{% highlight bash %}
apt-get update
apt-get install -y vim
update-alternatives --config editor
# Then hit the number for vim
{% endhighlight %}

### Step 2- Get Yourself A User (And A Group)
Now the server's up and running- or you're still fiddling with a graphics card- let's get a user for our deployments. You can use the root user, but that's a bit dodgy. So let's setup that user:

{% highlight bash %}
groupadd deployers
adduser deploy -ingroup deployers
{% endhighlight %}

Now edit /etc/sudoers:
{% highlight bash %}
%deployers  ALL=(ALL) ALL
{% endhighlight %}

And add your ssh key:
{% highlight bash %}
su deploy
cd ~
mkdir .ssh
cd .ssh
vim authorized_keys
# Paste your public keyfile (ssh-keygen -t rsa)
{% endhighlight %}

From here on, I'm just going to assume you're logged in as the new deploy user.

Finally, make sure your server is up to date, and sort out time zones so you don't have to work out what was happening at 3am later on:
{% highlight bash %}
sudo apt-get -y update
sudo apt-get -y upgrade
sudo dpkg-reconfigure tzdata
{% endhighlight %}

### Step 3- Get Yourself A Proxy
In case you didn't know- and because I didn't- Nginx is actually a proxy server (which makes it a bit different to Apache). This is what makes it perfect for our use, we'll setup Nginx to proxy requests to our unicorn workers.

{% highlight bash %}
sudo add-apt-repository ppa:nginx/stable
sudo apt-get -y update
sudo apt-get -y install nginx
sudo service nginx start
{% endhighlight %}

You can edit /etc/nginx/nginx.conf if you want, but mine tends to stay pretty standard:
{% highlight nginx %}
user www-data;
worker_processes 4;
pid /run/nginx.pid;

events {
  worker_connections 768;
}

http {
  # Basic Settings

  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  keepalive_timeout 65;
  types_hash_max_size 2048;

  server_name_in_redirect off;

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  # Logging Settings

  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log;

  # Gzip Settings

  gzip on;
  gzip_disable "msie6";

  # Virtual Host Configs

  include /etc/nginx/conf.d/*.conf;
  include /etc/nginx/sites-enabled/*;
}
{% endhighlight %}

### Step 4- Get Yourself A Ruby
There's a whole thing out there about [http://rvm.io/](RVM) and [http://rbenv.org/](Rbenv) and which runs faster, jumps higher and all the rest, but I prefer to stay out of inane internet arguments for my own sanity. Right now, I'm preferring Rbenv, because it feels easier and lighter, but both are awesome, so go with your gut.

First we install rbenv and a bunch of dependencies:

{% highlight bash %}
sudo apt-get -y install git
sudo curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
sudo apt-get -y install zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev nodejs
{% endhighlight %}

There's a step in there that rbenv will tell you to do, but I seem to forget it all the time. Edit ~/.bash_profile:

{% highlight bash %}
export RBENV_ROOT="${HOME}/.rbenv"

if [ -d "${RBENV_ROOT}" ]; then
  export PATH="${RBENV_ROOT}/bin:${PATH}"
  eval "$(rbenv init -)"
fi
{% endhighlight %}

Then reload your environment:

{% highlight bash %}
source ~/.bash_profile
{% endhighlight %}

Now that rbenv is ready to go, install a ruby version (2.2.0 for me as of now) and bundler, because it's awesome:

{% highlight bash %}
rbenv install 2.2.0
rbenv global 2.2.0
gem install bundler
{% endhighlight %}

### Step 5- Get Yourself A Unicorn

It appears I got a little distracted here and forgot to update. This will be updated- soon, I hope.

### Step 6- Get Yourself A Mina
I've always used Capistrano as my deployment tool (other than the dark ages of FTP) but I really like the look of Mina, so I'm giving it a try.

First, add the mina gems:

{% highlight ruby %}
gem 'mina'
gem 'mina-unicorn', :require => false
{% endhighlight %}

Then set it up:

{% highlight bash %}
bundle install
bundle exec mina init
{% endhighlight %}

Then all it takes is a single command:

{% highlight bash %}
bundle exec mina deploy
{% endhighlight %}
