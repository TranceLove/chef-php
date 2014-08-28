# encoding: utf-8
#
# Author::  Panagiotis Papadomitsos (<pj@ezgr.net>)
# Author::  TranceLove (airwave209gt@gmail.com)
#
# Cookbook Name:: chefphp
# Recipe:: fpm
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

# Run the package installation at compile time
package node['php']['fpm_package'] do
  action :install
end

# This deletes the default FPM profile. Please use the fpm LWRP to define FPM pools
file "#{node['php']['fpm_pool_dir']}/www.conf" do
  action :delete
end

# Ubuntu uses a separate ini for FPM
template "#{node['php']['fpm_conf_dir']}/php.ini" do
  source 'php.ini.erb'
  owner 'root'
  group 'root'
  notifies :restart, "service[php-fpm]"
  mode 00644
  only_if { platform_family?('debian') }
end

# The generic server config
template "#{node['php']['fpm_conf_dir']}/php-fpm.conf" do
  source 'php-fpm.conf.erb'
  owner 'root'
  group 'root'
  notifies :restart, "service[php-fpm]"
  mode 00644
end

# For the pool log files
directory node['php']['fpm_log_dir'] do
  owner 'root'
  group 'root'
  mode 01733
  action :create
end

# Log rotation file
template node['php']['fpm_rotfile'] do
  source 'php-fpm.logrotate.erb'
  owner 'root'
  group 'root'
  mode 00644
end

# Since we do not have any pool files we do not attempt to start the service
service "php-fpm" do
  service_name('php5-fpm') if platform_family?('debian')
  action :enable
  provider(Chef::Provider::Service::Upstart)if (platform?('ubuntu') && node['platform_version'].to_f >= 14.04)
end
