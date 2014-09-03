service "php-fpm" do
  service_name('php5-fpm') if platform_family?('debian')
  supports :status => true, :restart => true
  action :nothing
  provider(Chef::Provider::Service::Upstart)if (platform?('ubuntu') && node['platform_version'].to_f >= 14.04)
end
