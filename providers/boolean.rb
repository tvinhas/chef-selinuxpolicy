# Support whyrun
def whyrun_supported?
  true
end

use_inline_resources

# Set for now, without persisting
action :set do
  set_sebool(false)
end

# Set and persist
action :setpersist do
  set_sebool(true)
end

def set_sebool(persist=false)
  persist_string= persist ? '-P ':''
  new_value= new_resource.state ? 'on' : 'off'
  e = execute "selinux-setbool-#{new_resource.name}-#{new_value}" do
    command "/usr/sbin/setsebool #{persist_string} #{new_resource.name} #{new_value}"
    not_if "/usr/sbin/getsebool #{new_resource.name} | grep '#{new_value}$' >/dev/null" if !new_resource.force
  end
end
