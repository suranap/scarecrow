
Introduction
------------

Scarecrow uses Prolog to monitor and administer resources on [Amazon
Web Services](http://aws.amazon.com). It is (or will be) an expert
system for manipulating AWS automatically.

The current state of your AWS account is called the _initial state_
(I). The state you wish to achieve is called the _goal state_ (G). The
goal state could be a web deployment, a DB backup, a modified security
group, etc. How do you get from I to G? You could use the AWS
management console to manually perform the required actions, but this
is tedious and error-prone. You could instead write a script to
perform these same actions programmatically, but you would need to
write different scripts for every different task or goal.

Scarecrow, by contrast, is sort of like a script generator. All you
need to do is declare the _goal state_ you wish to reach. It will
query AWS to discover the _initial state_. Then it will use a library
of predefined domain-specific rules to determine the sequence of
actions required to get from I to G. 

Why Prolog? The language is unique for its powerful support for
backtracking and unification. The first is used to search for a path
from I to G to accomplish a task. The latter is used to make complex
queries on the state of your AWS deployment. Think of it as a weird
SQL query. 

How is this different from [boto](http://code.google.com/p/boto/) or a
million other libraries for AWS? These libraries are merely a
programming interface to AWS, but you still have to write all the
scripts yourself. Scarecrow is a level up from this: it _writes_ the
scripts for you. Well, it might someday... 

Here's another attempt at [explaining the purpose of
Scarecrow](http://surana.wordpress.com/2011/07/13/prolog-and-aws/).


Requirements
------------

* [SWI-Prolog](http://www.swi-prolog.org) v5.8.0
* [AWS perl script](http://timkay.com/aws/)


