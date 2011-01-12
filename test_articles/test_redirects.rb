require 'yaml'
require File.dirname(__FILE__) + '/redirect_checker.rb'


redirect_checker = RedirectChecker.new
urls = YAML::load_file(File.open('urls.yaml'))
urls.each do |pair|
  redirect_checker.add_redirect pair[:old], File.join('http://www.ucsf.edu', pair[:new])
end

redirect_checker.run
