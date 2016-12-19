service 'awslogs' do
  supports [:start, :stop, :status, :restart]
  action :nothing
end

[
  "#{node['cwlogs']['base_dir']}/etc/config",
  "#{node['cwlogs']['base_dir']}/logs",
  "#{node['cwlogs']['base_dir']}/bin"
].each do |path_to_create|
  directory path_to_create do
    recursive true
  end
end

template "#{node['cwlogs']['base_dir']}/etc/aws.conf" do
  source 'awscli.conf.erb'
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

setup_script = "#{node['cwlogs']['base_dir']}/bin/awslogs-agent-setup.py"
remote_file setup_script do
  source node['cwlogs']['installer_file']
  mode 0o755
  not_if { ::File.exist?(setup_script) }
end

template "/tmp/cwlogs-install.conf" do
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

execute 'Install CloudWatch Logs Agent' do
  command "#{setup_script} -n -r #{node['cwlogs']['region']} -c /tmp/cwlogs-install.conf"
  live_stream true
  timeout 600
  not_if { ::File.exist?("#{node['cwlogs']['base_dir']}/bin/aws") }
end
