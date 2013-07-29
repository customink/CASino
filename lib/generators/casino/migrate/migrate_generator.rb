module Casino # CASino would lead to c_a_sino...
  class MigrateGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)

    # Implement the required interface for Rails::Generators::Migration.
    def self.next_migration_number(dirname)
      next_migration_number = current_migration_number(dirname) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end

    def migrate
      migration_template "migrate_casino_tables.rb", "db/migrate/migrate_casino_tables.rb"
    end

    def install_casino
      args = %w{--skip-check-old-install --skip-migration}
      args << '--force' if options['force']
      generate 'casino:install', args.join(' ')
    end
  end
end