Given(/I am on the "([^"]*)" waltz app home page/) do |os|
  case os
    when "iOS"
      # sleep(2)
      # @ios_driver.driver.switch_to.alert.accept
      @welcome_page = WelcomePage.new(@ios_driver.driver)
    when "android"
      # AndroidAlerts.new.accept_alert_1(@android_driver.driver)
      # AndroidAlerts.new.accept_alert_2(@android_driver.driver)
      # `adb shell input keyevent 27`
      # sleep(1)
      # `adb shell input keyevent 4`
  end
end

When(/I click the "([^"]*)" easter egg 5 times/) do |os|
  case os
    when "iOS"
      5.times { @welcome_page.click_easter_egg(@ios_driver.driver)}
    when "android"
      # @awp = AndroidWelcomePage.new(DRIVER)
      # binding.pry
      # 6.times { @awp.easter_egg.click}
  end
end

When(/I skip the video on "([^"]*)"/) do |os|
  case os
    when "iOS"
      sleep (1)
      @video = VideoiOS.new(@ios_driver.driver)
      @video.video.click
      @video.skip_video(@ios_driver.driver).click
    when "android"
      sleep(1)
      @video = AndroidVideo.new(@android_driver.driver)
      @video.video.click
      @video.skip_video(@android_driver.driver).click
  end
end

When(/I select the "([^"]*)" environment for "([^"]*)"/) do |env, os|
  case os
    when "iOS"
      begin
        @easter_egg = EasterEgg.new(@ios_driver.driver)
      rescue Exception => e
        puts "Loading vars from wrong page: " + e.message
      end
      case env
        when "QA"
          @easter_egg.qa_env.click
          @easter_egg.left_arrow.click
      end
    when "android"
      # case env
      #   when "QA"
      #     AndroidEasterEgg.new.click_qa(DRIVER)
      #     AndroidEasterEgg.new.click_ok(DRIVER)
      # end
  end
end

When(/I log in to the "([^"]*)" mobile app as "([^"]*)"$/) do |os, role|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)

  case os
    when "iOS"
      wait.until {@welcome_page.log_in.displayed?}
      @welcome_page.log_in.click
      begin
        @login_page = LoginPage.new(@ios_driver.driver)
      rescue Exception => e
        puts "Likely you're loading the wrong page: " + e.message
      end
    when "android"
      @awp = AndroidWelcomePage.new(@android_driver.driver)
      @awp.log_in.click

      begin
        @login_page = AndroidLoginPage.new(@android_driver.driver)
      rescue Exception => e
        puts "Likely you're loading the wrong page: " + e.message
      end
  end
  @login_page.username.clear
  case role
    when "tenant admin"
      @login_page.username.send_keys @env['auth']['qa']['tenant_admin']
      @login_page.password.send_keys @env['password']
    when "new user"
      @login_page.username.send_keys @email
      @login_page.password.send_keys @env['password']
    when "new guest"
      @login_page.username.send_keys @guest_email
      @login_page.password.send_keys @env['password']
    else
      @login_page.username.send_keys @user_hash[role.to_sym][:email]
      @login_page.password.send_keys @env['password']
  end
  case os
    when  "iOS"
      @login_page.log_in.click
    when "android"
      AndroidLoginPage.log_in(@android_driver.driver).click
  end
end

When(/I accept the camera dialogs on "([^"]*)"/) do |os|
  case os
    when "iOS"
      @ios_driver.driver.find_element(:name => "Turn on camera access to try!").click
      @ios_driver.driver.switch_to.alert.accept
    when "android"
      AndroidQRPage.camera_accept(@android_driver.driver)
      AndroidQRPage.camera_native_accept(@android_driver.driver)
  end
end

When(/I "([^"]*)" the selfie flow on "([^"]*)"/) do |action, os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  case os
    when "iOS"
      case action
        when "back out of"
          @ios_driver.driver.find_element(:name => "Finish your profile with a selfie!").click
          @ios_driver.driver.find_element(:name => "BACK").click
          wait.until {@ios_driver.driver.find_element(:name => "Got it!").displayed?}
          @ios_driver.driver.find_element(:name => "Got it!").click
        when "complete"
          @ios_driver.driver.find_element(:name => "Finish your profile with a selfie!").click
          @ios_driver.driver.find_element(:name => "button").click
          @ios_driver.driver.find_element(:name => "Save").click
          wait.until {@ios_driver.driver.find_element(:name => "Got it!").displayed?}
          @ios_driver.driver.find_element(:name => "Got it!").click
        when "skip"
          @ios_driver.driver.find_element(:name => "Not Now").click
          @ios_driver.driver.find_element(:name => "Got it!").click
        when "partially complete"
          @ios_driver.driver.find_element(:name => "Finish your profile with a selfie!").click
      end
    when "android"
      case action
        when "skip"
          AndroidSelfie.skip_selfie(@android_driver.driver)
          AndroidSelfie.skip_selfie(@android_driver.driver)
        when "complete"
          AndroidSelfie.accept_selfie(@android_driver.driver)
          @android_selfie = AndroidSelfie.new(@android_driver.driver)
          @android_selfie.take_photo.click
          wait.until {@android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/save")}
          @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/save").click
          wait.until {@android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/permission_dialog_positive_button").displayed?}
          @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/permission_dialog_positive_button").click
        when "back out of"
          AndroidSelfie.accept_selfie(@android_driver.driver)
          @android_selfie = AndroidSelfie.new(@android_driver.driver)
          @android_selfie.cancel.click
          wait.until {@android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/permission_dialog_negative_button").displayed?}
          @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/permission_dialog_negative_button").click
      end
  end
end

Then(/I verify I am on the "([^"]*)" "([^"]*)"/) do |os, page|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  qr_validation = {}
  case os
    when "iOS"
      case page
        when "qr page"
          @qr_page = QRPage.new(@ios_driver.driver)
          qr_validation.merge!({:qr_user_message => (@qr_page.user_message.displayed?)})
          qr_validation.merge!({:qr_displayed => @qr_page.qr_code.present?})
          # * * * * * * * T E S T R A I L S * * * * * * *
          # C54: After a successful Log in, verify the presence of the Open Door QR code.
          # Criteria:
          # The QR code is present
          # Suite Real Estate App (iOS)
          # ---------------------------------------------

          TestRailsTest.check_54_2(@env_info, @client, qr_validation.values.all?)
      end
    when "android"
      case page
        when "qr page"
          @qr_page = AndroidQRPage.new(@android_driver.driver)
          qr_validation.merge!({:qr_user_message => (@qr_page.user_message.displayed?)})
          # * * * * * * * T E S T R A I L S * * * * * * *
          # C37: After a successful Log in, verify the presence of the Open Door QR code.
          # Criteria: Can change contact name
          #
          message = "The QR page was not present"
          suite = "Real Estate App (Android)"
          case_id = 37
          # ---------------------------------------------

          TestRailsTest.validator(@env_info, @client, suite, case_id, qr_validation.values.all?, message)
      end
  end
end


When(/I "([^"]*)" a selfie on "([^"]*)"$/) do |action, os|
  case os
    when "iOS"
      @selfie = Selfie.new(@ios_driver.driver)
      wait = Selenium::WebDriver::Wait.new(:timeout => 30)
      wait.until {@selfie.take_photo.displayed?}
      case action
        when "take"
          @selfie.take_photo.click
          @selfie.save_selfie(@ios_driver.driver)
        when "skip"
          @selfie.cancel.click
      end
      wait.until {
        @qr_page = QRPage.new(@ios_driver.driver)
        @qr_page.user_message.displayed?
      }
    when "android"
      @selfie = AndroidSelfie.new(@android_driver.driver)
      wait = Selenium::WebDriver::Wait.new(:timeout => 30)
      wait.until {@selfie.take_photo.displayed?}
      case action
        when "skip"
          `adb shell input keyevent 4`
      end
  end

end

When(/I "([^"]*)" a selfie on "([^"]*)" and go back to menu$/) do |action, os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  case os
    when "iOS"
      case action
        when "take"
          wait.until {@ios_driver.driver.find_element(:name => "button").displayed?}
          @ios_driver.driver.find_element(:name => "button").click
          @ios_driver.driver.find_element(:name => "Save").click
        when "skip"
          wait.until {@ios_driver.driver.find_element(:name => "BACK").displayed?}
          @ios_driver.driver.find_element(:name => "BACK").click
        when "cancel"
          wait.until {@ios_driver.driver.find_element(:name => "button").displayed?}
          @ios_driver.driver.find_element(:name => "button").click
          wait.until {@ios_driver.driver.find_element(:name => "Take a Selfie").displayed?}
          @ios_driver.driver.find_element(:name => "Take a Selfie").click
          wait.until {@ios_driver.driver.find_element(:name => "BACK").displayed?}
          @ios_driver.driver.find_element(:name => "BACK").click
      end
    when "android"
      case action
        when "skip"
          @android_selfie = AndroidSelfie.new(@android_driver.driver)
          @android_selfie.cancel.click
        when "take"
          @android_selfie = AndroidSelfie.new(@android_driver.driver)
          @android_selfie.take_photo.click
          wait.until {@android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/save")}
          @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/save").click
          # wait.until {@android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/permission_dialog_positive_button").displayed?}
          # @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/permission_dialog_positive_button").click
      end
  end
end


When(/I choose "([^"]*)" for my "([^"]*)" user on "([^"]*)"$/) do |option, num, os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  case os
    when "iOS"
      wait.until {@welcome_page.log_in.displayed?}
      @welcome_page.log_in.click
      begin
        @login_page = LoginPage.new(@ios_driver.driver)
      rescue Exception => e
        puts "Likely you're loading the wrong page: " + e.message
      end
      @login_page.forgot.click
      @ios_driver.driver.find_elements(:class_name => "XCUIElementTypeTextField")[0].clear
      @ios_driver.driver.find_elements(:class_name => "XCUIElementTypeTextField")[0].send_keys @user_hash[num.to_s.to_sym][:email].downcase
      @ios_driver.driver.find_element(:name => "Send email").click
      FirePoll.poll("Wait for Alert", 10) do
        @ios_driver.driver.find_element(:name => "OK")
      end
      @ios_driver.driver.find_element(:name => "OK").click
      begin
        @login_page = LoginPage.new(@ios_driver.driver)
      rescue Exception => e
        puts "Likely you're loading the wrong page: " + e.message
      end
    when "android"
      @awp = AndroidWelcomePage.new(@android_driver.driver)
      wait.until {@awp.log_in.displayed?}
      @awp.log_in.click
      begin
        @login_page = AndroidLoginPage.new(@android_driver.driver)
      rescue Exception => e
        puts "Likely you're loading the wrong page: " + e.message
      end
      @login_page.forgot.click
      @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/user_email_address").clear
      @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/user_email_address").send_keys @user_hash[num.to_s.to_sym][:email].downcase
      @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/send_button").click
      FirePoll.poll("Wait for Alert", 10) do
        @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/md_content")
      end
      @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/md_buttonDefaultPositive").click
      begin
        @login_page = AndroidLoginPage.new(@android_driver.driver)
      rescue Exception => e
        puts "Likely you're loading the wrong page: " + e.message
      end
      @android_driver.driver.find_element(:class_name => "android.widget.ImageButton").click
  end

  response = Automato::MailinatorHelper.getInbox(@user_hash[num.to_s.to_sym][:email])
  email = Automato::MailinatorHelper.get_individual_email(response['messages'][1]['id'])
  parsed_body = Nokogiri(email['data']['parts'][0]['body'])

  reset_link = parsed_body.search('a')[1].to_h['href']

  @browser.goto reset_link
  case os
    when "iOS"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C52: Verify that the 'Forgot your password?' link directs the user to enter their email for a password reset.
      # Criteria:
      # Browser url for forgot password directs user to input a new password
      # Suite Real Estate App (iOS)
      # ---------------------------------------------
      TestRailsTest.check_52(@env_info, @client, @browser)

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C53: Verify that a password reset link is sent to the email address in the  'Forgot your password?' view
      # Criteria:
      # Browser URL includes forgot password, the forgot password dialogs are available
      # Suite Real Estate App (iOS)
      # ---------------------------------------------

      TestRailsTest.check_53(@env_info, @client, @browser)

    when "android"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C29: Verify that a password reset link is sent to the email address in the  'Forgot your password?' view
      # Criteria:
      # Browser URL includes forgot password, the forgot password dialogs are available
      # Suite Real Estate App (android)
      # ---------------------------------------------

      TestRailsTest.check_28(@env_info, @client, @browser)

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C29: Verify that a password reset link is sent to the email address in the  'Forgot your password?' view
      # Criteria:
      # Browser URL includes forgot password, the forgot password dialogs are available
      # Suite Real Estate App (android)
      # ---------------------------------------------

      TestRailsTest.check_29(@env_info, @client, @browser)

  end

  @admin_ui.sign_up_password.send_keys @env['password2']
  @admin_ui.sign_up_button.click
  @user_hash[num.to_s.to_sym][:password] = @env['password2']
  @user_hash[num.to_s.to_sym][:pass_changed] = :true
end

Then(/I validate the invalid log in errors "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  log_in_validation = {}
  case os
    when "iOS"
      wait.until {@welcome_page.log_in.displayed?}
      @welcome_page.log_in.click
      @login_page = LoginPage.new(@ios_driver.driver)
      @login_page.username.clear
      @login_page.username.send_keys "1"
      @login_page.log_in.click
      log_in_validation.merge!({:invalid_email_format_length => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid email format").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @login_page.username.clear
      @login_page.username.send_keys "erics"
      @login_page.log_in.click
      log_in_validation.merge!({:invalid_email_format_1 => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid email format").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @login_page.username.clear
      @login_page.username.send_keys "erics@"
      @login_page.log_in.click
      log_in_validation.merge!({:invalid_email_format_2 => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid email format").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @login_page.username.clear
      @login_page.username.send_keys "erics@eric.com"
      @login_page.log_in.click
      log_in_validation.merge!({:invalid_password_empty => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid password format").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @login_page.password.send_keys "1"
      @login_page.log_in.click
      log_in_validation.merge!({:invalid_password_length => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid password format").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @login_page.password.clear
      @login_page.password.send_keys "letswaltz123"
      @login_page.log_in.click
      log_in_validation.merge!({:invalid_password_format_1 => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid password format").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @login_page.password.clear
      @login_page.password.send_keys "Letswaltz"
      @login_page.log_in.click
      log_in_validation.merge!({:invalid_password_format_2 => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid password format").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @login_page.password.clear
      @login_page.password.send_keys "LetsWaltz12"
      @login_page.log_in.click
      log_in_validation.merge!({:invalid_email_or_password => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid email address and/or password.").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C49: Verify that entering an invalid email address or password prevents the user from attempting to log in and displays an appropriate error message.
      # Criteria:
      # Log in page has password and email validation
      # Suite Real Estate App (android)
      # ---------------------------------------------

      TestRailsTest.check_49(@env_info, @client, log_in_validation.values.all?)
    when "android"
      @welcome_page = AndroidWelcomePage.new(@android_driver.driver)
      wait.until {@welcome_page.log_in.displayed?}
      @welcome_page.log_in.click
      @login_page = AndroidLoginPage.new(@android_driver.driver)
      @login_page.username.clear
      @login_page.username.click
      @login_page.username.send_keys "1"
      @login_page.log_in(@android_driver.driver).click
      sleep(1)
      @android_driver.driver.save_screenshot("test.png")
      log_in_validation.merge!({:invalid_email_format_length => (Phashion::Image.new("#{File.expand_path('.')}/lib/mobile/android/android_images/invalid_email_format_length.png").duplicate?(Phashion::Image.new("#{File.expand_path('.')}/test.png")))})
      @login_page.username.clear
      @login_page.username.click
      @login_page.username.send_keys "erics"
      @login_page.log_in(@android_driver.driver).click
      sleep(1)
      @android_driver.driver.save_screenshot("test.png")
      log_in_validation.merge!({:invalid_email_format_1 => (Phashion::Image.new("#{File.expand_path('.')}/lib/mobile/android/android_images/invalid_email_format_1.png").duplicate?(Phashion::Image.new("#{File.expand_path('.')}/test.png")))})
      @login_page.username.clear
      @login_page.username.click
      @login_page.username.send_keys "erics@"
      @login_page.log_in(@android_driver.driver).click
      sleep(1)
      @android_driver.driver.save_screenshot("test.png")
      log_in_validation.merge!({:invalid_email_format_2 => (Phashion::Image.new("#{File.expand_path('.')}/lib/mobile/android/android_images/invalid_email_format_2.png").duplicate?(Phashion::Image.new("#{File.expand_path('.')}/test.png")))})
      @login_page.username.clear
      @login_page.username.click
      @login_page.username.send_keys "erics@eric.com"
      @login_page.password.click
      @login_page.log_in(@android_driver.driver).click
      sleep(1)
      @android_driver.driver.save_screenshot("test.png")
      log_in_validation.merge!({:invalid_password_empty => (Phashion::Image.new("#{File.expand_path('.')}/lib/mobile/android/android_images/invalid_password_empty.png").duplicate?(Phashion::Image.new("#{File.expand_path('.')}/test.png")))})
      @login_page.password.clear
      @login_page.password.click
      @login_page.password.send_keys "1"
      @login_page.password.click
      @login_page.log_in(@android_driver.driver).click
      sleep(1)
      @android_driver.driver.save_screenshot("test.png")
      log_in_validation.merge!({:invalid_password_length => (Phashion::Image.new("#{File.expand_path('.')}/lib/mobile/android/android_images/invalid_password_length.png").duplicate?(Phashion::Image.new("#{File.expand_path('.')}/test.png")))})
      @login_page.password.clear
      @login_page.password.click
      @login_page.password.send_keys "letswaltz123"
      @login_page.password.click
      @login_page.log_in(@android_driver.driver).click
      sleep(1)
      @android_driver.driver.save_screenshot("test.png")
      log_in_validation.merge!({:invalid_password_format_1 => (Phashion::Image.new("#{File.expand_path('.')}/lib/mobile/android/android_images/invalid_password_format_1.png").duplicate?(Phashion::Image.new("#{File.expand_path('.')}/test.png")))})
      @login_page.password.clear
      @login_page.password.click
      @login_page.password.send_keys "Letswaltz"
      @login_page.password.click
      @login_page.log_in(@android_driver.driver).click
      sleep(1)
      @android_driver.driver.save_screenshot("test.png")
      log_in_validation.merge!({:invalid_password_format_2 => (Phashion::Image.new("#{File.expand_path('.')}/lib/mobile/android/android_images/invalid_password_format_1.png").duplicate?(Phashion::Image.new("#{File.expand_path('.')}/test.png")))})
      @login_page.password.clear
      @login_page.password.click
      @login_page.password.send_keys "LetsWaltz12"
      @login_page.password.click
      @login_page.log_in(@android_driver.driver).click
      sleep(1)
      @android_driver.driver.save_screenshot("test.png")
      log_in_validation.merge!({:invalid_email_or_password => (Phashion::Image.new("#{File.expand_path('.')}/lib/mobile/android/android_images/invalid_email_or_password.png").duplicate?(Phashion::Image.new("#{File.expand_path('.')}/test.png")))})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C25: Verify that entering an invalid email address or password prevents the user from attempting to log in and displays an appropriate error message.
      # Criteria: Can change contact name
      #
      message = "Error messages were not correct"
      suite = "Real Estate App (Android)"
      case_id = 25
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, log_in_validation.values.all?, message)
  end
end

When(/I tap to the "([^"]*)" page "([^"]*)"$/) do |page, os|
  case os
    when "iOS"
      case page
        when "log in"
          @welcome_page = WelcomePage.new(@ios_driver.driver)
          @welcome_page.log_in.click
        when "forgot password"
          @login_page = LoginPage.new(@ios_driver.driver)
          @login_page.forgot.click
      end
    when "android"
      case page
        when "log in"
          @welcome_page = AndroidWelcomePage.new(@android_driver.driver)
          @welcome_page.log_in.click
        when "forgot password"
          @login_page = AndroidLoginPage.new(@android_driver.driver)
          @login_page.forgot.click
      end
  end
end

Then(/I validate the show hide button "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  show_hide_validation = {}
  case os
    when "iOS"
      wait.until {@ios_driver.driver.find_elements(:class_name => "XCUIElementTypeButton")[4].displayed?}
      show_hide_validation.merge!({:password_hidden => (@ios_driver.driver.find_elements(:class_name => "XCUIElementTypeButton")[4].text == "SHOW")})
      @ios_driver.driver.find_elements(:class_name => "XCUIElementTypeButton")[4].click
      @ios_driver.driver.find_elements(:class_name => "XCUIElementTypeButton")[4].click
      show_hide_validation.merge!({:password_visible => (@ios_driver.driver.find_elements(:class_name => "XCUIElementTypeButton")[4].text == "HIDE")})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C51: Verify that the SHOW/HIDE password button functions correctly.
      # Criteria:
      # Show Hide button has expected functionality
      # Suite Real Estate App (android)
      # ---------------------------------------------

      TestRailsTest.check_51(@env_info, @client, show_hide_validation.values.all?)
    when "android"
      @login_page = AndroidLoginPage.new(@android_driver.driver)
      wait.until {@login_page.show_hide.displayed?}
      show_hide_validation.merge!({:password_hidden => (@login_page.show_hide.text == "SHOW")})
      @login_page.show_hide.click
      show_hide_validation.merge!({:password_shown => (@login_page.show_hide.text == "HIDE")})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C27: Verify that the SHOW/HIDE password button functions correctly.
      # Criteria: Can change contact name
      #
      message = "Show hide is as expected"
      suite = "Real Estate App (Android)"
      case_id = 27
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, show_hide_validation.values.all?, message)

  end

end

When(/I choose the forgot password link on "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  forgot_password_validation = {}
  case os
    when "iOS"
      begin
        @login_page = LoginPage.new(@ios_driver.driver)
      rescue Exception => e
        binding.pry
      end
      @login_page.forgot.click
      wait.until {@ios_driver.driver.find_element(:name => "Forgot Password").displayed?}
      forgot_password_validation.merge!({:forgot_pass_screen => (@ios_driver.driver.find_element(:name => "Forgot Password").displayed?)})
      forgot_password_validation.merge!({:forgot_pass_button => (@ios_driver.driver.find_element(:name => "Send email").displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C52: Verify that the 'Forgot your password?' link directs the user to enter their email for a password reset.
      # Criteria:
      # Mobile forgot pass button
      # Suite Real Estate App (iOS)
      # ---------------------------------------------
      TestRailsTest.check_52_2(@env_info, @client, forgot_password_validation.values.all?)
    when "android"
      begin
        @login_page = AndroidLoginPage.new(@android_driver.driver)
      rescue Exception => e
        binding.pry
      end
      @login_page.forgot.click
      @forgot_page = AndroidForgotPassword.new(@android_driver.driver)
      wait.until {@forgot_page.username.displayed?}
      forgot_password_validation.merge!({:forgot_pass_screen => (@forgot_page.username.displayed?)})
      forgot_password_validation.merge!({:forgot_pass_button => (@forgot_page.forgot_pass_text.text == "Forgot Password")})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C28: Verify that the 'Forgot your password?' link directs the user to enter their email for a password reset.
      # Criteria: Can change contact name
      #
      message = "Forgot password didn't bring me to the forgot pass page"
      suite = "Real Estate App (Android)"
      case_id = 28
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, forgot_password_validation.values.all?, message)
  end
end

Then(/I validate that an email gets sent "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      email_sent_validation = {}
      wait.until {@ios_driver.driver.find_elements(:class_name => "XCUIElementTypeTextField")[0].displayed?}
      @ios_driver.driver.find_elements(:class_name => "XCUIElementTypeTextField")[0].clear
      @ios_driver.driver.find_elements(:class_name => "XCUIElementTypeTextField")[0].send_keys @env['auth']['qa']['employee']
      @ios_driver.driver.find_element(:name => "Send email").click
      FirePoll.poll("Wait for Alert", 10) do
        @ios_driver.driver.find_element(:name => "OK")
      end
      email_sent_validation.merge!({:OK_button => (@ios_driver.driver.find_element(:name => "OK").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click

      response = Automato::MailinatorHelper.getInbox(@env['auth']['qa']['employee'])
      email = Automato::MailinatorHelper.get_individual_email(response['messages'][0]['id'])
      parsed_body = Nokogiri(email['data']['parts'][0]['body'])

      reset_link = parsed_body.search('a')[1].to_h['href']

      @browser.goto reset_link
      wait.until {@browser.element(:css => 'input[type="password"]').present?}
      email_sent_validation.merge!({:browser_opens => (@browser.url.include? "forgot-password/new-password")})

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C53: Verify that a password reset link is sent to the email address in the 'Forgot your password?' view.
      # Criteria:
      # Browser URL includes forgot password, the forgot password dialogs are available
      # Suite Real Estate App (iOS)
      # ---------------------------------------------

      TestRailsTest.check_53_2(@env_info, @client, email_sent_validation)
    when "android"
      email_sent_validation = {}
      @forgot_page = AndroidForgotPassword.new(@android_driver.driver)
      wait.until {@forgot_page.forgot_pass_text.displayed?}
      @forgot_page.username.clear
      @forgot_page.username.send_keys @env['auth']['qa']['employee']
      @forgot_page.send_email.click
      FirePoll.poll("Wait for Alert", 15) do
        @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/md_content").text == "A message will be sent to that address containing a link to reset your password."
      end
      email_sent_validation.merge!({:email_sent => (@android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/md_buttonDefaultPositive"))})
      @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/md_buttonDefaultPositive").click

      response = Automato::MailinatorHelper.getInbox(@env['auth']['qa']['employee'])
      email = Automato::MailinatorHelper.get_individual_email(response['messages'][0]['id'])
      parsed_body = Nokogiri(email['data']['parts'][0]['body'])

      reset_link = parsed_body.search('a')[1].to_h['href']

      @browser.goto reset_link
      wait.until {@browser.element(:css => 'input[type="password"]').present?}
      email_sent_validation.merge!({:browser_opens => (@browser.url.include? "forgot-password/new-password")})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C29: Verify that a password reset link is sent to the email address in the 'Forgot your password?' view.
      # Criteria: Can change contact name
      #
      message = "The password reset link was not sent"
      suite = "Real Estate App (Android)"
      case_id = 29
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, email_sent_validation.values.all?, message)
  end

end

When(/I send a forgot password email to "([^"]*)" "([^"]*)"$/) do |user, os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case user
    when "new user"
      case os
        when "iOS"
          wait.until {@ios_driver.driver.find_elements(:class_name => "XCUIElementTypeTextField")[0].displayed?}
          @ios_driver.driver.find_elements(:class_name => "XCUIElementTypeTextField")[0].clear
          @ios_driver.driver.find_elements(:class_name => "XCUIElementTypeTextField")[0].send_keys @email
          @ios_driver.driver.find_element(:name => "Send email").click
          FirePoll.poll("Wait for Alert", 10) do
            @ios_driver.driver.find_element(:name => "OK")
          end
          @ios_driver.driver.find_element(:name => "OK").click
        when "android"
          @forgot_page = AndroidForgotPassword.new(@android_driver.driver)
          wait.until {@forgot_page.forgot_pass_text.displayed?}
          @forgot_page.username.clear
          @forgot_page.username.send_keys @email
          @forgot_page.send_email.click
          FirePoll.poll("Wait for Alert", 15) do
            @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/md_content").text == "A message will be sent to that address containing a link to reset your password."
          end
          FirePoll.poll("Wait for Alert", 15) do
            @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/md_buttonDefaultPositive").displayed?
          end

          @android_driver.driver.find_element(:id => "com.waltzapp.android.access.debug:id/md_buttonDefaultPositive").click
    end
  end
end

When(/I go to the forgot password page for my "([^"]*)"$/) do |user|
  case user
    when "new user"
      response = Automato::MailinatorHelper.getInbox(@email)
      email = Automato::MailinatorHelper.get_individual_email(response['messages'][0]['id'])
      delete = Automato::MailinatorHelper.delete_email(response['messages'][0]['id'])
      parsed_body = Nokogiri(email['data']['parts'][0]['body'])


      @reset_link = parsed_body.search('a')[1].to_h['href']

      @browser.goto @reset_link
  end
end

Then(/I verify I cannot reset the password twice "([^"]*)"$/) do |os|
  double_reset_password_validation = {}
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  @admin_ui.password.send_keys "LetsWaltz1234"
  @admin_ui.sign_in.click
  wait.until { @browser.element(:css => 'h1').text.include? "Success"}
  @browser.goto @reset_link
  @admin_ui.password.send_keys "LetsWaltz1235"
  @admin_ui.sign_in.click
  wait.until {@browser.element(:css => 'h1').text.include? "Password NOT Changed"}
  double_reset_password_validation.merge!({:reset_twice => (@browser.element(:css => 'h1').text.include? "Password NOT Changed")})
  case os
    when "iOS"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C409: Verify that the email Password change link cannot be used once a password has been successfully changed and returns a message 'Password not changed'.
      # Criteria:
      # Password not changed second time around
      # Suite Real Estate App (iOS)
      # ---------------------------------------------

      TestRailsTest.check_409(@env_info, @client, double_reset_password_validation.values.all?)
    when "android"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C408: Verify that the email Password change link cannot be used once a password has been successfully changed and returns a message 'Password not changed'.
      # Criteria: Can change contact name
      #
      message = "The password was able to be reset twice"
      suite = "Real Estate App (Android)"
      case_id = 408
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, double_reset_password_validation.values.all?, message)
  end


end

When(/I fill out a new password/) do
  @admin_ui.password.send_keys @env['password2']
  @admin_ui.sign_in.click
end

Then(/I log in to the "([^"]*)" mobile app as "([^"]*)" with new password$/) do |os, role|
  case os
    when "iOS"
      case role
        when "new user"
          begin
            @login_page = LoginPage.new(@ios_driver.driver)
          rescue Exception => e
            puts "Likely you're loading the wrong page: " + e.message
          end
          case role
            # when "tenant admin"
            #   @login_page.username.send_keys @env['auth']['qa']['tenant_admin']
            #   @login_page.password.send_keys @env['password']
            when "new user"
              @login_page.username.send_keys @email
              @login_page.password.send_keys @env['password2']
            # else
            #   @login_page.username.send_keys @user_hash[role.to_sym][:email]
            #   @login_page.password.send_keys @env['password']
          end
      end
    when "android"
      begin
        @login_page = AndroidLoginPage.new(@android_driver.driver)
      rescue Exception => e
        puts "i dunno"
      end
      @login_page.username.clear
      case role
        # when "tenant admin"
        #   @login_page.username.send_keys @env['auth']['qa']['tenant_admin']
        #   @login_page.password.send_keys @env['password']
        when "new user"
          @login_page.username.send_keys @email
          @login_page.password.send_keys @env['password2']
        # else
        #   @login_page.username.send_keys @user_hash[role.to_sym][:email]
        #   @login_page.password.send_keys @env['password']
      end
  end
  case os
    when "iOS"
      @login_page.log_in.click
    when "android"
      @login_page.log_in(@android_driver.driver).click
  end


end

Then(/I verify I am logged in "([^"]*)"$/) do |os|
  case os
    when "iOS"
      log_in_validation = {}
      @qr_page = QRPage.new(@ios_driver.driver)
      log_in_validation.merge!({:qr_page_visible => (@qr_page.user_message.displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C279: Verify that the user can sign in to the app with the reset password.
      # Criteria:
      # User can sign in with reset password
      # Suite Real Estate App (iOS)
      # ---------------------------------------------

      TestRailsTest.check_279_2(@env_info, @client, log_in_validation.values.all?)
    when "android"
      log_in_validation = {}
      @qr_page = AndroidQRPage.new(@android_driver.driver)
      log_in_validation.merge!({:qr_page_visible => (@qr_page.user_message.displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C278: Verify that the user can sign into the app with the new password.
      # Criteria: Can change contact name
      #
      message = "The password was able to be reset twice"
      suite = "Real Estate App (Android)"
      case_id = 278
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, log_in_validation.values.all?, message)
  end

end

Then(/I verify I can log out of the mobile app "([^"]*)"$/) do |os|
  log_out_validation = {}
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      @qr_page = QRPage.new(@ios_driver.driver)
      @qr_page.menu.click
      wait.until{@qr_page.log_out.displayed?
      sleep(0.2)}
      begin
        retries ||= 0
        @qr_page.log_out.click
      rescue Selenium::WebDriver::Error::UnhandledAlertError => e
        retry if (retries += 1) < 3
      end
      begin
        @welcome_page = WelcomePage.new(@ios_driver.driver)
      rescue Exception => e
        puts "Likely you're loading the wrong page: " + e.message
      end
      log_out_validation.merge!({:welcome_page_displayed => (@welcome_page.log_in.displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C56: Verify that the user can sign in to the app with the reset password.
      # Criteria:
      # User can sign in with reset password
      # Suite Real Estate App (iOS)
      # ---------------------------------------------

      TestRailsTest.check_56_2(@env_info, @client, log_out_validation.values.all?)
    when "android"
      @qr_page = AndroidQRPage.new(@android_driver.driver)
      @qr_page.open_menu.click
      @menu = AndroidMenu.new(@android_driver.driver)
      wait.until {@menu.log_out.displayed?}
      @menu.log_out.click
      begin
        @welcome_page = AndroidWelcomePage.new(@android_driver.driver)
      rescue Exception => e
        puts "Likely you're loading the wrong page: " + e.message
      end
      log_out_validation.merge!({:welcome_page_displayed => (@welcome_page.log_in.displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C12912: Verify the Log out button(s) return user to the Log in view.
      # Criteria: Can change contact name
      #
      message = "User was not able to log out"
      suite = "Real Estate App (Android)"
      case_id = 12912
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, log_out_validation.values.all?, message)
  end

end

When(/I log out of the mobile app "([^"]*)"/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      @qr_page = QRPage.new(@ios_driver.driver)
      @qr_page.menu.click
      wait.until{@qr_page.log_out.displayed?
      sleep(0.2)}
      begin
        retries ||= 0
        @qr_page.log_out.click
      rescue Selenium::WebDriver::Error::UnhandledAlertError => e
        retry if (retries += 1) < 3
      end
    when "android"
      begin
        retries ||= 0
        wait.until {@qr_page = AndroidQRPage.new(@android_driver.driver)}
        @qr_page.open_menu.click
      rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
        retry if (retries += 1) < 3
      end
      @menu = AndroidMenu.new(@android_driver.driver)
      @menu.log_out.click
  end

end

Then(/I verify my email is prefilled "([^"]*)"$/) do |os|
  prefill_validation = {}
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      wait.until {@ios_driver.driver.find_elements(:class_name => "XCUIElementTypeTextField")[0].displayed?}
      prefill_validation.merge!({:email_prefilled => (@ios_driver.driver.find_elements(:class_name => "XCUIElementTypeTextField")[0].text.include? @env['auth']['qa']['tenant_admin'])})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C4770: After logging out, verify that the last used email is prefilled on the log in screen.
      # Criteria:
      # Email is prefilled
      # Suite Real Estate App (iOS)
      # ---------------------------------------------

      TestRailsTest.check_4770(@env_info, @client, prefill_validation.values.all?)
    when "android"
      @login_page = AndroidLoginPage.new(@android_driver.driver)
      prefill_validation.merge!({:email_prefilled => (@login_page.username.text.include? @env['auth']['qa']['tenant_admin'])})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C47: Verify the Log out button(s) return user to the splash page and the most recently used email is prefilled on the log in screen.
      # Criteria:
      # Video plays on first log in
      message = "Email was not pre-filled"
      suite = "Real Estate App (Android)"
      case_id = 47
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, prefill_validation.values.all?, message)

  end

end

Then(/I verify the presence of the instruction video "([^"]*)"$/) do |os|
  case os
    when "iOS"
      @video = VideoiOS.new(@ios_driver.driver)
      @video.video.displayed?
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C2753: When the user logs in to the app for the first time, verify the presence of the instruction video.
      # Criteria:
      # Video plays on first log in
      message = "video did not play"
      suite = "Real Estate App (iOS)"
      case_id = 2753
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, @video.video.displayed?, message)
    when "android"
      @video = AndroidVideo.new(@android_driver.driver)
      @video.video.displayed?
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C2757: When the user logs in to the app for the first time, verify the presence of the instruction video.
      # Criteria:
      # Video plays on first log in
      message = "video did not play"
      suite = "Real Estate App (Android)"
      case_id = 2757
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, @video.video.displayed?, message)
  end
end



Then(/I verify I can skip the video on "([^"]*)"/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  can_skip_video_validation = {}
  case os
    when "iOS"
      @video = VideoiOS.new(@ios_driver.driver)
      wait.until {@video.video.displayed?}
      sleep(11)
      @video.video.click
      can_skip_video_validation.merge!({:skip_exists => (@ios_driver.driver.find_element(:name => "Skip >").displayed?)})
      @video.skip_video(@ios_driver.driver).click
      wait.until {@qr_page = QRPage.new(@ios_driver.driver)}
      can_skip_video_validation.merge!({:skip_worked => (@qr_page.user_message.displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C2754: Verify that the video can be skipped by pressing on the skip button on the bottom right after the 16 second mark.
      # Criteria:
      # Video can be skipped
      message = "Video wasn't skipped"
      suite = "Real Estate App (iOS)"
      case_id = 2754
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, can_skip_video_validation.values.all?, message)
    when "android"
      @video = AndroidVideo.new(@android_driver.driver)
      wait.until {@video.video.displayed?}
      sleep(4)
      @video.video.click
      can_skip_video_validation.merge!({:skip_exists => (@video.skip_video(@android_driver.driver).displayed?)})
      @video.skip_video(@android_driver.driver).click
      wait.until {@qr_page = AndroidQRPage.new(@android_driver.driver)}
      can_skip_video_validation.merge!({:skip_worked => (@qr_page.user_message.displayed?)})

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C2758: Verify that the video can be skipped by pressing on the skip button on the bottom right after the 11 second mark.
      # Criteria:
      # Video can be skipped
      message = "Video wasn't skipped"
      suite = "Real Estate App (Android)"
      case_id = 2758
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, can_skip_video_validation.values.all?, message)
  end
end

Then(/I verify I am prompted to take a photo "([^"]*)"/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      wait.until {@ios_driver.driver.find_element(:name => "Finish your profile with a selfie!").displayed?}
      @mobile_test_hash.merge!({:take_photo => (@ios_driver.driver.find_element(:name => "Finish your profile with a selfie!").displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C450: Verify that the first time I login I am prompted to add a selfie to my account.
      # Criteria:
      # Prompted to take photo multiple times
      message = "Was not prompted to take photo"
      suite = "Real Estate App (iOS)"
      case_id = 450
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, @mobile_test_hash.values.all?, message)
    when "android"
      wait.until {AndroidSelfie.find_selfie_button(@android_driver.driver)}
      @mobile_test_hash.merge!({:take_photo => (AndroidSelfie.find_selfie_button(@android_driver.driver).displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C459: Verify that the first time I login I am prompted to add a selfie to my account.
      # Criteria:
      # Prompted to take photo multiple times
      message = "Was not prompted to take photo"
      suite = "Real Estate App (iOS)"
      case_id = 450
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, @mobile_test_hash.values.all?, message)
  end
end

Then(/I verify that I took a photo "([^"]*)"/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  took_photo_validation = {}
  case os
    when "iOS"
      @qr_page = QRPage.new(@ios_driver.driver)
      @qr_page.menu.click
      wait.until{@qr_page.log_out.displayed?}
      @ios_driver.driver.manage.timeouts.implicit_wait = 5
      took_photo_validation.merge!({:photo_taken => (@ios_driver.driver.find_elements(:name => "user").count == 0)})
      @ios_driver.driver.manage.timeouts.implicit_wait = 300
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C452: If 'Take photo' is selected, verify that I can press 'Take photo' to take a picture immediately with the phone camera.
      # Criteria:
      # Photo was taken
      message = "Photo was not taken"
      suite = "Real Estate App (iOS)"
      case_id = 452
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, took_photo_validation.values.all?, message)
    when "android"
      wait.until {@qr_page = AndroidQRPage.new(@android_driver.driver)}
      wait.until {@qr_page.open_menu.displayed?}
      @qr_page.open_menu.click
      @menu = AndroidMenu.new(@android_driver.driver)
      @android_driver.driver.manage.timeouts.implicit_wait = 5
      @menu = AndroidMenu.new(@android_driver.driver)
      @menu.edit_profile.click
      @edit_account = AndroidEditAccount.new(@android_driver.driver)
      @android_driver.driver.save_screenshot("test.png")
      image = MiniMagick::Image.open('test.png')
      image.crop "#{@edit_account.profile_pic.size.width}x#{@edit_account.profile_pic.size.height}+#{@edit_account.profile_pic.location.x}+#{@edit_account.profile_pic.location.y}"
      image.write 'test.png'
      took_photo_validation.merge!({:photo_is_not_default => !(Phashion::Image.new("#{File.expand_path('.')}/lib/mobile/android/android_images/android_default_no_photo.png").duplicate?(Phashion::Image.new("#{File.expand_path('.')}/test.png")))})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C461: If 'Take photo' is selected, verify that I can press 'Take photo' to take a picture immediately with the phone camera.
      # Criteria:
      # Photo was taken
      message = "Photo was not taken"
      suite = "Real Estate App (Android)"
      case_id = 461
      # ---------------------------------------------
      TestRailsTest.validator(@env_info, @client, suite, case_id, took_photo_validation.values.all?, message)
  end

end

When(/I open the menu "([^"]*)"/) do |os|
  case os
    when "iOS"
      @qr_page = QRPage.new(@ios_driver.driver)
      @qr_page.menu.click
    when "android"
      @qr_page = AndroidQRPage.new(@android_driver.driver)
      @qr_page.open_menu.click
  end
end

Then(/I verify there is no selfie "([^"]*)" "([^"]*)"/) do |num, os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      wait.until {@ios_driver.driver.find_element(:name => "photo").displayed?}
      @mobile_test_hash.merge!({num => (@ios_driver.driver.find_elements(:name => "photo").count == 1)})
    when "android"
      @edit_account = AndroidEditAccount.new(@android_driver.driver)
      @android_driver.driver.save_screenshot("test.png")
      image = MiniMagick::Image.open('test.png')
      image.crop "#{@edit_account.profile_pic.size.width}x#{@edit_account.profile_pic.size.height}+#{@edit_account.profile_pic.location.x}+#{@edit_account.profile_pic.location.y}"
      image.write 'test.png'
      @mobile_test_hash.merge!({num => (Phashion::Image.new("#{File.expand_path('.')}/lib/mobile/android/android_images/android_default_no_photo.png").duplicate?(Phashion::Image.new("#{File.expand_path('.')}/test.png")))})
  end

end

When(/I choose the menu item "([^"]*)" "([^"]*)"/) do |menu_item, os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      case menu_item
        when "edit profile"
          @ios_driver.driver.find_element(:name => "#{@email.downcase}").click
          wait.until {
            @edit_account = EditAccount.new(@ios_driver.driver)
            @edit_account.edit_account.displayed?}
        when "invite guest"
          @ios_driver.driver.find_element(:name => "Invite Guest").click
        when "settings"
          @ios_driver.driver.find_element(:name => "Settings").click
      end
    when "android"
      case menu_item
        when "edit profile"
          @menu = AndroidMenu.new(@android_driver.driver)
          @menu.edit_profile.click
        when "invite guest"
          @menu = AndroidMenu.new(@android_driver.driver)
          @menu.invite_guest.click
        when "settings"
          @menu = AndroidMenu.new(@android_driver.driver)
          @menu.settings.click
      end
  end


end

Then(/I verify that a selfie was never taken "([^"]*)"$/) do |os|
  case os
    when "iOS"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C453: Verify that I can press Cancel at any time before taking/choosing a photo to return to the application with the QR code displayed.
      # Criteria:
      # Selfie was cancelable
      message = "Could not cancel selfie"
      suite = "Real Estate App (iOS)"
      case_id = 453
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, @mobile_test_hash.values.all?, message)
    when "android"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C462: Verify that I can press Cancel at any time before taking/choosing a photo to return to the application with the QR code displayed.
      # Criteria:
      # Selfie was cancelable
      message = "Could not cancel selfie"
      suite = "Real Estate App (Android)"
      case_id = 462
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, @mobile_test_hash.values.all?, message)
  end
end

Then(/I verify a selfie was taken from the menu "([^"]*)"/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  selfie_taken_validation = {}
  case os
    when "iOS"
      wait.until {@ios_driver.driver.find_element(:name => "#{@email.downcase}")}
      @ios_driver.driver.manage.timeouts.implicit_wait = 2
      wait.until {@ios_driver.driver.find_elements(:name => "photo").count == 0}
      selfie_taken_validation.merge!({:selfie_taken => (@ios_driver.driver.find_elements(:name => "photo").count == 0)})
      @ios_driver.driver.manage.timeouts.implicit_wait = 300
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C456: When clicking on the avatar icon on the main menu, verify that I can click on the avatar icon in the Edit Account view to take a new selfie.
      # Criteria:
      # Seflie was taken
      message = "Selfie was not taken"
      suite = "Real Estate App (iOS)"
      case_id = 456
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, selfie_taken_validation.values.all?, message)
    when "android"
      wait.until {@edit_account = AndroidEditAccount.new(@android_driver.driver)}
      @android_driver.driver.save_screenshot("test.png")
      image = MiniMagick::Image.open('test.png')
      image.crop "#{@edit_account.profile_pic.size.width}x#{@edit_account.profile_pic.size.height}+#{@edit_account.profile_pic.location.x}+#{@edit_account.profile_pic.location.y}"
      image.write 'test.png'
      selfie_taken_validation.merge!({:photo_is_not_default => !(Phashion::Image.new("#{File.expand_path('.')}/lib/mobile/android/android_images/android_default_no_photo.png").duplicate?(Phashion::Image.new("#{File.expand_path('.')}/test.png")))})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C465: When clicking on the avatar icon on the main menu, verify that I can click on the avatar icon in the Edit Account view to take a new selfie.
      # Criteria:
      # Seflie was taken
      message = "Selfie was not taken"
      suite = "Real Estate App (Android)"
      case_id = 465
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, selfie_taken_validation.values.all?, message)
  end
end

When(/I tap "([^"]*)" button$/) do |button|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  case button
    when "take photo"
      @ios_driver.driver.find_element(:name => "button").click
    when "back to take photo"
      wait.until {@ios_driver.driver.find_element(:name => "Take a Selfie").displayed?}
      @ios_driver.driver.find_element(:name => "Take a Selfie").click
  end

end

Then(/I verify I can retake the photo/) do
  take_photo_back_button_validation = {}

  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  wait.until {@ios_driver.driver.find_element(:name => "button")}
  take_photo_back_button_validation.merge!({:take_photo_displayed => (@ios_driver.driver.find_element(:name => "button").displayed?) })
  take_photo_back_button_validation.merge!({:cancel_photo_displayed => (@ios_driver.driver.find_element(:name => "BACK").displayed?)})
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C457: After taking a photo, verify that you can choose to press back to retake it
  # Criteria:
  # Seflie was taken
  message = "Take photo back button didn't work"
  suite = "Real Estate App (iOS)"
  case_id = 457
  # ---------------------------------------------

  TestRailsTest.validator(@env_info, @client, suite, case_id, take_photo_back_button_validation.values.all?, message)
end

Then(/I verify a selfie was not taken and I am on the edit profile page/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until {@ios_driver.driver.find_element(:name => "#{@email.downcase}")}
  selfie_not_taken_validation = {}
  @ios_driver.driver.manage.timeouts.implicit_wait = 2
  selfie_not_taken_validation.merge!({:selfie_not_taken => (@ios_driver.driver.find_elements(:name => "photo").count == 1)})
  @ios_driver.driver.manage.timeouts.implicit_wait = 300
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C1563: When taking a picture from edit profile, pressing cancel returns user to profile view.
  # Criteria:
  # Seflie was taken
  message = "Canceling a photo from menu did not bring me back to menu"
  suite = "Real Estate App (iOS)"
  case_id = 1563
  # ---------------------------------------------

  TestRailsTest.validator(@env_info, @client, suite, case_id, selfie_not_taken_validation.values.all?, message)
end


Then(/I verify the error messages on invite guest "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  invite_guest_validation = {}
  case os
    when "iOS"
      @invite_guest = InviteGuest.new(@ios_driver.driver)
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:first_name_error => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid first name").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @invite_guest.first_name.send_keys @guest_first_name
      @invite_guest.keyboard_done(@ios_driver.driver).click
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:last_name_error => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid last name").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @invite_guest.last_name.send_keys @guest_last_name
      @invite_guest.keyboard_done(@ios_driver.driver).click
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:email_empty_error => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid email format").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @invite_guest.email.send_keys "erics"
      @invite_guest.keyboard_done(@ios_driver.driver).click
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:email_format_error_1 => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid email format").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @invite_guest.email.clear
      @invite_guest.email.send_keys "erics@"
      @invite_guest.keyboard_done(@ios_driver.driver).click
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:email_format_error_2 => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid email format").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @invite_guest.email.clear
      @invite_guest.email.send_keys "erics@eric.com"
      @invite_guest.keyboard_done(@ios_driver.driver).click
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:phone_format_error => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid phone number").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @invite_guest.mobile.send_keys "1234"
      @invite_guest.keyboard_done(@ios_driver.driver).click
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:phone_format_error_2 => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid phone number").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @invite_guest.mobile.send_keys "56789123"
      @invite_guest.keyboard_done(@ios_driver.driver).click
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:phone_format_error_3 => (@ios_driver.driver.find_element(:name => "Error").displayed?) && (@ios_driver.driver.find_element(:name => "Invalid phone number").displayed?)})
      @ios_driver.driver.find_element(:name => "OK").click
      @invite_guest.mobile.clear
      @invite_guest.mobile.send_keys @guest_mobile
      @invite_guest.keyboard_done(@ios_driver.driver).click
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:invitation_sent => (@ios_driver.driver.find_element(:name => "Invitation sent!").displayed?) && (@ios_driver.driver.find_element(:name => "View invitations").displayed?)})

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C58: On the invite Guests view, verify that when the button 'Send Invitation' is pressed, an error message appears for each field until all fields have valid data (details inside).
      # Criteria:
      # Seflie was taken
      message = "Errors on invite guest page were not as expected"
      suite = "Real Estate App (iOS)"
      case_id = 58
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, invite_guest_validation.values.all?, message)
    when "android"
      @invite_guest = AndroidInviteGuest.new(@android_driver.driver)
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:first_name_error => (@invite_guest.error_message(@android_driver.driver).text.include? "Invalid first name")})
      @invite_guest.close_error(@android_driver.driver).click
      @invite_guest = AndroidInviteGuest.new(@android_driver.driver)
      @invite_guest.first_name.send_keys @guest_first_name
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:last_name_error => (@invite_guest.error_message(@android_driver.driver).text.include? "Invalid last name")})
      @invite_guest.close_error(@android_driver.driver).click
      @invite_guest = AndroidInviteGuest.new(@android_driver.driver)
      @invite_guest.last_name.send_keys @guest_last_name
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:email_empty_error => (@invite_guest.error_message(@android_driver.driver).text.include? "Invalid email format")})
      @invite_guest.close_error(@android_driver.driver).click
      @invite_guest = AndroidInviteGuest.new(@android_driver.driver)
      @invite_guest.email.send_keys "erics"
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:email_format_error_1 => (@invite_guest.error_message(@android_driver.driver).text.include? "Invalid email format")})
      @invite_guest.close_error(@android_driver.driver).click
      @invite_guest = AndroidInviteGuest.new(@android_driver.driver)
      @invite_guest.email.clear
      @invite_guest.email.send_keys "erics@"
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:email_format_error_2 => (@invite_guest.error_message(@android_driver.driver).text.include? "Invalid email format")})
      @invite_guest.close_error(@android_driver.driver).click
      @invite_guest = AndroidInviteGuest.new(@android_driver.driver)
      @invite_guest.email.clear
      @invite_guest.email.send_keys "erics@eric.com"
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:phone_format_error => (@invite_guest.error_message(@android_driver.driver).text.include? "Invalid phone number")})
      @invite_guest.close_error(@android_driver.driver).click
      @invite_guest = AndroidInviteGuest.new(@android_driver.driver)
      @invite_guest.mobile.clear
      @invite_guest.mobile.send_keys "1234"
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:phone_format_error_2 => (@invite_guest.error_message(@android_driver.driver).text.include? "Invalid phone number")})
      @invite_guest.close_error(@android_driver.driver).click
      @invite_guest = AndroidInviteGuest.new(@android_driver.driver)
      @invite_guest.mobile.clear
      @invite_guest.mobile.send_keys "56789123"
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:phone_format_error_3 => (@invite_guest.error_message(@android_driver.driver).text.include? "Invalid phone number")})
      @invite_guest.close_error(@android_driver.driver).click
      @invite_guest = AndroidInviteGuest.new(@android_driver.driver)
      @invite_guest.mobile.clear
      @invite_guest.mobile.send_keys @guest_mobile
      @invite_guest.send_inv.click
      invite_guest_validation.merge!({:invitation_sent => (@invite_guest.invitation_sent(@android_driver.driver).text.include? "Invitation sent!")})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C38: On the invite Guests view, verify that the pressing 'Send Invitation' with invalid/empty data triggers an error dialogue detailing each appropriate missing/invalid field.
      # Criteria:
      # Seflie was taken
      message = "Errors on invite guest page were not as expected"
      suite = "Real Estate App (Android)"
      case_id = 38
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, invite_guest_validation.values.all?, message)
  end

end

When(/I invite a guest "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      @invite_guest = InviteGuest.new(@ios_driver.driver)
      @invite_guest.first_name.send_keys @guest_first_name
      @invite_guest.last_name.send_keys @guest_last_name
      @invite_guest.email.send_keys @guest_email
      @invite_guest.mobile.send_keys @guest_mobile
      @invite_guest.keyboard_done(@ios_driver.driver).click
      @invite_guest.send_inv.click
      @view_invitations = @ios_driver.driver.find_element(:name => "View invitations").displayed?
      @ios_driver.driver.find_element(:name => "View invitations").click
    when "android"
      @invite_guest = AndroidInviteGuest.new(@android_driver.driver)
      @invite_guest.first_name.send_keys @guest_first_name
      @invite_guest.last_name.send_keys @guest_last_name
      @invite_guest.email.send_keys @guest_email
      @invite_guest.mobile.send_keys @guest_mobile
      @invite_guest.send_inv.click
      wait.until {@view_invitations = @invite_guest.invitation_sent(@android_driver.driver).text.include? "Invitation sent!"}
      @invite_guest.close_invite_dialog(@android_driver.driver).click
  end

end

When(/I invite a guest "([^"]*)" and wait$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      @invite_guest = InviteGuest.new(@ios_driver.driver)
      @invite_guest.first_name.send_keys @guest_first_name
      @invite_guest.last_name.send_keys @guest_last_name
      @invite_guest.email.send_keys @guest_email
      @invite_guest.mobile.send_keys @guest_mobile
      @invite_guest.keyboard_done(@ios_driver.driver).click
      @invite_guest.send_inv.click
      @view_invitations = @ios_driver.driver.find_element(:name => "View invitations").displayed?
      sleep(10)
    when "android"
      @invite_guest = AndroidInviteGuest.new(@android_driver.driver)
      @invite_guest.first_name.send_keys @guest_first_name
      @invite_guest.last_name.send_keys @guest_last_name
      @invite_guest.email.send_keys @guest_email
      @invite_guest.mobile.send_keys @guest_mobile
      @invite_guest.send_inv.click
      wait.until {@view_invitations = @invite_guest.invitation_sent(@android_driver.driver).text.include? "Invitation sent!"}
  end

end

Then(/I verify the invite is visible in "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  invite_active_valdiation = {}
  case os
    when "iOS"
      wait.until {@ios_driver.driver.find_element(:name => "#{@guest_first_name} #{@guest_last_name}").displayed?}

      invite_active_valdiation.merge!({:active_invite => (@ios_driver.driver.find_element(:name => "#{@guest_first_name} #{@guest_last_name}"))})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C59: After clicking 'Send invitation' verify that the invite is visible in the Active section of Guests view.
      # Criteria:
      #
      message = "Guest invite is active"
      suite = "Real Estate App (iOS)"
      case_id = 59
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, invite_active_valdiation.values.all?, message)
    when "android"
      @my_guests = AndroidMyGuests.new(@android_driver.driver)
      @my_guests.guest_list[0].text.include? @guest_first_name
      invite_active_valdiation.merge!({:active_invite => (@my_guests.guest_list[0].text.include? @guest_first_name) && (@my_guests.guest_list[0].text.include? @guest_last_name)})

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C39: After clicking 'Send invitation' verify that the invite is visible with the status 'sent' in My Guests view.
      # Criteria:
      #
      message = "Guest invite is active"
      suite = "Real Estate App (Android)"
      case_id = 39
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, invite_active_valdiation.values.all?, message)
  end

end

When(/I verify I can invite the same guest "([^"]*)" times "([^"]*)"$/) do |num, os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  many_guest_invites_validation = {}
  case os
    when "iOS"
      @invite_guest = InviteGuest.new(@ios_driver.driver)
      @invite_guest.first_name.send_keys @guest_first_name
      @invite_guest.last_name.send_keys @guest_last_name
      @invite_guest.email.send_keys @guest_email
      @invite_guest.mobile.send_keys @guest_mobile
      @invite_guest.keyboard_done(@ios_driver.driver).click
      @num = num.to_i
      num.to_i.times { |num|
        @invite_guest.send_inv.click
        @ios_driver.driver.find_element(:name => "View invitations").click
        wait.until {@ios_driver.driver.find_element(:name => "Invite Guest").displayed?}
        @ios_driver.driver.find_element(:name => "Invite Guest").click unless num == @num - 1
      }
      many_guest_invites_validation.merge!({:guest_invite_count => ( @ios_driver.driver.find_elements(:name => "#{@guest_first_name} #{@guest_last_name}").count == @num)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C4783: Verify that a guest can be invited any number of times whether they have been accepted or rejected.
      # Criteria:
      #
      message = "Guest cannot be invited any number of times"
      suite = "Real Estate App (iOS)"
      case_id = 4783
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, many_guest_invites_validation.values.all?, message)
    when "android"
      @num = num.to_i
      num.to_i.times { |num|
        @invite_guest = AndroidInviteGuest.new(@android_driver.driver)
        @invite_guest.first_name.send_keys @guest_first_name
        @invite_guest.last_name.send_keys @guest_last_name
        @invite_guest.email.send_keys @guest_email
        @invite_guest.mobile.send_keys @guest_mobile
        @invite_guest.send_inv.click
        wait.until {@invite_guest.invitation_sent(@android_driver.driver).text.include? "Invitation sent!"}
        @invite_guest.close_invite_dialog(@android_driver.driver).click
        @my_guests = AndroidMyGuests.new(@android_driver.driver)
        unless num == @num - 1
          @my_guests.back_button.click
          begin
            retries ||= 0
            wait.until {@qr_page = AndroidQRPage.new(@android_driver.driver)}
            @qr_page.open_menu.click
          rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
            retry if (retries += 1) < 3
          end
          @menu = AndroidMenu.new(@android_driver.driver)
          @menu.invite_guest.click
        end
      }
      @my_guests = AndroidMyGuests.new(@android_driver.driver)
      @my_guests.guest_list.count.times {|num|
        many_guest_invites_validation.merge!({num => (@my_guests.guest_list[num].text.include? @guest_first_name)})
      }
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C4784: Verify that a guest can be invited any number of times whether they have been accepted or rejected.
      # Criteria:
      #
      message = "Guest cannot be invited any number of times"
      suite = "Real Estate App (Android)"
      case_id = 4784
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, many_guest_invites_validation.values.all?, message)
  end

end

Then(/I verify the guest invitation is listed as accepted "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  approved_guest_validation = {}
  case os
    when "iOS"
      @ios_driver.driver.find_element(:name => "Invite Guest").click
      wait.until {@ios_driver.driver.find_element(:name => "Open Door").displayed?}
      @ios_driver.driver.find_element(:name => "Open Door").click
      @ios_driver.driver.find_element(:name => "MenuHamburger").click
      @ios_driver.driver.find_element(:name => "My Guests").click

      approved_guest_validation.merge!({:guest_approved => (@ios_driver.driver.find_element(:name => "Approved").displayed?)})

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C61: If the Tenant Admin accepts the guest invitation, verify that the invite is visible in the Accepted section of the Guests view.
      # Criteria:
      #
      message = "Guest was not approved by Tenant Admin"
      suite = "Real Estate App (iOS)"
      case_id = 61
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, approved_guest_validation.values.all?, message)
    when "android"
      @my_guests = AndroidMyGuests.new(@android_driver.driver)
      @my_guests.back_button.click
      begin
        retries ||= 0
        wait.until {@qr_page = AndroidQRPage.new(@android_driver.driver)}
        @qr_page.open_menu.click
      rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
        retry if (retries += 1) < 3
      end
      @menu = AndroidMenu.new(@android_driver.driver)
      @menu.my_guests.click
      @my_guests = AndroidMyGuests.new(@android_driver.driver)
      approved_guest_validation.merge!({:guest_approved => (@my_guests.status[0].text.include? "Approved")})

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C41: If the Tenant Admin accepts the guest invitation, verify that the invite is visible in the Accepted section of the Guests view.
      # Criteria:
      #
      message = "Guest was not approved by Tenant Admin"
      suite = "Real Estate App (Android)"
      case_id = 41
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, approved_guest_validation.values.all?, message)
  end
end

Then(/I verify the guest invitation is listed as rejected "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  rejected_guest_validation = {}
  case os
    when "iOS"
      @ios_driver.driver.find_element(:name => "Invite Guest").click
      wait.until {@ios_driver.driver.find_element(:name => "Open Door").displayed?}
      @ios_driver.driver.find_element(:name => "Open Door").click
      @ios_driver.driver.find_element(:name => "MenuHamburger").click
      @ios_driver.driver.find_element(:name => "My Guests").click

      rejected_guest_validation.merge!({:guest_rejected => (@ios_driver.driver.find_element(:name => "Rejected by admin").displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C14097: If the Tenant Admin rejects the guest invitation, verify that invite status is set to Rejected by admin in My Guests view.
      # Criteria:
      #
      message = "Guest was not rejected by Tenant Admin"
      suite = "Real Estate App (iOS)"
      case_id = 14097
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, rejected_guest_validation.values.all?, message)
    when "android"
      @my_guests = AndroidMyGuests.new(@android_driver.driver)
      @my_guests.back_button.click
      begin
        retries ||= 0
        wait.until {@qr_page = AndroidQRPage.new(@android_driver.driver)}
        @qr_page.open_menu.click
      rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
        retry if (retries += 1) < 3
      end
      @menu = AndroidMenu.new(@android_driver.driver)
      @menu.my_guests.click
      @my_guests = AndroidMyGuests.new(@android_driver.driver)
      rejected_guest_validation.merge!({:guests_rejected => (@my_guests.status[0].text.include? "Rejected")})

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C40: If the Tenant Admin rejects the guest invitation, verify that invite status is set to Rejected by admin in My Guests view.
      # Criteria:
      #
      message = "Guest was not rejected by Tenant Admin"
      suite = "Real Estate App (Android)"
      case_id = 40
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, rejected_guest_validation.values.all?, message)
  end
end

Then(/I verify the guest received a welcome email "([^"]*)"$/) do |os|
  response = Automato::MailinatorHelper.getInbox(@guest_email)
  email = Automato::MailinatorHelper.get_individual_email(response['messages'][0]['id'])
  user_receives_email = email['data']['subject'].include? "Invitation to Eric's Test Tenant"
  case os
    when "iOS"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C62: Once a Tenant Admin accepts the guest invitation, verify that an email is sent to the guest account.
      # Criteria:
      #
      message = "The email was not sent to the guest account"
      suite = "Real Estate App (iOS)"
      case_id = 62
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, user_receives_email, message)
    when "android"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C42: Once a Tenant Admin accepts the guest invitation, verify that an email is sent to the guest account.
      # Criteria:
      #
      message = "The email was not sent to the guest account"
      suite = "Real Estate App (Android)"
      case_id = 42
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, user_receives_email, message)
  end

end

When(/I set the guest password/) do
    response = Automato::MailinatorHelper.getInbox(@guest_email)
    email = Automato::MailinatorHelper.get_individual_email(response['messages'][0]['id'])
    delete = Automato::MailinatorHelper.delete_email(response['messages'][0]['id'])
    parsed_body = Nokogiri::HTML(email['data']['parts'][0]['body'])

    sign_up_link = parsed_body.search('a')[1].to_h['href']

    @browser.goto sign_up_link


    @admin_ui.sign_up_password.send_keys @env['password']
    @admin_ui.sign_up_button.click

    Watir::Wait.until{ @browser.url == "https://qa.realestate.waltzapp.com/#/set-password/success"}
    Watir::Wait.until{@browser.element(:css => ".box.box-password").visible?}
end

When(/I go back to the qr page from "([^"]*)" "([^"]*)"$/) do |page, os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      case page
        when "My Guests"
          @ios_driver.driver.find_element(:name => "Invite Guest").click
          wait.until {@ios_driver.driver.find_element(:name => "Open Door").displayed?}
          @ios_driver.driver.find_element(:name => "Open Door").click
      end
    when "android"
      case page
        when "My Guests"
          @my_guests = AndroidMyGuests.new(@android_driver.driver)
          @my_guests.back_button.click
      end
  end
end

Then(/I verify I am logged in as guest "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  guest_log_in_validation = {}
  case os
    when "iOS"
      guest_log_in_validation.merge!({:qr_visible => (@ios_driver.driver.find_element(:name => "transaction").displayed?)})
      guest_log_in_validation.merge!({:user_message => (@ios_driver.driver.find_element(:name => "Please hold your phone about 1 to 2 feet away from the terminal").displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C64: Verify the guest can log in to the app with their email and password.
      # Criteria:
      #
      message = "The guest could not log in with their email and password"
      suite = "Real Estate App (iOS)"
      case_id = 64
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, guest_log_in_validation.values.all?, message)
    when "android"
      begin
        retries ||= 0
        wait.until {@qr_page = AndroidQRPage.new(@android_driver.driver)}
      rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
        retry if (retries += 1) < 3
      end
      guest_log_in_validation.merge!({:user_message => @qr_page.user_message.displayed?})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C44: Verify the guest can log in to the app with their email and password.
      # Criteria:
      #
      message = "The guest could not log in with their email and password"
      suite = "Real Estate App (Android)"
      case_id = 44
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, guest_log_in_validation.values.all?, message)
  end

end

Then(/I verify there was a pop up to see invitations "([^"]*)"$/) do |os|
  send_invitation_validation = {}
  case os
    when "iOS"
      send_invitation_validation.merge!({:pop_up_visible => @view_invitations})

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C2701: After clicking 'Send Invitation' verify that a dialogue appears allowing user to navigate to their 'My Guests' view.
      # Criteria:
      #
      message = "The pop up was not displayed"
      suite = "Real Estate App (iOS)"
      case_id = 2701
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, send_invitation_validation.values.all?, message)
    when "android"
      send_invitation_validation.merge!({:pop_up_visible => @view_invitations})

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C2703: After clicking 'Send Invitation' verify that a dialogue appears allowing user to navigate to their 'My Guests' view.
      # Criteria:
      #
      message = "The pop up was not displayed"
      suite = "Real Estate App (Android)"
      case_id = 2703
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, send_invitation_validation.values.all?, message)
  end

end

Then(/I verify the error messages on the change password page/) do
  binding.pry
  puts "hello"
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until {
    @change_password = ChangePassword.new(@ios_driver.driver)
  }
  @change_password.save.click
  error_validation = {}
  error_validation.merge!({:fields_empty => (@ios_driver.driver.find_element(:name => "Backend error response").displayed?)})
  error_validation.merge!({:fields_empty_2 => (@ios_driver.driver.find_element(:name => "OK").displayed?)})
  @ios_driver.driver.find_element(:name => "OK").click
  @change_password.password.send_keys @env['password']
  @change_password.save.click
  error_validation.merge!({:password => (@ios_driver.driver.find_element(:name => "Backend error response").displayed?)})
  error_validation.merge!({:password_2 => (@ios_driver.driver.find_element(:name => "OK").displayed?)})
  @ios_driver.driver.find_element(:name => "OK").click
  @change_password.new_password.send_keys @env['password2']
  @change_password.save.click
  error_validation.merge!({:new_password => (@ios_driver.driver.find_element(:name => "Backend error response").displayed?)})
  error_validation.merge!({:new_password_2 => (@ios_driver.driver.find_element(:name => "OK").displayed?)})
  @ios_driver.driver.find_element(:name => "OK").click
  binding.pry
  puts  "hello"
end

Then(/I verify the easter egg exists/) do
  easter_egg_exists = {}
  @easter_egg = EasterEgg.new(@ios_driver.driver)
  easter_egg_exists.merge!({:easter_egg_exists => (@easter_egg.qa_env.displayed?)})
  easter_egg_exists.merge!({:easter_egg_exists_2 => (@easter_egg.left_arrow.displayed?)})
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C89: Verify that the easter egg is enabled in QA environment/builds (click 6 times on center of main screen).
  # Criteria:
  #
  message = "The easter egg did not exist"
  suite = "Real Estate App (iOS)"
  case_id = 89
  # ---------------------------------------------

  TestRailsTest.validator(@env_info, @client, suite, case_id, easter_egg_exists.values.all?, message)
end

Then(/I verify there is a version number/) do
  version_number_validation = {}
  version_number_validation.merge!({:text => (@ios_driver.driver.find_elements(:class_name => "XCUIElementTypeStaticText")[0].text.include? "7.1")})
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C110: Verify that the version number appears at the bottom of the splash screen.
  # Criteria:
  #
  message = "The version number didn't exist"
  suite = "Real Estate App (iOS)"
  case_id = 110
  # ---------------------------------------------

  TestRailsTest.validator(@env_info, @client, suite, case_id, version_number_validation.values.all?, message)
end

Then(/I verify I am on the guest view/) do
  guest_view_validation = {}
  guest_view_validation.merge!({:guest_view =>  (@ios_driver.driver.find_element(:name => "Sent").displayed?)})
  guest_view_validation.merge!({:guest_view_2 => (@ios_driver.driver.find_element(:name => "My Guests").displayed?)})
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C191: Verify that after the guest invite is sent and the 'view invitation' button is pressed, user is returned to the Guest view.
  # Criteria:
  #
  message = "The version number didn't exist"
  suite = "Real Estate App (iOS)"
  case_id = 191
  # ---------------------------------------------

  TestRailsTest.validator(@env_info, @client, suite, case_id, guest_view_validation.values.all?, message)
end

Then(/I verify after 10 seconds I am on the guest view "([^"]*)"/) do |os|
  guest_view_validation = {}
  case os
    when "iOS"
      guest_view_validation.merge!({:guest_view =>  (@ios_driver.driver.find_element(:name => "Sent").displayed?)})
      guest_view_validation.merge!({:guest_view_2 => (@ios_driver.driver.find_element(:name => "My Guests").displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C2702: Verify that the post invitation dialogue dismisses itself after 10 seconds.
      # Criteria: Guest view is automatically shown after 10 seconds
      #
      message = "Guest view not shown after 10 seconds"
      suite = "Real Estate App (iOS)"
      case_id = 2702
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, guest_view_validation.values.all?, message)
    when "android"
      @my_guests = AndroidMyGuests.new(@android_driver.driver)
      guest_view_validation.merge!({:guest_view => (@my_guests.guest_list.count > 0)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C2704: Verify that the post invitation dialogue dismisses itself after 10 seconds.
      # Criteria: Guest view is automatically shown after 10 seconds
      #
      message = "Guest view not shown after 10 seconds"
      suite = "Real Estate App (Android)"
      case_id = 2704
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, guest_view_validation.values.all?, message)
  end

end

When(/From the settings menu I choose "([^"]*)" "([^"]*)"$/) do |option, os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      case option
        when "guest"
          wait.until { @ios_driver.driver.find_element(:name => "Guest").displayed?}
          @ios_driver.driver.find_element(:name => "Guest").click
      end
    when "android"
      case option
        when "guest"
          @settings = AndroidSettings.new(@android_driver.driver)
          @settings.guest.click
      end
  end


end

Then(/I verify I can toggle the contact person "([^"]*)"/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  guest_contact_validation = {}
  case os
    when "iOS"
      wait.until {@ios_driver.driver.find_element(:name => "Select contact person").displayed?}
      @ios_driver.driver.find_element(:name => "Select contact person").click
      wait.until {@ios_driver.driver.find_element(:name => "Search").displayed?}
      @ios_driver.driver.find_element(:name => "Search").send_keys "Adela71424 Cummerata"
      wait.until {@ios_driver.driver.find_element(:name => "Adela71424 Cummerata").displayed?}
      @ios_driver.driver.find_element(:name => "Adela71424 Cummerata").click
      wait.until {@ios_driver.driver.find_element(:name => "adela71424.cummerata724@mailinator.com").displayed?}

      guest_contact_validation.merge!({:can_change_contact => (@ios_driver.driver.find_element(:name => "adela71424.cummerata724@mailinator.com").displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C2713: For invited Guests, verify that the contact person can be toggled from 'me' to someone else in the same organization.
      # Criteria: Can change contact name
      #
      message = "Could not change contact person"
      suite = "Real Estate App (iOS)"
      case_id = 2713
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, guest_contact_validation.values.all?, message)
    when "android"
      @settings_guest = AndroidSettingsGuest.new(@android_driver.driver)
      @settings_guest.select_contact.click
      @select_contact = AndroidSelectContact.new(@android_driver.driver)
      @select_contact.contacts.click
      @settings_guest = AndroidSettingsGuest.new(@android_driver.driver)
      guest_contact_validation.merge!({:can_change_contact => (@settings_guest.select_contact.text == "adela71424.cummerata724@mailinator.com")})

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C2728: For invited Guests, verify that the contact person can be toggled from 'me' to someone else in the same organization.
      # Criteria: Can change contact name
      #
      message = "Could not change contact person"
      suite = "Real Estate App (Android)"
      case_id = 2728
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, guest_contact_validation.values.all?, message)

  end

end



When(/I choose "([^"]*)" on the edit profile page "([^"]*)"$/) do |option, os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      case option
        when "change password"
          @edit_account.change_password.click
        when "take selfie"
          wait.until {@ios_driver.driver.find_element(:name => "photo").displayed?}
          @ios_driver.driver.find_element(:name => "photo").click
      end
    when "android"
      case option
        when "change password"
          @edit_account = AndroidEditAccount.new(@android_driver.driver)
          @edit_account.edit_password.click
        when "take selfie"
          @edit_account = AndroidEditAccount.new(@android_driver.driver)
          @edit_account.profile_pic.click
      end
  end
end

When(/I input a new password "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      wait.until {
        @change_password = ChangePassword.new(@ios_driver.driver)
      }
      @change_password.password.send_keys @env['password']
      @change_password.new_password.send_keys @env['password2']
      @change_password.confirm.send_keys @env['password2']
      @change_password.save.click

      wait.until {
        @change_password.password_updated(@ios_driver.driver)
      }
      @change_password.edit_profile.click
    when "android"
      @change_password = AndroidChangePassword.new(@android_driver.driver)
      @change_password.old_pass.send_keys @env['password']
      @change_password.new_pass.send_keys @env['password2']
      @change_password.confirm_pass.send_keys @env['password2']
      @change_password.save_pass.click
      @password_updated = @change_password.password_updated(@android_driver.driver)
      @change_password.close_update_popup(@android_driver.driver)
      @change_password = AndroidChangePassword.new(@android_driver.driver)
      @change_password.back.click
  end
end

When(/I make a transaction with the terminal/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  @env_info.merge!({:base_uri => "https://re-qa.waltzlabs.com", :user => "tenant_admin"})
  @pem = nil
  # @headers = @account_service.headers
  response = HTTParty.post(@env_info[:base_uri]+@env['API']['services']['account']['auth']['sign-in'],
                           :body => {
                               email: @env['auth']['qa'][@env_info[:user]],
                               password: @env['password']
                           })
  @key = response['roles'][0]['key']
  @token = response['token']
  AMQPHelper.new.unlock_terminal(@env)
  FirePoll.poll("Wait for entries to update", 30) do
    entry = HTTParty.get(@env_info[:base_uri]+ @env['API']['services']['ledger']['entries']['list-search'].gsub('roleKey', @key),
                         :headers => APIHeaderBuilder.new.get_header(@token),
                         :pem => @pem)
    @entry_info = JSON.parse(entry.body)
    @first_name == @entry_info['data'][0]['userFirstName']
  end
  AMQPHelper.new.lock_terminal(@env)
  @entry = @entry_info['data'].select {|entry| entry['userFirstName'] == @first_name}
end