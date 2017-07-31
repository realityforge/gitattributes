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
          rules = File.exist?(attributes_file) ? Reality::Git::AttributesParser.parse_file(attributes_file) : {}
          Attributes.new(repository_path, attributes_file, relative_path, rules)
        end
      end

      def initialize(repository_path, attributes_file = nil, relative_path = nil, rules = [])
        @path = File.expand_path(repository_path)
        @attributes_file = attributes_file || "#{@path}/.gitattributes"
        @relative_path = relative_path || File.dirname(@attributes_file)
        @rules = rules
      end

      attr_reader :attributes_file

      # Returns the attributes for the specified path as a hash.
      def attributes(path)
        full_path = File.join(@path, path)

        @rules.reverse.each do |rule|
          return rule.attributes if File.fnmatch?(File.join(@relative_path, rule.pattern), full_path)
        end

        {}
      end

      def write_to(filename, options = {})
        prefix = options[:prefix].nil? ? '' : "#{options[:prefix]}\n"
        rules = options[:normalize] ? @rules.dup.sort.uniq : @rules
        content = rules.collect {|r| r.to_s }.join("\n")
        content += "\n" unless content.empty?
        IO.write(filename, prefix + content)
      end

      # Returns a list of attribute rules to apply.
      def rules
        @rules.dup
      end
    end
  end
end

