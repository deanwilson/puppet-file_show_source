Puppet::Type.type(:file).newproperty(:show_source) do
  desc "Add extended attributes to files showing where in puppet the resource is defined

    file { '/tmp/extattr':
      ensure      => 'present',
      content     => 'test content',
      show_source => true,
    }

    and to see which puppet resource creates the file run 

    $ getfattr -d /tmp/extattr
    ...
    user.puppet.file='/etc/puppet/modules/external_parameter/show_source/test.pp'
    user.puppet.line='5'
    user.puppet.path='/Stage[main]//File[/tmp/show_source]'
    user.puppet.resource='File[/tmp/show_source]'

  "

  def puppet_attribute_names
    puppet_attributes.keys
  end

  def puppet_attributes
    attrs = {
      'user.puppet.file'     => resource.file || "from_apply",
      'user.puppet.line'     => resource.line.to_s,
      'user.puppet.resource' => resource.to_s,
      'user.puppet.path'     => resource.path,
    }

    attrs
  end

  def retrieve
    attrs = {}

    puppet_attributes.keys.each do |name|
      attrs[name] = `/usr/bin/getfattr --only-values -n #{name} #{resource[:path]} 2> /dev/null`.chomp
    end

    attrs == puppet_attributes
  end

  def set(value)
  end

  def flush
    puppet_attributes.each do |attr_name,attr_value|
      if should
        `/usr/bin/setfattr -n #{attr_name} -v #{attr_value} #{resource[:path]}`
      else
        `/usr/bin/setfattr --remove=#{attr_name}  #{resource[:path]}`
      end
    end
  end

end
