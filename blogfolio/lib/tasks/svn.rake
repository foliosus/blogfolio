desc "Configure Subversion for Rails"
task :setup_svn do
  puts "Removing /log"
  system "svn remove log/*"
  system 'svn propset svn:ignore "*.log" log/'

  puts "Ignoring /db"
  system 'svn propset svn:ignore "*.db" db/'

  puts "Renaming database.yml database.example"
  system "svn move config/database.yml config/database.example"
  system 'svn propset svn:ignore "database.yml" config/'

  puts "Ignoring /tmp"
  system 'svn propset svn:ignore "*" tmp/'

  puts "Ignoring /doc"
  system 'svn propset svn:ignore "*" doc/'
  
  puts "Committing all changes"
  system "svn commit -m 'Applied svn.rake task to properly configure the app for subversion'"
end