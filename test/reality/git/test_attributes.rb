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

require File.expand_path('../../../helper', __FILE__)

class Reality::TestAttributes < Reality::TestCase
  def test_basic_operation_using_default_attributes
    content = <<TEXT
* -text
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    write_standard_file(dir, content)

    attributes = Reality::Git::Attributes.parse(dir)
    assert_equal("#{dir}/.gitattributes", attributes.attributes_file)
    assert_equal(['* -text'], attributes.rules.collect{|p|p.to_s})

    assert_equal({ 'text' => false }, attributes.attributes('README.md'))
  end

  def test_gitattributes_in_non_standard_location
    content = <<TEXT
* -text
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    attributes_file = "#{dir}/non-standard-gitattributes"
    write_file(attributes_file, content)

    attributes = Reality::Git::Attributes.parse(dir, attributes_file)
    assert_equal(attributes_file, attributes.attributes_file)
    assert_equal(['* -text'], attributes.rules.collect{|p|p.to_s})

    assert_equal({ 'text' => false }, attributes.attributes('README.md'))
    assert_equal({ 'text' => false }, attributes.attributes('docs/README.md'))
  end

  def test_multi_value_attribute
    content = <<TEXT
*.textile text -crlf -binary
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    write_standard_file(dir, content)

    attributes = Reality::Git::Attributes.parse(dir)
    assert_equal(['*.textile text -crlf -binary'], attributes.rules.collect{|p|p.to_s})

    assert_equal({}, attributes.attributes('README.md'))
    assert_equal({ 'text' => true, 'crlf' => false, 'binary' => false }, attributes.attributes('README.textile'))
    assert_equal({ 'text' => true, 'crlf' => false, 'binary' => false }, attributes.attributes('doc/X.textile'))
  end

  def test_multi_patterns
    content = <<TEXT
* -text
*.textile text -crlf -binary
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    write_standard_file(dir, content)

    attributes = Reality::Git::Attributes.parse(dir)
    assert_equal(['* -text', '*.textile text -crlf -binary'], attributes.rules.collect{|p|p.to_s})

    assert_equal({ 'text' => false }, attributes.attributes('README.md'))
    assert_equal({ 'text' => true, 'crlf' => false, 'binary' => false }, attributes.attributes('doc/X.textile'))
  end

  def test_ignore_comments
    content = <<TEXT
# DO NOT EDIT: File is auto-generated
* -text
# DO NOT EDIT: File is auto-generated
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    write_standard_file(dir, content)

    attributes = Reality::Git::Attributes.parse(dir)
    assert_equal("#{dir}/.gitattributes", attributes.attributes_file)
    assert_equal(['* -text'], attributes.rules.collect{|p|p.to_s})
  end

  def test_relative_dir
    content = <<TEXT
doc/*.md text
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    write_standard_file(dir, content)

    attributes = Reality::Git::Attributes.parse(dir)
    assert_equal("#{dir}/.gitattributes", attributes.attributes_file)
    assert_equal(['doc/*.md text'], attributes.rules.collect{|p|p.to_s})

    assert_equal({}, attributes.attributes('README.md'))
    assert_equal({ 'text' => true }, attributes.attributes('doc/X.md'))
  end

  def test_gitattributes_in_subdirectory
    content = <<TEXT
* -text
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    attributes_file = "#{dir}/foo/.gitattributes"
    write_file(attributes_file, content)

    attributes = Reality::Git::Attributes.parse(dir, attributes_file)
    assert_equal(attributes_file, attributes.attributes_file)
    assert_equal(['* -text'], attributes.rules.collect{|p|p.to_s})

    assert_equal({}, attributes.attributes('README.md'))
    assert_equal({ 'text' => false }, attributes.attributes('foo/docs/README.md'))
  end

  def test_write_to
    content = <<TEXT
* -text
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    write_standard_file(dir, content)

    attributes = Reality::Git::Attributes.parse(dir)
    assert_equal("#{dir}/.gitattributes", attributes.attributes_file)
    assert_equal(['* -text'], attributes.rules.collect{|p|p.to_s})

    output_filename = "#{dir}/output_gitattributes"
    attributes.write_to(output_filename)

    assert_equal(<<TEXT, IO.read(output_filename))
* -text
TEXT
  end

  def test_write_to_with_multiple_rules
    content = <<TEXT
*.md text
* -text
*.java text
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    write_standard_file(dir, content)

    attributes = Reality::Git::Attributes.parse(dir)
    assert_equal("#{dir}/.gitattributes", attributes.attributes_file)
    assert_equal(['*.md text', '* -text', '*.java text'], attributes.rules.collect{|p|p.to_s})

    output_filename = "#{dir}/output_gitattributes"
    attributes.write_to(output_filename)

    assert_equal(<<TEXT, IO.read(output_filename))
*.md text
* -text
*.java text
TEXT
  end

  def test_write_to_with_normalization
    content = <<TEXT
*.md text
* -text
*.java text
*.java text
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    write_standard_file(dir, content)

    attributes = Reality::Git::Attributes.parse(dir)
    assert_equal("#{dir}/.gitattributes", attributes.attributes_file)
    assert_equal(['*.md text', '* -text', '*.java text', '*.java text'], attributes.rules.collect{|p|p.to_s})

    output_filename = "#{dir}/output_gitattributes"
    attributes.write_to(output_filename, :normalize => true)

    assert_equal(<<TEXT, IO.read(output_filename))
* -text
*.java text
*.md text
TEXT
  end

  def test_write_to_with_prefix
    content = <<TEXT
* -text
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    write_standard_file(dir, content)

    attributes = Reality::Git::Attributes.parse(dir)
    assert_equal("#{dir}/.gitattributes", attributes.attributes_file)
    assert_equal(['* -text'], attributes.rules.collect{|p|p.to_s})

    output_filename = "#{dir}/output_gitattributes"
    attributes.write_to(output_filename, :prefix => '# DO NOT EDIT: File is auto-generated')

    assert_equal(<<TEXT, IO.read(output_filename))
# DO NOT EDIT: File is auto-generated
* -text
TEXT
  end

  def write_standard_file(dir, content)
    write_file("#{dir}/.gitattributes", content)
  end

  def write_file(attributes_file, content)
    FileUtils.mkdir_p File.dirname(attributes_file)
    IO.write(attributes_file, content)
  end
end