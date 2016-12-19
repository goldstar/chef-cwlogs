require 'spec_helper'

describe 'cwlogs::default' do
  describe service('awslogs') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/var/awslogs/etc/awscli.conf') do
    it { should exist }
    it { should be_mode 644 }
  end

  describe file('/var/awslogs/etc/config/var_log_awslogs_log.conf') do
    it { should exist }
  end
end
