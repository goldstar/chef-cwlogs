# `cwlogs`

A Chef recipe for installing and configure Amazone CloudWatch Logs Agent.

## Requirements

### Platforms

- Ubuntu 14.04 
- Ubuntu 16.04

### Chef

- Chef 12.0 or later

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['cwlogs']['region']</tt></td>
    <td>String</td>
    <td>_(Required)_ The AWS region where the CloudWatch Logs are stored</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['cwlogs']['aws_access_key_id']</tt></td>
    <td>String</td>
    <td>_(Optional)_ The AWS access key used to push logs to CloudWatch Logs</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['cwlogs']['aws_secret_access_key']</tt></td>
    <td>String</td>
    <td>_(Optional)_ The AWS access secret</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['cwlogs']['installer_file']</tt></td>
    <td>String</td>
    <td>_(Optional)_ The file to use for installing the AWS CloudWatch Logs Agent</td>
    <td><tt>https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py</tt></td>
  </tr>
  <tr>
    <td><tt>['cwlogs']['use_gzip_http_content_encoding']</tt></td>
    <td>String</td>
    <td>_(Optional)_ Whether to use gzip compression when sending logs to AWS</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### `cwlogs::default`

Add `cwlogs` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[cwlogs]"
  ]
}
```

This recipe installs the Amazon CloudWatch Logs Agent and exploses an LWRP for configuring CloudWatch Logs.

## Resources

### `cwlogs_log_file`

Used to configure CloudWatch Logs Agent to tail a log file. [See Amazon's documentation](http://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AgentReference.html) for a more thorough explanation of these configuration options.

### Actions

- `create` - Creates a configuration file for the given log file
- `delete` - Deletes a configuration file

### Properties:

- `log_group_name` - The CloudWatch Logs group name. Defaults to the resource's name if not provided.
- `log_stream_name` - The stream name. Defaults to `{hostname}`. Any string will work or the special variables `{ip_address}` or `{instance_id}`.
- `datetime_format` - The datetime format for the given log file.
- `time_zone` - Timezone of the log file. UTC is the default.
- `file` - The log file to tail. Defaults to resource's name.
- `file_fingerprint_lines` - Specifies the range of lines for identifying a file.
- `multi_line_start_pattern` - Specifies the pattern for identifying the start of a log message.
- `initial_position` - Specifies where to start to read data (`start_of_file` or `end_of_file`). Defaults to `start_of_file`.
- `encoding` - Specifies the encoding of the log file so that the file can be read correctly. Defaults to `utf_8`.
- `buffer_duration` - Specifies the time duration for the batching of log events in ms. Default is `5000`, which is the minimum value.
- `batch_count` - Specifies the max number of log events in a batch, up to `10000`. The default value is `1000`.
- `batch_size` - Specifies the max size of log events in a batch, in bytes, up to `1048576` bytes. The default value is `32768` bytes. 
- `owner` - Owner of the configuration file. Defaults to `root`.
- `group` - Group for the configuration file. Defaults to `root`.
- `mode` - The mode of the configuration file. Defaults to `0644`.

### Example:

```ruby
cwlogs_log_file "/var/log/auth.log" do
  log_group_name 'mysite-auth-logs'
  action :create
end
```
