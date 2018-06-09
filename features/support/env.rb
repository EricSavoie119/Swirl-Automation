$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../../', 'lib'))

require 'rubygems'
require 'require_all'
require 'fire_poll'
require 'page-object'
require 'page-object/elements'
require 'page-object/page_factory'
require 'selenium-webdriver'
require 'nokogiri'
require 'pry'
require 'date'

require_all 'lib'

ENV['FRAMEWORK'] = File.expand_path('.')

BROWSER_TYPE = ENV['BROWSER'] || 'chrome'
@platform = ENV['PLATFORM']
@os_version = ENV['OS_VERSION']
@device_name = ENV['DEVICE_NAME']
@automation_name = ENV['AUTOMATION_NAME']

# File.open("#{File.expand_path('.')}/report.txt", "a") do |handle|
#   d = DateTime.now
#   handle.puts d.strftime("%d/%m/%Y %H:%M") + "\n"
# end

# if @platform == 'iOS'
#   ios_device = ARGV.find { |arg| arg.downcase.include? "ios_device" }
#
#   ios_device = ios_device.include?('=')? ios_device.split('=')[1] : ios_device
#   Automato::IOSEnvironment.get_udid(ios_device)
#   @device_name = ENV['DEVICE_NAME'] = ios_device
#   @udid = ENV['iOSUDID']
#   @app_path = ".//#{ENV['APP_PATH']}"
# end

puts "Setting up automation environment..."

#Add "device name" inside of the android command line
# if @platform == 'android'
#   android_device = ARGV.find {|arg| arg.downcase.include? "android_device"}
#   android_device = android_device.include?('=')? android_device.split('=')[1] : android_device
#   Automato::AndroidEnvironment.get_proper_app(android_device)
#   if android_device
#     Automato::Android.android_setup(android_device)
#   else
#     Automato::Android.android_setup
#   end
#   @app_path = ENV['APP_PATH']
#   @device_name, @os_version = Automato::Android.android_device_info
# end

# if @platform == 'iOS'
#   Automato::IPhone.iphone_setup(@udid)
# end

if @platform == 'iOS-real'
  @device_name = 'Waltz-Admin’s iPhone'
  @app_path = ".//#{ENV['APP_PATH']}"
end

# if @platform == 'android-real'
#   @app_path = ".//#{ENV['APP_PATH']}"
# end
#
# # If platform is android or ios create driver instance for mobile browser
case @platform
#   when 'android', 'iOS',
#     @no_reset = true
#     if @browser_type == 'native'
#       @browser_type = 'Browser'
#     end
#
#     desired_caps = {
#         caps:       {
#             platformName:  @platform,
#             browserName: @browser_type,
#             versionNumber: @os_version,
#             deviceName: @device_name,
#             udid: @udid,
#             app: @app_path,
#             automationName: @automation_name,
#             noReset: @no_reset
#         },
#     }

  # when 'iOS-real'
  #   @no_reset = false
  #   @platform = 'iOS'
  #
  #   desired_caps = {
  #       caps:       {
  #           platformName:  @platform,
  #           browserName: @browser_type,
  #           versionNumber: @os_version,
  #           deviceName: @device_name,
  #           udid: 'a9648f5a80e3456103275deecded79a7084c2e4b',
  #           app: @app_path,
  #           automationName: @automation_name,
  #           noReset: @no_reset,
  #           xcodeOrgId: "TT9MREG5GA",
  #           xcodeSigningId: "iPhone Developer",
  #           # updatedWDABundleId: "io.appium.WebDriverAgentRunner123"
  #       },
  #   }
  #
  #   begin
  #     Automato::AppiumHelpers.appium_start
  #     DRIVER = Appium::Driver.new(desired_caps, true).start_driver
  #   rescue Exception => e
  #     puts e.message
  #     Process.exit(0)
  #   end
  # local testing
  when 'desktop'
    begin

      # if Automato::OsFunctions.new.is_mac?
      #   dimensions = DRIVER.execute_script(%Q{return { width: window.screen.availWidth, height:window.screen.availHeight};})
      #   DRIVER.manage.window.resize_to(dimensions["width"], dimensions["height"])
      #   DRIVER.manage.window.maximize
      # elsif Automato::OsFunctions.new.is_windows?
      #   DRIVER.manage.window.maximize
      # end
    rescue Exception => e
      puts "Environment error: " + e.message
      Process.exit(0)
    end
  # else test on browserstack
  else
    nil
    # BS_USERNAME  = ENV['BS_USERNAME'] = 'ericsavoie1'
    # BS_AUTHKEY   = ENV['BS_AUTHKEY'] = 'RARq6L6DoCsWtjHgW3y4'
    # url = "http://#{ENV['BS_USERNAME']}:#{ENV['BS_AUTHKEY']}@hub-cloud.browserstack.com/wd/hub"
    #
    # capabilities = Selenium::WebDriver::Remote::Capabilities.new
    #
    # # capabilities['project'] = ENV['BS_AUTOMATE_PROJECT'] if ENV['BS_AUTOMATE_PROJECT']
    # # capabilities['build'] = ENV['BS_AUTOMATE_BUILD'] if ENV['BS_AUTOMATE_BUILD']
    #
    # if ENV['BS_AUTOMATE_OS']
    #   capabilities['os'] = ENV['BS_AUTOMATE_OS']
    #   capabilities['os_version'] = ENV['BS_AUTOMATE_OS_VERSION']
    # else
    #   capabilities['platform'] = ENV['PLATFORM']
    # end
    # capabilities['browser'] = ENV['SELENIUM_BROWSER'] || 'chrome'
    # capabilities['browser_version'] = ENV['BROWSER_VERSION']
    #
    # DRIVER = Selenium::WebDriver.for(:remote, :url => url, :desired_capabilities => capabilities)
end
