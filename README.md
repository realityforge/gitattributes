# gitattributes

[![Build Status](https://secure.travis-ci.org/realityforge/gitattributes.png?branch=master)](http://travis-ci.org/realityforge/gitattributes)

Classes to parse `.gitattributes` files.

A simple example of it's usage:

```ruby
 attributes = Reality::Git::Attributes.new(some_repo.path)
 attributes.attributes('README.md') # => { "eol" => "lf }
```

## Credit

These classes were extracted from the [gitlab_git](https://gitlab.com/ben.boeckel/gitlab_git) by
with the gitattribtues code originally authored by Douwe Maan. All credit goes to the original
authors.
