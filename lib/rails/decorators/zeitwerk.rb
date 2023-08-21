# This used to work with older versions of zeitwerk supporting the deprecated preload interface. 
# This mechanism decorates the loader (old method named "do_preload"). The new method is named setup.
# This woud have skipeed the block in the mutex for thread safety so we disabled it by commenting the prepend.
# Instead we relied on the callback in the engine initializer to load all the .decorator files, wich seemed to work.
module Zeitwerk
  class Loader
    module RailsDecorators
      def setup
        super
        load_decorators
      end

      def load_decorators
        decorator_ext = /\.#{Rails::Decorators.extension}$/
        queue = []
        actual_root_dirs.each do |root_dir, namespace|
          queue << [namespace, root_dir] unless eager_load_exclusions.member?(root_dir)
        end

        while dir_to_load = queue.shift
          namespace, dir = dir_to_load

          ls(dir) do |basename, abspath|
            if abspath =~ decorator_ext
              load(abspath)
            elsif dir?(abspath) && !root_dirs.key?(abspath)
              if collapse_dirs.member?(abspath)
                queue << [namespace, abspath]
              else
                cname = inflector.camelize(basename, abspath)
                queue << [namespace.const_get(cname, false), abspath]
              end
            end
          end
        end
      end
    end

    #prepend RailsDecorators
  end
end
