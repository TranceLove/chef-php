# encoding: utf-8
#
# Author:: Panagiotis Papadomitsos (pj@ezgr.net)
# Author:: TranceLove (airwave209gt@gmail.com)
#
# Cookbook Name:: chefphp
# Recipe:: module_redis-igbinary
#
# Copyright:: 2013, Panagiotis Papadomitsos
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

tmp = Chef::Config['file_cache_path'] || '/tmp'
ver = node['php']['phpredis_igbinary']['version'] || 'master'
lib = value_for_platform_family(
  [ 'rhel', 'fedora' ] => '/var/lib/php',
  'debian' => '/var/lib/php5'
)

if platform_family?('rhel')
  %w{ httpd-devel pcre pcre-devel }.each { |pkg| package pkg }
end

if (Chef::Config[:solo] && !File.exists?("#{lib}/.redis_igbinary-#{ver}-installed"))

  git "#{tmp}/php-redis-igbinary-#{ver}" do
    repository 'https://github.com/nicolasff/phpredis.git'
    reference "#{ver}"
    action :checkout
  end

  execute 'php-redis-igbinary-phpize' do
    command 'phpize'
    cwd "#{tmp}/php-redis-igbinary-#{ver}"
    creates "#{tmp}/php-redis-igbinary-#{ver}/configure"
    action :run
  end

  execute 'php-redis-igbinary-configure' do
    command './configure --enable-redis-igbinary'
    cwd "#{tmp}/php-redis-igbinary-#{ver}"
    creates "#{tmp}/php-redis-igbinary-#{ver}/config.h"
    action :run
  end

  execute 'php-redis-igbinary-build' do
    command "make -j#{node['cpu']['total']}"
    cwd "#{tmp}/php-redis-igbinary-#{ver}"
    creates "#{tmp}/php-redis-igbinary-#{ver}/modules/redis.so"
    action :run
    notifies :run, 'execute[php-redis-igbinary-install]', :immediately
  end

  execute 'php-redis-igbinary-install' do
    command 'make install'
    cwd "#{tmp}/php-redis-igbinary-#{ver}"
    action :nothing
  end

  if Chef::Config[:solo]
    file "#{lib}/.redis_igbinary-#{ver}-installed" do
      owner 'root'
      group 'root'
      action :create_if_missing
    end
  else
    node.set['php']['phpredis_igbinary']['version_installed'] = ver
  end
end

template "#{node['php']['ext_conf_dir']}/redis.ini" do
  only_if { platform?('ubuntu') && node['platform_version'].to_f >= 12.04 && ::File.exists?('/usr/sbin/php5enmod') }
  source 'extension.ini.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables({
    :name => 'redis',
    :directives => {}
  })
end

execute '/usr/sbin/php5enmod redis' do
  only_if { platform?('ubuntu') && node['platform_version'].to_f >= 12.04 && ::File.exists?('/usr/sbin/php5enmod') }

  if node['recipes'].include?('chefphp::fpm')
    notifies :restart, "service[php-fpm]"
  end
end
