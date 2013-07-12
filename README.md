# Show Source attributes on Puppet file resources #

Have you ever wanted to see which part of your puppet codebase manages a given file?

When you set the show_source propertity on a file resource (or globally
- but that's a little slow) puppet will add extended attributs to show
where in your modules and manifests the resource is contained. This
allows easier discovery of how you manage which files in cross team
environments and also allows further tooling to be based on its output.

    file { '/tmp/extattr':
      ensure      => 'present',
      content     => 'test content',
      show_source => true,
    } 

    and to see which puppet resource creates the file run 

    $ getfattr -d /tmp/extattr
    ...
    user.puppet.file='/home/myhero_richardc/src/evil_lab/monkey_parameter/show_source/test.pp'
    user.puppet.line='5'
    user.puppet.path='/Stage[main]//File[/tmp/show_source]'
    user.puppet.resource='File[/tmp/show_source]'


## Implementation

This extension of an existing type and provider is deployed
within a module and uses rubys open nature to add additional properties
to a type with `Puppet::Type.type(:file).newproperty(:extattr)`. Full
implementation details and technical explanations will follow in a
couple of blog posts that we'll link to from here.

Much of this code is the result of an evening worth of puppet internals
exploration and the brilliance of @richardc - some of the approaches
used in these sample extension modules may be incorrect assumptions or
change heavily as we go further back in to the code base but these
extensions hopefully prove that extending the core types is both
possible and desirable.

## Deployment

Install this code as you would any other module and then, if you have a puppet master, restart it.

## Notes

 * This property calls out to the getfattr and setfattr commands
   and assumes that they are installed and in the path
 * The file system contain the target of the file resource requires support for extended attributes
 * I've only tested this on linux
 * we currently don't show which attributes have changed
