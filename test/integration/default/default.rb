%w(
  http://ppa.launchpad.net/nginx/stable/ubuntu
  http://ppa.launchpad.net/certbot/certbot/ubuntu
  https://download.docker.com/linux/ubuntu
).each do |i|
  describe apt(i) do
    it { should exist }
    it { should be_enabled }
  end
end

%w(
  nginx
  certbot
  python3-certbot-dns-cloudflare
).each do |i|
  describe package(i) do
    it { should be_installed }
  end
end

describe file('/etc/nginx/nginx.conf') do
  its('uid') { should eq 0 }
  its('gid') { should eq 0 }
  its('mode') { should cmp '0644' }
end

describe file('/etc/nginx/sites-enabled/default') do
  it { should_not exist }
end

describe file('/etc/letsencrypt/cloudflare.ini') do
  its('uid') { should eq 0 }
  its('gid') { should eq 0 }
  its('mode') { should cmp '0600' }
end

describe systemd_service('nginx') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
