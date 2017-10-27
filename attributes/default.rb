default['cwlogs']['base_dir'] = '/var/awslogs'
default['cwlogs']['installer_file'] = 'https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py'
default['cwlogs']['use_gzip_http_content_encoding'] = 'true'

# Optional attributes
#
# default['cwlogs']['region'] = "us-west-1"
# default['cwlogs']['http_proxy'] = "http://proxy:3128"
# default['cwlogs']['https_proxy'] = "http://poxy:3128"
# default['cwlogs']['aws_access_key_id'] = AWS_ACCESS_KEY_ID
# default['cwlogs']['aws_secret_access_key'] = aws_secret_access_key
