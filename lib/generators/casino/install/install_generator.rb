require 'casino_core'

module Casino # CASino would lead to c_a_sino...
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)

    class_option :migration,
        desc:'Skip generating migrations',
        type: :boolean,
        default: true

    class_option :check_old_install,
        desc:'Check for pre-existing installation of CASino v1.3 or lower',
        type: :boolean,
        default: true


    # Implement the required interface for Rails::Generators::Migration.
    def self.next_migration_number(dirname)
      next_migration_number = current_migration_number(dirname) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end

    def check_for_old_installation
      return unless options['check_old_install']

      if old_casino_install?
        say "It looks like you already have an older version of CASino installed.\n", :yellow
        if yes?('Would you like to migrate your installation now?')
          generate 'casino:migrate', options['force'] ? '--force' : nil
        else
          say "OK, then. But the current version is not compatible with the " \
              "older version, so you'll have to handle the upgrade manually."
        end
        exit
      end
    end

    def create_implementations
      implement 'login_ticket'
      implement 'proxy_granting_ticket'
      implement 'proxy_ticket'
      implement 'service_rule'
      implement 'service_ticket'
      implement 'ticket_granting_ticket'
      implement 'two_factor_authenticator'
      implement 'user'
    end

    def copy_initializer_file
      copy_file 'casino_core.rb', 'config/initializers/casino_core.rb'
    end

    def copy_config_files
      copy_file 'cas.yml', 'config/cas.yml'
      copy_file 'casino_and_overrides.scss', 'app/assets/stylesheets/casino_and_overrides.scss'
    end

    def insert_assets_loader
      insert_into_file 'app/assets/javascripts/application.js', :after => %r{//= require +['"]?jquery_ujs['"]?} do
        "\n//= require casino"
      end
    end

    def insert_engine_routes
      route "mount CASino::Engine => '/', :as => 'casino'"
    end

    def remove_index_html
      remove_file 'public/index.html'
    end

    def show_readme
      readme 'README'
    end

  private

    def implement(name)
      if model_exists? name
        upgrade_implementation name
      else
        install_implementation name
      end
    end

    def install_implementation(name)
      copy_file "implementations/#{name}/model.rb", model_path(name)
      if options['migration']
        migration_template "implementations/#{name}/migration.rb", "db/migrate/create_casino_#{name.pluralize}.rb"
      end
    end

    def upgrade_implementation(name)
      # TODO: Would recommend implementing an upgrade path by following along
      # the lines of this gem:
      #
      #   https://github.com/collectiveidea/audited/blob/7134f76938e534f8ef627066425e8a8fc5c6c235/lib/generators/audited/upgrade_generator.rb#L31
      #
      # But its hard to say without knowing what types of upgrades might be
      # required
      raise NotImplementedError, "No upgrade path currently exists for " \
                                  "#{name.classify}.\n\n" \
                                  "You can either manually " \
                                  "copy over any changes or re-run this generator " \
                                  "with the --force flag.\n\n"
    end

    def old_casino_install?
      if table_exists? 'login_tickets'
        if Dir[File.join(destination_root,'app','models','casino')].empty?
          true
        else
          say "Although CASino appears to already be installed, your database " \
              "has not been migrated yet.\n\n" \
              "Before proceeding, be sure to run:\n\n" \
              "    bundle exec rake db:migrate\n\n"
          exit
        end
      end
    end

    def table_exists?(name)
      ActiveRecord::Base.connection.table_exists? name
    end

    def model_exists?(model)
      return false if options['force'] == true

      File.exists?(File.join(destination_root, model_path(model)))
    end

    def model_path(model)
      File.join('app', 'models', 'casino', "#{model}.rb")
    end
  end
end
