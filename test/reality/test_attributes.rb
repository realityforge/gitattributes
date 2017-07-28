require File.expand_path('../../helper', __FILE__)

class Reality::TestAttributes < Reality::TestCase
  def test_basic_operation_using_default_attribtues
    content = <<TEXT
* -text
TEXT
    dir = random_local_dir
    write_standard_file(dir, content)

    attributes = Reality::Git::Attributes.new(dir)
    assert_equal({ "#{dir}/*" => { 'text' => false } }, attributes.patterns)

    assert_equal({ 'text' => false }, attributes.attributes('README.md'))
  end

  def test_gitattributes_in_non_standard_location
    content = <<TEXT
* -text
TEXT
    dir = random_local_dir
    attributes_file = "#{dir}/non-standard-gitattributes"
    write_file(attributes_file, content)

    attributes = Reality::Git::Attributes.new(dir, attributes_file)
    assert_equal({ "#{dir}/*" => { 'text' => false } }, attributes.patterns)

    assert_equal({ 'text' => false }, attributes.attributes('README.md'))
    assert_equal({ 'text' => false }, attributes.attributes('docs/README.md'))
  end

  def test_multi_value_attribute
    content = <<TEXT
*.textile text -crlf -binary
TEXT
    dir = random_local_dir
    write_standard_file(dir, content)

    attributes = Reality::Git::Attributes.new(dir)
    assert_equal({ "#{dir}/*.textile" => { 'text' => true, 'crlf' => false, 'binary' => false } },
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
    dir = random_local_dir
    write_standard_file(dir, content)

    attributes = Reality::Git::Attributes.new(dir)
    assert_equal({
                   "#{dir}/*" => { 'text' => false },
                   "#{dir}/*.textile" => { 'text' => true, 'crlf' => false, 'binary' => false }
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
    dir = random_local_dir
    write_standard_file(dir, content)

    attributes = Reality::Git::Attributes.new(dir)
    assert_equal({ "#{dir}/*" => { 'text' => false } }, attributes.patterns)
  end

  def write_standard_file(dir, content)
    write_file("#{dir}/.gitattributes", content)
  end

  def write_file(attributes_file, content)
    FileUtils.mkdir_p File.dirname(attributes_file)
    IO.write(attributes_file, content)
  end
end
