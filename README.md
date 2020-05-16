# rorschach

Rorschach installs NGINX and configures it to act as a reverse proxy for any deployed Application. Certbot is also installed to manage TLS certificates on an ongoing basis. Nginx is configured against Mozillas [recommendations](https://ssl-config.mozilla.org/)

Rorschach's attributes should be overriden as part of a role spec as per Chef [documentation](https://docs.chef.io/attributes/), for example:

```json
{
  "name": "kibana",
  "description": "",
  "json_class": "Chef::Role",
  "default_attributes": {
    "rorschach": {
      "domain": "kibana.uksouth.bink.sh",
      "port": 5601
    }
  },
  "override_attributes": {

  },
  "chef_type": "role",
  "run_list": [
    "recipe[fury]",
    "recipe[manhattan]",
    "recipe[rorschach]"
  ],
  "env_run_lists": {
                                                   
  }                                                
}                                                  
```

# TODO

* More Attributes/Customisations to `templates/default/nginx.conf.erb`
