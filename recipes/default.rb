apt_repository 'nginx' do
  uri 'ppa:nginx/stable'
  components ['main']
  key '00A6F0A3C300EE8C'
  keyserver 'keyserver.ubuntu.com'
  action :add
end

package 'certbot' do
  action :remove
  notifies :run, 'execute[apt_cleanup]', :immediately
end

execute 'apt_cleanup' do
  command 'apt-get -y autoremove'
  action :nothing
end

package %w(
  nginx
  python3-pip
) do
  action :install
end

execute 'pip3 install certbot-azure==0.1.0' do
  not_if 'pip3 freeze | grep certbot-azure==0.1.0'
end

execute 'pip3 install cryptography==3.2' do
  not_if 'pip3 freeze | grep cryptography==3.2'
end

service 'nginx' do
  action [:enable, :start]
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

directory '/etc/letsencrypt' do
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file '/etc/letsencrypt/azure.json' do
  source 'azure.json'
  owner 'root'
  group 'root'
  mode '0600'
  action :create
end

certbot_args = [
  '-a dns-azure',
  '--dns-azure-credentials /etc/letsencrypt/azure.json',
  '--dns-azure-resource-group uksouth-dns',
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
  command "/usr/local/bin/certbot certonly #{certbot_args.join(' ')}"
  not_if { ::File.exist?("/etc/letsencrypt/live/#{node['rorschach']['domain']}/privkey.pem") }
  retries 10
end
