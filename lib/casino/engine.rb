module CASino
  class Engine < Rails::Engine
    isolate_namespace CASino

    def self.autoload_implementations(app)
      CASinoCore.config.implementors.each do |name, klass|
        next if klass

        CASinoCore.config.implementors[name] ||= begin
          "CASino::#{name.to_s.classify}".constantize
        # We have to rescue here to handle the interstitial state of the gem
        # being installed and but not the migrations.
        rescue NameError
          nil
        end
      end
    end

    rake_tasks { require 'casino_core/tasks' }

    initializer 'casino.autoload_implementations', &method(:autoload_implementations)

    initializer 'casino.setup_casino_core' do
      CASinoCore.setup
    end
  end
end
