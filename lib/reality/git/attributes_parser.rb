# Copyright (c) 2017 Peter Donald
# Copyright (c) 2013 Dmitriy Zaporozhets
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# These classes were extracted from the https://gitlab.com/ben.boeckel/gitlab_git repository
# with the gitattribtues code originally authored by Douwe Maan. Credit to the original authors.

module Reality #nodoc
  module Git
    # Parse the Git attribute file extracting the attributes for file patterns.
    module AttributesParser
      class << self

        # Parses the specified Git attributes file.
        def parse_file(filename)
          pairs = []
          comment = '#'

          IO.readlines(filename).each do |line|
            next if line.start_with?(comment) || line.empty?

            pattern, attrs = line.split(/\s+/, 2)

            parsed = attrs ? parse_attributes(attrs) : {}

            pairs << [pattern, parsed]
          end

          # Newer entries take precedence over older entries.
          pairs.reverse.to_h
        end

        private

        # Parses an attribute string.
        #
        # These strings can be in the following formats:
        #
        #     text      # => { "text" => true }
        #     -text     # => { "text" => false }
        #     key=value # => { "key" => "value" }
        #
        # string - The string to parse.
        #
        # Returns a Hash containing the attributes and their values.
        def parse_attributes(string)
          values = {}
          dash = '-'
          equal = '='
          binary = 'binary'

          string.split(/\s+/).each do |chunk|
            # Data such as "foo = bar" should be treated as "foo" and "bar" being
            # separate boolean attributes.
            next if chunk == equal

            key = chunk

            # Input: "-foo"
            if chunk.start_with?(dash)
              key = chunk.byteslice(1, chunk.length - 1)
              value = false

              # Input: "foo=bar"
            elsif chunk.include?(equal)
              key, value = chunk.split(equal, 2)

              # Input: "foo"
            else
              value = true
            end

            values[key] = value

            # When the "binary" option is set the "diff" option should be set to
            # the inverse. If "diff" is later set it should overwrite the
            # automatically set value.
            values['diff'] = false if key == binary && value
          end

          values
        end
      end
    end
  end
end

