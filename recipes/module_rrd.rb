# encoding: utf-8
#
# Author::  Panagiotis Papadomitsos (<pj@ezgr.net>)
# Author::  TranceLove (airwave209gt@gmail.com)
#
# Cookbook Name:: chefphp
# Recipe:: module_rrd
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
when 'rhel', 'fedora'
	%w{ rrdtool rrdtool-devel }.each do |pkg|
		package pkg do
			action :install
		end
	end
    php_pear 'rrd' do
      action :install
    end
when 'debian'
	package 'php5-rrd' do
		action :install
    notifies(:run, "execute[/usr/sbin/php5enmod rrd]", :immediately) if platform?('ubuntu') && node['platform_version'].to_f >= 12.04
  end
end

execute '/usr/sbin/php5enmod rrd' do
  action :nothing
  only_if { platform?('ubuntu') && node['platform_version'].to_f >= 12.04 && ::File.exists?('/usr/sbin/php5enmod') }
end
