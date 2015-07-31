---
layout: post
title:  "My Beautiful Dark Twisted Encryption"
date:   2015-07-31 08:45:00
categories: programming encryption databases
---

I've got another confession to make- I've relied on user/password libraries for far too long. It's not a particularly glamorous or enjoyable part of web/app development, so I inevitable turn to some kind of library to do the storing, the comparing and I focus on the pretty colours for the login page.

That sinking feeling in my gut is probably linked to the thought that leaving password storage, encryption, etc. to a third party attack might be why [Ashley Madison is having some 'issues'][afr-ashley-madison]. However, that's probably not the reason I'm thinking about this. Recently, I've been playing with node.js and express as an alternative to ruby and rails, whilst watching the [Handmade Hero][handmade-hero] video series.

__Quick Sidenote:__ Express isn't really comparable to Rails, it's more like Sinatra- very lightweight with an absolute crapton of plugins.

I was inspired by Casey Muratori's approach to game making (even though I never want to program a game), which goes very low level in understanding and implementing concepts and code. At the same time, the express library is incredibly unopinionated (with requirejs allowing any kind of modularity you could wish), so it allows me to go to similarly low levels in implementing a new web app.

So, on with the show. Here's the sum total of my knowledge on passwords and encryption and what not:
* __Don't store passwords in plain text__- This one might feel like a no-brainer but apparently [it's not for everybody][plaintext-offenders].
* __Not all hashing functions are created equal__- I knew this, but only as a kind of mantra. Having now read [Coda Hale's Article][use-bcrypt], I think I get it, but more on that later.
* __Salting__- Is the process of adding a unique string to the start of the password before hashing it.

And that's about it. Beyond knowing I could download the BCrypt library for a given language, I really don't know much. That's when I decided to do some research. I'm still no expert, but here are some of the attacks, and ways to stop them.

### A Script that tries to Login

Let's say you've got a simple email and password login screen. Our malicious attackers already know the user's email address but not the password. Put simply, these attackers might try a whole lot of passwords on that one username. To stop this, most sites implement a lockdown/password reset after a number of incorrect attempts.

### Accessing the database records

Alright, let's go a little deeper and say you forgot to change the user on the database from admin:admin and now the malicious attackers have downloaded your user table.

If you kept the passwords in plain text, well that's it, but we're good database admins and we'd never do that. Right? Right?

We're slightly better database admins now, we've encrypted our passwords with MD5. Our attackers aren't silly, they can tell we've used MD5, so they use a little trick called Rainbow Tables. Instead of testing the passwords on the spot, they generate the MD5 hash of a pile of passwords before hand, and check to see if your hashed value matches one of them. By doing this, they can significantly reduce the time taken to crack a password by implementing a large table instead of continuously determining the value.

So, with that knowledge, we implement our salt. We store it beside the hashed password in the table (so our attackers have it too). Unfortunately, your average computer with a decent graphics card can compare 2.8 trillion passwords hashed with MD5 or similar every second, so the attackers might not be able to prepare the rainbow table in advance, but they should have a pretty easy time of cracking the password.

What's the answer then. As far as I can tell, it's called key stretching- and basically it's purpose is to slow down the process. We still use a salt (otherwise rainbow table would still cause problems), but we use an algorithm that takes a significant amount of time (for a computer) to process, generally around a second. If I'm a user logging into your site, a second isn't particularly noticable. But if the attacker to try 2.8 trillion passwords to guess yours, it will take 2.8 trillion seconds (around 80,000 years). That's not bad.

There are a couple of algorithms/libraries that do this. Bcrypt, Scrypt and PBKDF2 are they ones I know of. Importantly, they also include what they call a cost factor, a number which increases the amount of time taken to perform the action. This means even as technology improves, these algorithms can continue to be useful by increasing that cost factor.

__Now what?__ Well, I'm probably going to go and download that BCrypt library. But if I've scared you significantly enough to worry about how your own passwords are being stored, there are a few things you can do:

* __Don't reuse passwords__- You can't trust the website you're using, no matter what. So don't use the same password in two places, or one cracked account will lead to a lot more.
* __Keep them long__- [How Secure is my Password?][https://howsecureismypassword.net/] is a great website for understanding the value of a long password over just a varied password. Use sentences with punctuation and numbers in them to improve the strength.
* __Don't write them down__- The temptation is strong, but if you want to keep all in one place, services like [keepass][http://keepass.info/] and [passpack][https://www.passpack.com] can be particularly useful. Make sure you understand what they're doing and how they work before you start using them though.

[afr-ashley-madison]: http://www.afr.com/technology/why-ashley-madison-hack-exposes-aussie-businesses-and-poses-ethical-questions-20150727-giim1q
[handmade-hero]: https://handmadehero.org/
[plaintext-offenders]: http://plaintextoffenders.com/
[use-bcrypt]: http://codahale.com/how-to-safely-store-a-password/
