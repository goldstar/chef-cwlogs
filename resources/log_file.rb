resource_name :circleci_artifact

property :log_group_name, String
property :log_stream_name, String, default: '{instance_id}'
property :datetime_format, String
property :time_zone, String
property :stream_name, String, name_attribute: true
property :file, String, name_attribute: true
property :file_fingerprint_lines, [String, Integer]
property :multi_line_start_pattern, String
property :initial_position, String
property :encoding, String
property :buffer_duration, Integer
property :batch_count, Integer
property :batch_size, Integer
property :owner, [String, Integer], default: 'root'
property :group, [String, Integer], default: 'root'
property :mode, [String, Integer], default: '0644'

default_action :create if defined?(default_action)

action :create do
  template "#{node['cwlogs']['base_dir']}/etc/config/#{stream_name}.conf" do
    variables({
      :log_group_name => log_group_name,
      :log_stream_name => log_stream_name,
      :datetime_format => datetime_format,
      :time_zone => time_zone,
      :stream_name => stream_name,
      :file => file,
      :file_fingerprint_lines => file_fingerprint_lines,
      :multi_line_start_pattern => multi_line_start_pattern,
      :initial_position => initial_position,
      :encoding => encoding,
      :buffer_duration => buffer_duration,
      :batch_count => batch_count,
      :batch_size => batch_size
    })
    owner owner
    group group
    mode owner
    action :create
    notifies :restart, 'service[awslogs]'
  end
end

action :delete do
  template "#{node['cwlogs']['base_dir']}/etc/config/#{stream_name}.conf" do
    action :delete
  end
end
