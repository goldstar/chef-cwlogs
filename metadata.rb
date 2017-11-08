name             'cwlogs'
maintainer       'Mike Schuette'
maintainer_email 'mike.schuette@gmail.com'
license          'FreeBSD'
description      'Installs and configures AWS CloudWatch Logs'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.8'
source_url       'https://github.com/MikeSchuette/chef-cwlogs'
issues_url       'https://github.com/MikeSchuette/chef-cwlogs/issues'

%w(ubuntu debian centos redhat fedora).each do |os|
  supports os
end

depends 'cron' # Ubuntu 12.04 doesn't support /etc/cron.d
