#
# Author::  Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Cookbook Name:: php
# Recipe:: module_xml
#
# Copyright 2009-2012, Panagiotis Papadomitsos
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

case node['platform_family']
when 'debian'
	%w{ xmlrpc xsl }.each do |pkg|
  		package "php5-#{pkg}" do
    		action :install
        notifies(:run, "execute[/usr/sbin/php5enmod #{pkg}]", :immediately) if platform?('ubuntu') && node['platform_version'].to_f >= 12.04
      end
  end
when 'rhel', 'fedora'
  %w{ xml xmlrpc }.each do |pkg|
      package "php-#{pkg}" do
        action :install
      end
  end
end

execute '/usr/sbin/php5enmod xmlrpc' do
  action :nothing
  only_if { platform?('ubuntu') && node['platform_version'].to_f >= 12.04 }
end

execute '/usr/sbin/php5enmod xsl' do
  action :nothing
  only_if { platform?('ubuntu') && node['platform_version'].to_f >= 12.04 }
end
