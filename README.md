# gitattributes

[![Build Status](https://api.travis-ci.com/realityforge/gitattributes.svg?branch=master)](http://travis-ci.org/realityforge/gitattributes)

Classes to parse `.gitattributes` files.

A simple example of it's usage:

### Read an existing .gitattributes

Read an existing file that looks like

```
README.md text eol=lf
*.jpg binary
```

With code that looks like

```ruby
require 'reality/gitattributes'

attributes = Reality::Git::Attributes.parse('/home/user/myrepo')
attributes.attributes('README.md') # => { "text" => true, "eol" => "lf }
attributes.attributes('*.jpg') # => { "binary" => true }
```

### Write .gitattributes

```ruby
require 'reality/gitattributes'

attributes = Reality::Git::Attributes.new('/home/user/myrepo')
attributes.dos_text_rule('*.cmd')
attributes.dos_text_rule('*.rdl', :eofnl => false)
attributes.unix_text_rule('*.sh')
attributes.text_rule('*.md')
attributes.binary_rule('*.jpg')

attributes.write_to('/home/user/myrepo/.gitattributes')
```

produces a file that looks like

```
*.cmd text eol=crlf
*.rdl text eol=crlf -eofnl
*.sh text eol=lf
*.md text
*.jpg binary
```

You could also pass `:prefix` and `:normalize` options to write_to method like

```ruby
attributes.write_to('/home/user/myrepo/.gitattributes', :normalize => true, :prefix => '# DO NOT EDIT: File is auto-generated')
```

to produce a file that looks like:

```
# DO NOT EDIT: File is auto-generated
*.cmd text eol=crlf
*.md text
*.rdl text eol=crlf -eofnl
*.sh text eol=lf
```
