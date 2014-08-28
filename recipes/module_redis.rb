#
# Author:: TranceLove (<airwave209gt@gmail.com>)
#
# Cookbook Name:: chefphp
# Recipe:: module_redis
#
# Copyright 2014, TranceLove
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

pkg = value_for_platform_family(
    [ 'rhel', 'fedora' ] => 'php-redis',
    'debian' => 'php5-redis'
)

package pkg do
  action :install
  notifies(:run, "execute[/usr/sbin/php5enmod redis]", :immediately) if platform?('ubuntu') && node['platform_version'].to_f >= 12.04
end

execute '/usr/sbin/php5enmod redis' do
  action :nothing
  only_if { platform?('ubuntu') && node['platform_version'].to_f >= 12.04 && ::File.exists?('/usr/sbin/php5enmod') }
end
