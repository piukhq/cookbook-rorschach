# rorschach

Rorschach installs NGINX and configures it to act as a reverse proxy for any deployed Application. Certbot is also installed to manage TLS certificates on an ongoing basis. Nginx is configured against Mozillas [recommendations](https://ssl-config.mozilla.org/)

The following should be overriden as part of a node spec as per Chef [documentation](https://docs.chef.io/attributes/):

```ruby
node['rorschach']['domain']
node['rorschach']['port']
```

# TODO

* More Attributes/Customisations to `templates/default/nginx.conf.erb`
