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
      ATTR_ORDER = %w(text crlf binary eofnl)

      def initialize(pattern, attributes)
        @pattern = pattern
        @attributes = attributes.dup
        @priority = @attributes.delete('priority') || 1
      end

      attr_reader :pattern
      attr_reader :attributes
      attr_reader :priority

      def to_s
        rule = self.pattern

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
    end
  end
end
