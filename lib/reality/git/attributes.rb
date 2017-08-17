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
  module Git #nodoc
    # Representation of a gitattributes file.
    class Attributes

      class << self
        # path - The path to the Git repository.
        # attributes_file - The path to the ".gitattributes" file. Defaults to "<path>/.gitattributes".
        # relative_path - The path to which attributes apply. Defaults to direcotyr containing attributes file.
        def parse(repository_path, attributes_file = nil, relative_path = nil)
          path = File.expand_path(repository_path)
          attributes_file ||= "#{path}/.gitattributes"
          rules = File.exist?(attributes_file) ? parse_file(attributes_file) : []
          Attributes.new(repository_path, attributes_file, relative_path, rules)
        end

        private

        def parse_file(filename)
          rules = []

          IO.readlines(filename).each do |line|
            rule = AttributeRule.parse_line(line)
            rules << rule if rule
          end

          rules
        end
      end

      def initialize(repository_path, attributes_file = nil, relative_path = nil, rules = [])
        @path = File.expand_path(repository_path)
        @attributes_file = attributes_file || "#{@path}/.gitattributes"
        @relative_path = relative_path || File.dirname(@attributes_file)
        @rules = rules
        @rule_map = {}
        rules.each do |rule|
          cache_rule(rule)
        end
      end

      attr_reader :attributes_file

      # Returns the attributes for the specified path as a hash.
      def attributes(path)
        full_path = File.join(@path, path)

        self.rules.reverse.each do |rule|
          full_pattern = rule.pattern[0] == '/' ? "#{@relative_path}#{rule.pattern}" : "#{@relative_path}/**/#{rule.pattern}"
          return rule.attributes if File.fnmatch?(full_pattern, full_path, File::FNM_PATHNAME | File::FNM_DOTMATCH)
        end

        {}
      end

      # Returns the rules for the specified path.
      def rules_for_path(path)
        full_path = File.join(@path, path)

        rules = []

        self.rules.each do |rule|
          full_pattern = rule.pattern[0] == '/' ? "#{@relative_path}#{rule.pattern}" : "#{@relative_path}/**/#{rule.pattern}"
          rules << rule if File.fnmatch?(full_pattern, full_path, File::FNM_PATHNAME | File::FNM_DOTMATCH)
        end

        rules
      end

      def as_file_contents(options = {})
        prefix = options[:prefix].nil? ? '' : "#{options[:prefix]}\n"
        rules = self.rules
        rules = rules.dup.sort.uniq if options[:normalize]
        content = rules.collect {|r| r.to_s}.join("\n")
        content += "\n" unless content.empty?
        prefix + content
      end

      def write_to(filename, options = {})
        IO.write(filename, as_file_contents(options))
      end

      def write(options = {})
        write_to(@attributes_file, options)
      end

      def rule(pattern, attributes)
        rule = AttributeRule.new(pattern, attributes)
        @rules << rule
        cache_rule(rule)
        rule
      end

      def remove_rule(rule)
        uncache_rule(rule) if @rules.delete(rule)
      end

      # Adds a rule for pattern that sets the text attribute.
      # This means that the file will be stored in the repository with line endings converted to LF
      def text_rule(pattern, attributes = {})
        rule(pattern, { :text => true }.merge(attributes))
      end

      # Adds a rule for pattern that sets the text attribute and eol=lf.
      # This means that the file will be stored in the repository with line endings converted to LF
      # *and* the local checkout will have line endings converted to LF
      def unix_text_rule(pattern, attributes = {})
        text_rule(pattern, { :eol => 'lf' }.merge(attributes))
      end

      # Adds a rule for pattern that sets the text attribute and eol=crlf.
      # This means that the file will be stored in the repository with line endings converted to LF
      # *and* the local checkout will have line endings converted to CRLF
      def dos_text_rule(pattern, attributes = {})
        text_rule(pattern, { :eol => 'crlf' }.merge(attributes))
      end

      def binary_rule(pattern, attributes = {})
        rule(pattern, { :binary => true }.merge(attributes))
      end

      # Returns a list of attribute rules to apply.
      def rules
        @rules.dup
      end

      def rules_by_pattern(pattern)
        @rule_map[pattern].nil? ? [] : @rule_map[pattern].dup
      end

      def rules_by_pattern?(pattern)
        !rules_by_pattern(pattern).empty?
      end

      private

      def cache_rule(rule)
        (@rule_map[rule.pattern] ||= []) << rule
      end

      def uncache_rule(rule)
        (@rule_map[rule.pattern] ||= []).delete(rule)
      end
    end
  end
end

