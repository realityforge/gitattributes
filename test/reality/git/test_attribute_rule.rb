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

  def test_many_attributes
    rule = Reality::Git::AttributeRule.new('*.rdl', 'eofnl' => false, 'text' => true, 'crlf' => true, 'binary' => false, 'ms-file' => 'RPT', 'age' => '22')
    assert_equal({ 'eofnl' => false, 'text' => true, 'crlf' => true, 'binary' => false, 'ms-file' => 'RPT', 'age' => '22' }, rule.attributes)
    assert_equal('*.rdl text crlf -binary -eofnl age=22 ms-file=RPT', rule.to_s)
  end
end
