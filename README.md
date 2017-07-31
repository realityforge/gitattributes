# gitattributes

[![Build Status](https://secure.travis-ci.org/realityforge/gitattributes.png?branch=master)](http://travis-ci.org/realityforge/gitattributes)

Classes to parse `.gitattributes` files.

A simple example of it's usage:

```ruby
 attributes = Reality::Git::Attributes.parse('/home/user/myrepo')
 attributes.attributes('README.md') # => { "eol" => "lf }
```
