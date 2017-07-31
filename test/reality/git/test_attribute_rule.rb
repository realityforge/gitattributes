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

class Reality::Git::TestAttributeRule < Reality::TestCase
  def test_basic_operation
    rule = Reality::Git::AttributeRule.new('*', 'text' => false)
    assert_equal({ 'text' => false }, rule.attributes)
    assert_equal('* -text', rule.to_s)
    assert_equal(1, rule.priority)
  end

  def test_priority_specified
    rule = Reality::Git::AttributeRule.new('*', 'text' => false, 'priority' => 3)
    assert_equal(3, rule.priority)
    assert_equal({ 'text' => false }, rule.attributes)
    assert_equal('* -text', rule.to_s)
  end

  def test_many_attributes
    rule = Reality::Git::AttributeRule.new('*.rdl', 'eofnl' => false, 'text' => true, 'crlf' => true, 'binary' => false, 'ms-file' => 'RPT', 'age' => '22')
    assert_equal({ 'eofnl' => false, 'text' => true, 'crlf' => true, 'binary' => false, 'ms-file' => 'RPT', 'age' => '22' }, rule.attributes)
    assert_equal('*.rdl text crlf -binary -eofnl age=22 ms-file=RPT', rule.to_s)
  end

  def test_sorting
    rule1 = Reality::Git::AttributeRule.new('*.a', 'priority' => 2, 'text' => true)
    rule2 = Reality::Git::AttributeRule.new('*.b', 'priority' => 2, 'text' => true)
    rule3 = Reality::Git::AttributeRule.new('*.c', 'priority' => 1, 'text' => true)
    assert_equal(0, rule1 <=> rule1)
    assert_equal(0, rule2 <=> rule2)
    assert_equal(0, rule3 <=> rule3)
    assert_equal(-1, rule1 <=> rule2)
    assert_equal(1, rule1 <=> rule3)
    assert_equal(1, rule2 <=> rule3)
    assert_equal([rule3, rule1, rule2], [rule1, rule2, rule3].sort)
  end

  def test_eql
    rule1 = Reality::Git::AttributeRule.new('*.a', 'priority' => 2, 'text' => true)
    rule2 = Reality::Git::AttributeRule.new('*.a', 'priority' => 3, 'text' => true)
    assert_equal(true, rule1.eql?(rule1))
    assert_equal(rule1.hash, rule1.hash)
    assert_equal(false, rule1.eql?(rule2))
    assert_not_equal(rule1.hash, rule2.hash)
  end
end
