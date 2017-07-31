require 'reality/git/attributes_parser'

module Reality #nodoc
  # Class for parsing Git attribute files and extracting the attributes for
  # file patterns.
  #
  # Basic usage:
  #
  #     attributes = Reality::Git::Attributes.new(some_repo_path)
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

