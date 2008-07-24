require 'test/unit'

task :selenium_test do
  begin
    # NOTE: must require selenium here instead of top of file, or else it will always set RAILS_ENV to test
    require File.dirname(__FILE__) + '/../../test/selenium/selenium_helper'
    rails_server_process = IO.popen("ruby #{File.dirname(__FILE__) }/../../script/server --port=3001")
    selenium_server = Selenium::SeleniumServer.new
    unless selenium_server.running?
      selenium_server_process = IO.popen("selenium")
    end

    Rake::Task[:selenium_suite].invoke
    
    SeleniumBrowser.stop_browser
  rescue Exception => e
    puts e
    raise e
  ensure
    puts "Killing rails server process at pid #{rails_server_process.pid}"
    Process.kill(9,rails_server_process.pid)
    puts "Killing selenium server"
    selenium_server.stop
  end
end

Rake::TestTask.new do |t|
  t.name = "selenium_suite"
  t.pattern = 'test/selenium/**/*_test.rb'
  t.verbose = true
end
Rake::Task['selenium_suite'].comment = "Run selenium tests (requires rails and selenium servers to be running)"
