# encoding: utf-8
#
# Author::  TranceLove (airwave209gt@gmail.com)
# Cookbook Name:: chefphp
# Recipe:: module_yaml
#
# Copyright 2009-2011, Opscode, Inc.
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

%w(libyaml-dev php5-dev build-essential php-pear).each do |pkg|
    package pkg do
        action :install
    end
end

execute "Install PECL YAML extension without human intervention" do
    command "printf \\n | pecl install yaml"
    not_if { File.exists?("#{node['php']['ext_conf_dir']}/yaml.ini") }
end

template "#{node['php']['ext_conf_dir']}/yaml.ini" do
  only_if { platform?('ubuntu') && node['platform_version'].to_f >= 12.04 && ::File.exists?('/usr/sbin/php5enmod') }
  source 'extension.ini.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables({
    :name => 'yaml',
    :directives => {}
  })
end

execute '/usr/sbin/php5enmod yaml' do
  only_if { platform?('ubuntu') && node['platform_version'].to_f >= 12.04 && ::File.exists?('/usr/sbin/php5enmod') }
end
