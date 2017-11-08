include_recipe 'cron' # /etc/cron.d is required

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
  %w(python python-pip).each do |package_name|
    package package_name do
      action :install
      not_if { ::File.exist?('/usr/bin/python') }
    end
  end

  # awslogs-agent-setup.py writes this file incorrectly for older Ubuntus
  cookbook_file '/etc/logrotate.d/awslogs' do
    source 'logrotate_awslogs'
    only_if { node['platform_version'].to_i <= 12 }
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
  variables(
    aws_access_key_id: lazy { node['cwlogs']['aws_access_key_id'] },
    aws_secret_access_key: lazy { node['cwlogs']['aws_secret_access_key'] }
  )

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

service 'awslogs' do
  action [:enable, :start]
end
