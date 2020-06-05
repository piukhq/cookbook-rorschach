delete_lines 'remove cdrom references' do # Fix InSpec Parsing error
  path '/etc/apt/sources.list'
  pattern /cdrom/
end

apt_repository 'nginx' do
  uri 'http://ppa.launchpad.net/nginx/stable/ubuntu'
  components ['main']
  key '00A6F0A3C300EE8C'
  keyserver 'keyserver.ubuntu.com'
  action :add
end

apt_repository 'certbot' do
  uri 'http://ppa.launchpad.net/certbot/certbot/ubuntu'
  components ['main']
  key '8C47BE8E75BCA694'
  keyserver 'keyserver.ubuntu.com'
  action :add
end

package %w(
  nginx
  certbot
  python3-certbot-dns-cloudflare
) do
  action :install
end

# For some reason nginx doesnt come enabled on 16.04 :/
service 'nginx' do
  action :enable
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  notifies :restart, 'service[nginx]'
  variables(
    domain: node['rorschach']['domain'],
    port: node['rorschach']['port']
  )
end

file '/etc/nginx/sites-enabled/default' do
  action :delete
  notifies :restart, 'service[nginx]'
end

cookbook_file '/etc/letsencrypt/cloudflare.ini' do
  source 'cloudflare.ini'
  owner 'root'
  group 'root'
  mode '0600'
  action :create
end

certbot_args = [
  '--dns-cloudflare',
  '--dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini',
  '--preferred-challenges dns-01',
  '--agree-tos',
  '--non-interactive',
  '-m onlineservices@bink.com',
  "-d #{node['rorschach']['domain']}",
]

if node.chef_environment == 'vagrant'
  certbot_args.push \
    '--test-cert'
end

execute 'certbot' do
  command "/usr/bin/certbot certonly #{certbot_args.join(' ')}"
  not_if { ::File.exist?("/etc/letsencrypt/live/#{node['rorschach']['domain']}/privkey.pem") }
  retries 10
end
