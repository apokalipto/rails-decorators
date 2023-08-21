module Rails
  module Decorators
    class MissingZeitwerkError < StandardError; end

    class Engine < ::Rails::Engine
      isolate_namespace Rails::Decorators

      config.after_initialize do |app|
        #loader = Zeitwerk::Registry.loaders.first
        Zeitwerk::Registry.loaders.each do |loader|
          loader.on_setup do
            loader.send(:roots).each do |root|
            
              dir, namespace = root

              decorators = Dir.glob("#{dir}/**/*.#{Rails::Decorators.extension}")
              decorators.sort!
            
              decorators.each do |d| 
                load(d)
              end
            end
          end
        end
      end
    end
  end
end
