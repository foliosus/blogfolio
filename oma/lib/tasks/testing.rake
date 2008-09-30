# Run specific tests or test files
# 
# rake test:blog
# => Runs the full BlogTest unit test
# 
# rake test:blog:create
# => Runs the tests matching /create/ in the BlogTest unit test
# 
# rake test:blog_controller
# => Runs all tests in the BlogControllerTest functional test
# 
# rake test:blog_controller
# => Runs the tests matching /create/ in the BlogControllerTest functional test	
rule "" do |t|
  # test:file:method
  if /test:(.*)(:([^.]+))?$/.match(t.name)
    arguments = t.name.split(":")[1..-1]
    file_name = arguments.first
    test_name = arguments[1..-1].first
    
    if File.exist?("test/unit/#{file_name}_test.rb")
      run_file_name = "unit/#{file_name}_test.rb" 
    elsif File.exist?("test/functional/#{file_name}_test.rb")
      run_file_name = "functional/#{file_name}_test.rb" 
    elsif File.exist?("test/integration/#{file_name}_test.rb")
      run_file_name = "integration/#{file_name}_test.rb" 
    end
    
    execution_string = "ruby -Ilib:test test/#{run_file_name}"
    execution_string += " -n /#{test_name}/" if test_name
    
    sh execution_string
  end
end