SELinux Policy Cookbook
======================
This cookbbok can be used to manage SELinux policies and components (rather than just enable / disable enforcing).  
I made it because I needed some SELinux settings done, and the `execute`s started to look annoying.

Requirements
------------
Needs an SELinux policy active (so its values can be managed).  
Also requires SELinux's management tools, namely `semanage`, `setsebool` and `getsebool`.
Tools are installed by the `selinux_policy::install` recipe (for RHEL/Debian and the like).

Attributes
----------
None, at the moment.

Usage
-----

This cookbook's functionality is exposed via resources, so it should be called from a wrapper cookbook.
Remember to add `depends 'selinux_policy'` to your `metadata.rb`.

### boolean
Represents an SELinux [boolean](http://wiki.gentoo.org/wiki/SELinux/Tutorials/Using_SELinux_booleans).
You can either `set` it, meaning it will be changed without persistence (it will revert to default in the next reboot), or `setpersist` it (default action), so it'll keep it value after rebooting.  
Using `setpersist` requires an active policy (so that the new value can be saved somewhere).

Attributes:

* `name`: boolean's name. Defaults to resource name.
* `value`: Its new value (`true`/`false`).
* `force`: Use `setsebool` even if the current value agrees with the requested one.

Example usage:

```ruby
selinux_policy_boolean 'httpd_can_network_connect' do
    value true
    # Make sure nginx is started if this value was modified
    notifies :start,'service[nginx]', :immediate
end
```

**Note**: Due to ruby interperting `0` as `true`, using `value 0` is unwise.

### port
Allows assigning a network port to a certain SELinux context.  
As explained [here](http://wiki.centos.org/HowTos/SELinux#head-ad837f60830442ae77a81aedd10c20305a811388), it can be useful for running Apache on a non-standard port.

Actions:

* `addormodify` (default): Assigns the port to the right context, whether it's already listed another context or not at all.
* `add`: Assigns the port to the right context it's if not listed (only uses `-a`).
* `modify`: Changes the port's context if it's already listed (only uses `-m`).
* `delete`: Removes the port's context if it's listed (uses `-d`).

Attributes:

* `port`: The port in question, defaults to resource name.
* `protocol`: `tcp`/`udp`.
* `secontext`: The SELinux context to assign the port to. Uneeded when using `delete`.

Example usage:

```ruby
# Allow nginx to bind to port 5678, by giving it the http_port_t context
selinux_policy_port '5678' do
    protocol 'tcp'
    secontext 'http_port_t'
end
```

### module
Manages SEModules

Actions:

* `deploy` (default): Compiles a module from it's `te` file and deploys it. Deploys only when one of the following is true:
  * The module isn't currently present
  * `force` is enabled
  * The policy file has changed
* `remove`: Removes a module 

Example usage:

```ruby
# Allow openvpn to write/delete in '/etc/openvpn'
selinux_policy_module 'openvpn-googleauthenticator' do
  content '
module dy-openvpn-googleauthenticator 1.0;

require {
    type openvpn_t;
    type openvpn_etc_t;
    class file { write unlink };
}


#============= openvpn_t ==============
allow openvpn_t openvpn_etc_t:file { write unlink };
'
  action :deploy
end
```

### permissive
Allows some types to misbehave without stopping them.  
Not as good as specific policies, but better than disabling SELinux entirely.

Actions:

* `add`: Adds a permissive, unless it's already added
* `delete`: Deletes a permissive if it's listed

Example usage:

```ruby
# Disable enforcement on Nginx
# As described on http://nginx.com/blog/nginx-se-linux-changes-upgrading-rhel-6-6/

selinux_policy_permissive 'nginx' do
  notifies :restart, 'service[nginx]'
end
```

Contributing
------------
The generic method seems fine to me:

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Licensed [GPL v2](http://choosealicense.com/licenses/gpl-2.0/)  
Author: Nitzan Raz ([backslasher](http://backslasher.net))  

I'll be happy to accept contributions or to hear from you!
