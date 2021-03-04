describe package('nginx') do
  it { should be_installed }
end

describe file('/etc/nginx/nginx.conf') do
  its('uid') { should eq 0 }
  its('gid') { should eq 0 }
  its('mode') { should cmp '0644' }
end

describe file('/etc/nginx/sites-enabled/default') do
  it { should_not exist }
end

describe file('/etc/letsencrypt/azure.json') do
  its('uid') { should eq 0 }
  its('gid') { should eq 0 }
  its('mode') { should cmp '0600' }
end

describe systemd_service('nginx') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
