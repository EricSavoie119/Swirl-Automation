When(/I open the menu and choose "([^"]*)" "([^"]*)"/) do |option, os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      @qr_page = QRPage.new(@ios_driver.driver)
      @qr_page.menu.click
      wait.until {@qr_page.invite_guest.displayed?}
      case option.downcase
        when "settings"
          @qr_page.settings.click
        when "invite guest"
          @qr_page.invite_guest.click
        when "edit profile"
          @ios_driver.driver.find_element(:name => "#{@email.downcase}").click
          wait.until {
            @edit_account = EditAccount.new(@ios_driver.driver)
            @edit_account.edit_account.displayed?}
        when "my invitations"
          @qr_page.my_invites.click
      end
      @poll_time = Time.now.to_i - 5
    when "android"
      @qr_page = AndroidQRPage.new(@android_driver.driver)
      @qr_page.open_menu.click
      @menu = AndroidMenu.new(@android_driver.driver)
      case option.downcase
        when "settings"
          @menu.settings.click
        when "invite guest"
          @menu.invite_guest.click
        when "edit profile"
          @menu.edit_profile.click
        when "my invitations"
          @menu.my_invitations.click
      end

  end

end

When(/I go back to the main page from "([^"]*)" "([^"]*)"/) do |page, os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case os
    when "iOS"
      case page
        when "edit profile"
          @edit_account.open_door.click
      end
    when "android"
      case page
        when "edit profile"
          @edit_account = AndroidEditAccount.new(@android_driver.driver)
          @edit_account.back.click
          wait.until {@edit_account.element_gone(@android_driver.driver, :id, "com.waltzapp.android.access.debug:id/edit_user_password")}
      end
  end
end

Then(/I log back in to verify the password change "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  password_change_validation = {}
  case os
    when "iOS"
      wait.until {@welcome_page.log_in.displayed?}
      @welcome_page.log_in.click
      begin
        @login_page = LoginPage.new(@ios_driver.driver)
      rescue Exception => e
        puts "Likely you're loading the wrong page: " + e.message
      end
      @login_page.username.clear
      @login_page.username.send_keys @email
      @login_page.password.send_keys @env['password2']
      @login_page.log_in.click
      wait.until {@qr_page = QRPage.new(@ios_driver.driver)}

      password_change_validation.merge!({:password_changed => (@qr_page.user_message.displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C2706: In the edit profile page, verify that the user's password can be successfully changed and used to log in to the app.
      # Criteria:
      # Password can be changed and used to log in
      # Suite Real Estate App (iOS)
      # ---------------------------------------------

      TestRailsTest.check_2706(@env_info, @client, password_change_validation)
    when "android"
      @welcome_page = AndroidWelcomePage.new(@android_driver.driver)
      @welcome_page.log_in.click
      begin
        @login_page = AndroidLoginPage.new(@android_driver.driver)
      rescue Exception => e
        puts e.message
      end
      @login_page.username.clear
      @login_page.username.send_keys @email
      @login_page.password.send_keys @env['password2']
      @login_page.log_in(@android_driver.driver).click
      wait.until {@qr_page = AndroidQRPage.new(@android_driver.driver)}

      password_change_validation.merge!({:password_change => (@qr_page.user_message.displayed?)})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C2705: In the edit profile page, verify that the user's password can be successfully changed and used to log in to the app.
      # Criteria:
      #
      message = "The password did not work"
      suite = "Real Estate App (Android)"
      case_id = 2705
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, password_change_validation.values.all?, message)
  end


end

When(/I input the guest information/) do
  @guest_fname = Faker::Name.first_name
  @guest_lname = Faker::Name.last_name

  @guest_email = "#{@guest_fname}.#{@guest_lname}#{Faker::Number.number(3)}@mailinator.com"
  @guest_mobile = "000-#{Faker::Number.number(3)}-#{Faker::Number.number(4)}"
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until { @invite_guest = InviteGuest.new(@ios_driver.driver)}
  @invite_guest.first_name.send_keys @guest_fname
  @invite_guest.last_name.send_keys @guest_lname
  @invite_guest.email.send_keys @guest_email
  @invite_guest.mobile.send_keys @guest_mobile
  @invite_guest.keyboard_done(@ios_driver.driver).click
end

When(/I send the invite/) do
  @invite_guest.send_inv.click
  fail "Invitation pop up not present" unless @invite_guest.invitation_sent(@ios_driver.driver)
end

When(/I input the "([^"]*)" as guest/) do |role|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until {@invite_guest = InviteGuest.new(@ios_driver.driver)}
  @invite_guest.first_name.send_keys @user_hash[role.to_sym][:first_name]
  @invite_guest.last_name.send_keys @user_hash[role.to_sym][:last_name]
  @invite_guest.email.send_keys @user_hash[role.to_sym][:email]
  @invite_guest.mobile.send_keys @user_hash[role.to_sym][:mobile]
  @invite_guest.keyboard_done(@ios_driver.driver).click
end

Then(/I verify I have an invite from "([^"]*)"/) do |role|
  case role
    when "tenant admin"
      fail "Active Invite was not as expected" unless MyInvites.new.active_invites(@env_info, @ios_driver.driver)
  end
end

