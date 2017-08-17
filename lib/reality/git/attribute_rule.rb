#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Reality #nodoc
  module Git
    # Represents a rule within the attributes file
    class AttributeRule
      ATTR_ORDER = %w(text binary eol encoding eofnl)

      def initialize(pattern, attributes)
        @pattern = pattern.gsub('[[:space:]]', ' ')
        @attributes = {}
        @priority = 1
        attributes.each do |k, v|
          if k.to_s == 'priority'
            @priority = v
          else
            @attributes[k.to_s] = v
          end
        end
      end

      attr_reader :pattern
      attr_reader :attributes
      attr_reader :priority

      def to_s
        rule = self.pattern.gsub(' ', '[[:space:]]')

        attributes = self.attributes.dup
        ATTR_ORDER.each do |key|
          unless attributes[key].nil?
            rule = "#{rule}#{attr_value(key, attributes[key])}"
          end
        end
        attributes.keys.sort.each do |key|
          unless ATTR_ORDER.include?(key)
            rule = "#{rule}#{attr_value(key, attributes[key])}"
          end
        end

        rule
      end

      # noinspection RubySimplifyBooleanInspection
      def attr_value(key, value)
        if true == value
          " #{key}"
        elsif false == value
          " -#{key}"
        else
          " #{key}=#{value}"
        end
      end

      def eql?(other)
        self.pattern == other.pattern && self.attributes == other.attributes && self.priority == other.priority
      end

      def hash
        self.pattern.hash + self.attributes.hash + self.priority
      end

      def <=>(other)
        order = self.priority <=> other.priority
        if 0 != order
          order
        else
          to_s <=> other.to_s
        end
      end

      class << self
        def parse_line(line)
          line = line.strip
          return nil if line.start_with?('#') || line.empty?
          pattern, attrs = line.strip.split(/\s+/, 2)
          AttributeRule.new(pattern, attrs ? parse_attributes(attrs) : {})
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
