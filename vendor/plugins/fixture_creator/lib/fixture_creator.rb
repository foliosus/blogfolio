# A module intended for ActiveRecord::Base that dumps fixtures from current database data using AR::Base.find() syntax.  This allows commands like MyModel.create_fixtures(:all, :conditions => "first_name like '%foo%', :order => 'last_name ASC'")
module FixtureCreator
 def self.included(target)
   target.extend(ClassMethods)
 end

 module ClassMethods
   # Create a fixtures file with found data: passes the incoming args through to the find method, and writes the fixtures to the appropriate .yml file in RAILS_ROOT/test/fixtures.  If given a block, +create_fixtures+ uses the output of the block as the fixture name. For example,
   #
   #  Mymodel.create_fixtures(:all, :conditions => "name LIKE 'A%'"){|mymodel| mymodel.name.downcase}
   #
   # This will give fixtures named 'adam', 'aaron', 'anne', etc.
   #
   # Without a block, all fixtures are named after the fixture file with a counter appended (mymodels_001, mymodels_002, etc.).
   def create_fixtures(*args, &block)
     name = self.table_name.downcase.gsub(/.*\./,'')
     i = '000'
     File.open("#{RAILS_ROOT}/test/fixtures/#{name}.yml", 'w') do |file|
       file.write self.find(*args).inject({}){|hash, record|
         if block_given?
           the_name = yield(record).to_s
         else
           the_name = "#{name}_#{i.succ!}"
         end
         hash[the_name] = record.attributes
         hash
       }.to_yaml
     end
   end
 end
end
