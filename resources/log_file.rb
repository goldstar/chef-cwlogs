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

  template "#{node['cwlogs']['base_dir']}/etc/config/#{stream_name}.conf" do
    source 'log_file.conf.erb'
    cookbook 'cwlogs'
    variables(
      log_group_name: new_resource.log_group_name || new_resource.name,
      log_stream_name: new_resource.log_stream_name,
      datetime_format: new_resource.datetime_format,
      time_zone: new_resource.time_zone,
      file: new_resource.file,
      file_fingerprint_lines: new_resource.file_fingerprint_lines,
      multi_line_start_pattern: new_resource.multi_line_start_pattern,
      initial_position: new_resource.initial_position,
      encoding: new_resource.encoding,
      buffer_duration: new_resource.buffer_duration,
      batch_count: new_resource.batch_count,
      batch_size: new_resource.batch_size
    )
    owner owner
    group group
    mode owner
    notifies :restart, 'service[awslogs]'
  end
end

action :delete do
  stream_name = sanitize(new_resource.name)
  template "#{node['cwlogs']['base_dir']}/etc/config/#{stream_name}.conf" do
    action :delete
  end
end
