directory "#{node['cwlogs']['base_dir']}/bin" do
  recursive true
  action :create
end

setup_script = "#{node['cwlogs']['base_dir']}/bin/awslogs-agent-setup.py"
remote_file setup_script do
  source node['cwlogs']['installer_file']
  mode 0o755
  not_if { ::File.exist?(setup_script) }
end

template '/tmp/cwlogs-install.conf' do
  source 'awslogs.conf.erb'
  owner 'root'
  group 'root'
  mode 0o644
  if ::File.exist?("#{node['cwlogs']['base_dir']}/bin/aws")
    action :delete
  else
    action :create
  end
end

case node['platform']
when 'ubuntu'
  package 'cron' # /etc/cron.d is required.
  if node['platform_version'].to_i == 12
    node.default['cron']['emulate_cron.d'] = true
    include_recipe 'cron'
  elsif node['platform_version'].to_i == 16
    %w(python python-pip).each do |package_name|
      package package_name do
        action :install
        not_if { ::File.exist?('/usr/bin/python') }
      end
    end
    # Set up the systemd file.
    template '/etc/systemd/system/awslogs.service' do
      source 'awslogs.service.erb'
      action :create
    end
  end
end

execute 'Install CloudWatch Logs Agent' do
  command "#{setup_script} -n -r #{node['cwlogs']['region']} -c /tmp/cwlogs-install.conf"
  live_stream true
  timeout 600
  not_if { ::File.exist?("#{node['cwlogs']['base_dir']}/bin/aws") }
end

template "#{node['cwlogs']['base_dir']}/etc/aws.conf" do
  source 'aws.conf.erb'
  owner 'root'
  group 'root'
  mode 0o644

  notifies :restart, 'service[awslogs]'
end

template "#{node['cwlogs']['base_dir']}/etc/awslogs.conf" do
  source 'awslogs.conf.erb'
  owner 'root'
  group 'root'
  mode 0o644

  notifies :restart, 'service[awslogs]'
end

template "#{node['cwlogs']['base_dir']}/etc/proxy.conf" do
  source 'proxy.conf.erb'
  owner 'root'
  group 'root'
  mode 0o644

  notifies :restart, 'service[awslogs]'
end

file '/etc/init.d/awslogs' do
  action :delete
  only_if { node['platform_version'].to_i == 16 }
end

service 'awslogs' do
  supports [:start, :stop, :status, :restart]
  case node['platform']
  when 'ubuntu'
    if node['platform_version'].to_i == 16
      provider Chef::Provider::Service::Systemd
      action [:enable, :start]
    else
      provider Chef::Provider::Service::Init
      action :nothing
    end
  end
end
