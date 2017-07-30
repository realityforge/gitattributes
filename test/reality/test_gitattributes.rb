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

require File.expand_path('../../helper', __FILE__)

class Reality::TestGitAttributes < Reality::TestCase
  def test_basic_operation_using_default_attribtues
    content = <<TEXT
* -text
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    write_standard_file(dir, content)

    attributes = Reality::GitAttributes.new(dir)
    assert_equal({ '*' => { 'text' => false } }, attributes.patterns)

    assert_equal({ 'text' => false }, attributes.attributes('README.md'))
  end

  def test_gitattributes_in_non_standard_location
    content = <<TEXT
* -text
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    attributes_file = "#{dir}/non-standard-gitattributes"
    write_file(attributes_file, content)

    attributes = Reality::GitAttributes.new(dir, attributes_file)
    assert_equal({ '*' => { 'text' => false } }, attributes.patterns)

    assert_equal({ 'text' => false }, attributes.attributes('README.md'))
    assert_equal({ 'text' => false }, attributes.attributes('docs/README.md'))
  end

  def test_multi_value_attribute
    content = <<TEXT
*.textile text -crlf -binary
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    write_standard_file(dir, content)

    attributes = Reality::GitAttributes.new(dir)
    assert_equal({ '*.textile' => { 'text' => true, 'crlf' => false, 'binary' => false } },
                 attributes.patterns)

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

    attributes = Reality::GitAttributes.new(dir)
    assert_equal({
                   '*' => { 'text' => false },
                   '*.textile' => { 'text' => true, 'crlf' => false, 'binary' => false }
                 },
                 attributes.patterns)

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

    attributes = Reality::GitAttributes.new(dir)
    assert_equal({ '*' => { 'text' => false } }, attributes.patterns)
  end

  def test_relative_dir
    content = <<TEXT
doc/*.md text
TEXT
    dir = "#{working_dir}/#{::SecureRandom.hex}"
    write_standard_file(dir, content)

    attributes = Reality::GitAttributes.new(dir)
    assert_equal({ 'doc/*.md' => { 'text' => true } }, attributes.patterns)

    assert_equal({}, attributes.attributes('README.md'))
    assert_equal({ 'text' => true }, attributes.attributes('doc/X.md'))
  end

  def write_standard_file(dir, content)
    write_file("#{dir}/.gitattributes", content)
  end

  def write_file(attributes_file, content)
    FileUtils.mkdir_p File.dirname(attributes_file)
    IO.write(attributes_file, content)
  end
end
