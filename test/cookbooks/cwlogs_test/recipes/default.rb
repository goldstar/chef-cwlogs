#
# Cookbook Name:: cwlogs_test
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'cwlogs'

cwlogs_log_file "/var/log/awslogs.log" do 
  log_group_name 'goldstar-awslogs-group'
  datetime_format '%Y-%m-%d %H:%M:%S'
  action :create
end
