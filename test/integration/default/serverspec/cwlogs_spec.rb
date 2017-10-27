require 'spec_helper'

describe 'cwlogs::default' do
  describe service('awslogs') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/var/awslogs/etc/aws.conf') do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
  end

  describe file('/var/awslogs/etc/awslogs.conf') do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
  end

  describe file('/var/awslogs/etc/config/var_log_awslogs_log.conf') do
    it { should exist }
    it { should be_file }
  end

  describe file('/var/awslogs/etc/proxy.conf') do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
  end

  %w(awslogs awslogs_log_rotate).each do |cron_file|
    describe file("/etc/cron.d/#{cron_file}") do
      it { should exist }
      it { should be_file }
    end
  end
end
