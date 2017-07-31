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

require 'reality/git/attributes_parser'

module Reality #nodoc
  # Class for parsing Git attribute files and extracting the attributes for
  # file patterns.
  #
  # Basic usage:
  #
  #     attributes = Reality::GitAttributes.new(some_repo_path)
  #
  #     attributes.attributes('README.md') # => { "eol" => "lf" }
  class GitAttributes
    # path - The path to the Git repository.
    # attributes_file - The path to the ".gitattribtues" file. Defaults to "<path>/.gitattribtues".
    def initialize(repository_path, attributes_file = nil)
      @path = File.expand_path(repository_path)
      @attributes_file = attributes_file || "#{@path}/.gitattributes"
      @patterns =
        File.exist?(@attributes_file) ? Reality::Git::AttributesParser.parse_file(@attributes_file) : {}
    end

    # Returns all the Git attributes for the given path.
    #
    # path - A path to a file for which to get the attributes.
    #
    # Returns a Hash.
    def attributes(path)
      full_path = File.join(@path, path)

      @patterns.each do |pattern, attrs|
        return attrs if File.fnmatch?(File.join(@path, pattern), full_path)
      end

      {}
    end

    # Returns a Hash containing the file patterns and their attributes.
    def patterns
      @patterns.dup
    end
  end
end

