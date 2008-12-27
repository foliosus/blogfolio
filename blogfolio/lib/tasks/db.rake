namespace :db do
  BACKUP_DIR = "#{RAILS_ROOT}/db/backup"
  
  desc "Backup the database to a file. Uses RAILS_ENV (defaults to development)"
  task :backup => :environment do
    env = RAILS_ENV
    datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    file = "oma_#{datestamp}_#{env}_mysql.sql.bz2"
    h, d, u, p = load_database_yml(env)
    `mkdir -p #{BACKUP_DIR}`
    
    puts "Backing up #{env} database to #{BACKUP_DIR}/#{file}"
    cmd = "mysqldump #{d} -u#{u} -p#{p} -h#{h} | bzip2 > #{BACKUP_DIR}/#{file}"
    `#{cmd}`
  end
  
  desc "Restore the RAILS_ENV database from a backup file. e.g. backup=oma_2008-01-04_17-13-04_production_mysql.sql.bz2"
  task :restore => :environment do
    unless ENV.include?("backup")
      puts `ls -lc #{BACKUP_DIR}/*.sql.bz2`
      raise "Usage: RAILS_ENV=production rake db:restore backup=oma_2008-01-04_17-13-04_production_mysql.sql.bz2"    
    end
    file = "#{BACKUP_DIR}/#{ENV['backup']}"
    puts file
    raise "Backup file does not found" unless File.exists?(file)
    
    env = RAILS_ENV
    h, d, u, p = load_database_yml(env)
    
    puts "Restoring #{env} database from #{file}"
    
    Rake::Task["mysql:drop_db"].invoke
    Rake::Task["mysql:create_db"].invoke

    cmd = "bzcat #{file} | mysql #{d} -u#{u} -p#{p} -h#{h}"
    puts "\nUnzipping: #{cmd}"
    `#{cmd}`
  end
  
  task :drop_db => :environment do
    env = RAILS_ENV
    h, d, u, p = load_database_yml(env)
    cmd = "yes | mysqladmin drop #{d} -u#{u} -p#{p} -h#{h}"
    puts "\nDropping database: #{cmd}"
    `#{cmd}`
  end
 
  task :create_db => :environment do
    env = RAILS_ENV
    h, d, u, p = load_database_yml(env)
    cmd = "mysqladmin create #{d} -u#{u} -p#{p} -h#{h}"
    puts "\nCreating database: #{cmd}"
    `#{cmd}`
  end
end