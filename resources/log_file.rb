resource_name :cwlogs_log_file

property :log_group_name, String
property :log_stream_name, String, default: '{hostname}'
property :datetime_format, String, default: '%b %d %H:%M:%S'
property :time_zone, String
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


def sanitize(log_group_name)
  clean_name = log_group_name.gsub(/^[^0-9A-Z]/i, '')
  clean_name = clean_name.gsub(/[^0-9A-Z]$/i, '')
  clean_name.gsub(/[^0-9A-Z]/i, '_')
end

action :create do
  stream_name = sanitize(new_resource.name)

  # Defaults log_group_name to the name attribute.
  if log_group_name.length
    log_group_name = new_resource.name
  end

  template "#{node['cwlogs']['base_dir']}/etc/config/#{stream_name}.conf" do
    source 'log_file.conf.erb'
    cookbook 'cwlogs'
    variables({
      :log_group_name => log_group_name,
      :log_stream_name => log_stream_name,
      :datetime_format => datetime_format,
      :time_zone => time_zone,
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
  stream_name = sanitize(new_resource.name)
  template "#{node['cwlogs']['base_dir']}/etc/config/#{stream_name}.conf" do
    action :delete
  end
end
