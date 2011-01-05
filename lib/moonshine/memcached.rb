module Moonshine
  module Memcached
    # Define options for this plugin via the <tt>configure</tt> method
    # in your application manifest:
    #
    #   configure(:memcached => {:foo => true})
    #
    # Then include the plugin and call the recipe(s) you need:
    #
    #  recipe :memcached

    def memcached(options = {})
      options[:enable_on_boot] = true if options[:enable_on_boot].nil?

      exec 'apt-get install -q -y --force-yes memcached',
        :before => service('memcached'),
        :alias => 'memcached package',
        :unless => 'dpkg -l | grep memcached'

      service 'memcached', :ensure => :running, :enable => options[:enable_on_boot], :require => exec('memcached package')

      file '/etc/default/memcached',
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'default.erb'), binding),
        :mode => '644',
        :require => exec('memcached package'),
        :notify => service('memcached')

      file '/etc/memcached.conf',
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'memcached.conf.erb'), binding),
        :mode => '644',
        :require => exec('memcached package'),
        :notify => service('memcached')

      # install client gem if specified. otherwise, use version bundled with rails.
      if options[:client]
        gem 'memcache-client', :require => exec('memcached package'), :version => options[:client]
      end
    end
  end
end
