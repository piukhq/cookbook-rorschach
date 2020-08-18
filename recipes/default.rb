apt_repository 'nginx' do
  uri 'ppa:nginx/stable'
  components ['main']
  key '00A6F0A3C300EE8C'
  keyserver 'keyserver.ubuntu.com'
  action :add
end

apt_repository 'certbot' do
  uri 'ppa:certbot/certbot'
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
    port: node['rorschach']['port'],
    proxy_read_timeout: node['rorschach']['nginx']['proxy_read_timeout'],
    proxy_send_timeout: node['rorschach']['nginx']['proxy_send_timeout'],
    client_max_body_size: node['rorschach']['nginx']['client_max_body_size']
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
