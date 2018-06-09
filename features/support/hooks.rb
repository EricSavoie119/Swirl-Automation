#Cucumber provides a numbe rof hooks which allow us to run blocks at various points in the Cucumber test cycle
Before do |scenario|
  scenario.skip_invoke! if scenario.source_tag_names.include? '@manual'

  @env = YAML.load(File.open(File.join(Dir.pwd, 'config', 'env.yml')))
  @env_info = CommandLineHelper.new.ingest(ARGV, @env)

  @user_hash = Hash.new

  @first_name = Faker::Name.first_name + Faker::Number.number(5).gsub("'","")
  @last_name  = Faker::Name.last_name
  @email = "#{@first_name}.#{@last_name}#{Faker::Number.number(3)}@mailinator.com"
  @mobile = "000-#{Faker::Number.number(3)}-#{Faker::Number.number(4)}"

  @guest_first_name = Faker::Name.first_name + Faker::Number.number(5).gsub("'","")
  @guest_last_name  = Faker::Name.last_name
  @guest_email = "#{@guest_first_name}.#{@guest_last_name}#{Faker::Number.number(3)}@mailinator.com"
  @guest_mobile = "000-#{Faker::Number.number(3)}-#{Faker::Number.number(4)}"


  @test_rails_hash = {} # adminUI
  @mobile_test_hash = {}
end

Before('@swirl') do
  @browser = Watir::Browser.new BROWSER_TYPE.to_sym #, :switches => %w[--headless --disable-gpu]
  @swirl = Swirl.new(@browser)
end

After('@adminUI') do
  @browser.close
end

After('@adminUI_mobile') do
  @browser.close
end

After('@iOS_real') do
  @ios_driver.driver.quit
end

After('@android') do
  @android_driver.driver.quit
end

at_exit do
  # Kill simulators or drivers
  case @platform
    when "android"
      # Automato::AppiumHelpers.appium_teardown(DRIVER)
      # Automato::Android.android_teardown
    when "iOS"
      # DRIVER.close_app
      # DRIVER.remove_app('com.waltz.building-access.Building-Access')
      # Automato::AppiumHelpers.appium_teardown(DRIVER)
      # Automato::IPhone.iphone_teardown
    when "desktop"
      # @browser.quit
    when "api", "amqp"
      nil
    else
      # DRIVER.quit
  end
  p Thread.current[:errors]
end