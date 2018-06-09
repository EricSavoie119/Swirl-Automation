Given(/I sign in to swirl insurance/) do
  if @browser.exists?
    if @browser.url != "data:,"
      @browser.close
      @browser = Watir::Browser.new BROWSER_TYPE.to_sym
      @swirl = Swirl.new(@browser)
    end
  end
  @browser.window.resize_to(1600, 1000)
  @browser.goto @env['base-uri']['swirl_dev']

  @swirl.login_username.send_keys @env['swirl']['username']
  @swirl.login_password.send_keys @env['swirl']['password']
  @swirl.login_submit.click
end

When(/I click on the "([^"]*)" button$/) do |button|
  case button
    when "applicants"
      @swirl.applicants.click
  end
end

When(/I find the most recent applicant without FQS/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until {@swirl.fqs_checkboxes[1].exists?}
  num = @swirl.page_buttons.count
  @swirl.page_buttons[num-2].child.click
  binding.pry
end

# begin
#   retries ||= 0
#   @qr_page.log_out.click
# rescue Selenium::WebDriver::Error::UnhandledAlertError => e
#   retry if (retries += 1) < 3
# end