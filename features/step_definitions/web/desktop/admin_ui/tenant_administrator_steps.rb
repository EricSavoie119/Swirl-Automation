

Then(/I should see the support info "([^"]*)"/) do |role|

  support_tab_has_info = @admin_ui.support_info.text.include? "FAQ\nhttps://waltzapp.zendesk.com/hc/en-us\nSupport Number 888-541-3958\nManagement Console Version"
  case role
    when "employee"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C93: Verify the Support tab opens a view with support info.
      # Criteria:
      # Verify the support tab has info
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_93(@env_info, @client, support_tab_has_info)
    when "installer"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C138: Verify the Support tab opens a view with support info.
      # Criteria:
      # Verify the support tab has info
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_138(@env_info, @client, support_tab_has_info)
    when "pma"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C153: Verify the Support tab opens a view with support info.
      # Criteria:
      # Verify the support tab has info
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_153(@env_info, @client, support_tab_has_info)
    when "tenant admin"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C166: Verify the Support tab opens a view with support info.
      # Criteria:
      # Verify the support tab has info
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_166(@env_info, @client, support_tab_has_info)
  end


end

When(/I edit my password to "([^"]*)"/) do |password|
  @admin_ui.role_change.click
  @admin_ui.profile.click
  @admin_ui.edit.click
  @admin_ui.password.send_keys @env[password]
  sleep(0.5)
  @admin_ui.edit_save.click
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until {
    @admin_ui.loading.wait_until_present
    @admin_ui.loading.wait_while_present
    @admin_ui.modal.visible? }
end

Then(/I test logging in with my new password "([^"]*)"/) do |role|
  case role
    when "employee"
      @admin_ui.email.send_keys @env['auth']['qa'][role]
      @admin_ui.password.send_keys @env['password2']
    when "installer"
      @admin_ui.email.send_keys @env['auth']['qa'][role]
      @admin_ui.password.send_keys @env['password2']
    when "pma"
      @admin_ui.email.send_keys @env['auth']['qa'][role]
      @admin_ui.password.send_keys @env['password2']
    when "tenant admin"
      @admin_ui.email.send_keys @env['auth']['qa'][@user]
      @admin_ui.password.send_keys @env['password2']
  end

  @admin_ui.sign_in.click


  password_change_worked = @admin_ui.profile_info.wait_until_present

  case role
    when "employee"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C99: Verify that Employee can edit their profile and change their password.
      # Criteria:
      # A PMA can change their password
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_99(@env_info, @client, password_change_worked)

      new_password_login = @admin_ui.top_bar_text.text.include? "My Profile"

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C100: Verify that after changing profile password they can log in with the new password.
      # Criteria:
      # A PMA can log in with their changed password
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_100(@env_info, @client, new_password_login)
    when "installer"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C140: Verify that Employee can edit their profile and change their password.
      # Criteria:
      # A PMA can change their password
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_140(@env_info, @client, password_change_worked)

      new_password_login = @admin_ui.top_bar_text.text.include? "My Profile"

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C141: Verify that after changing profile password they can log in with the new password.
      # Criteria:
      # A PMA can log in with their changed password
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_141(@env_info, @client, new_password_login)
    when "pma"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C155: Verify that PMA can edit their profile and change their password
      # Criteria:
      # A PMA can change their password
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_155(@env_info, @client, password_change_worked)

      new_password_login = @admin_ui.top_bar_text.text.include? "Eric Savoie"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C156: Verify that after changing profile password they can log in with the new password.
      # Criteria:
      # A PMA can log in with their changed password
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_156(@env_info, @client, new_password_login)

    when "tenant admin"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C168: Verify that TA can edit their profile and change their password
      # Criteria:
      # A TA can change their password
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_168(@env_info, @client, password_change_worked)

      new_password_login = @admin_ui.top_bar_text.text.include? "Eric's Test Tenant"

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C169: Verify that after changing profile password they can log in with the new password.
      # Criteria:
      # A TA can log in with their changed password
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_169(@env_info, @client, new_password_login)
  end

end

And(/I edit some fields/) do
  @email = @admin_ui.email.value
  @mobile= @admin_ui.mobile.value
  @admin_ui.email.to_subtype.clear
  @admin_ui.mobile.to_subtype.clear
  fail "Field didn't clear" unless @admin_ui.email.value == ""
  fail "Field didn't clear" unless @admin_ui.mobile.value == ""
end

Then(/I press the reset button "([^"]*)"/) do |role|
  @admin_ui.reset.click
  email_reset =  @admin_ui.email.value == @email
  mobile_reset =  @admin_ui.mobile.value == @mobile
  case role
    when "employee"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C101: Verify that pressing Reset on the edit profile view returns the fields to their default state.
      # Criteria:
      # The reset buttons resets fields
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_101(@env_info, @client, email_reset, mobile_reset)
    when "installer"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C142: Verify that pressing Reset on the edit profile view returns the fields to their default state.
      # Criteria:
      # The reset buttons resets fields
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_142(@env_info, @client, email_reset, mobile_reset)
    when "pma"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C157: Verify that pressing Reset on the edit profile view returns the fields to their default state.
      # Criteria:
      # The reset buttons resets fields
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_157(@env_info, @client, email_reset, mobile_reset)
    when "tenant admin"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C170: Verify that pressing Reset on the edit profile view returns the fields to their default state.
      # Criteria:
      # The reset buttons resets fields
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_170(@env_info, @client, email_reset, mobile_reset)
  end

end



Then(/I should see information about the "([^"]*)" "([^"]*)"/) do |item, role|
  case item
    when "Eric's 100k Door"
      building_info_validation = []
      building_info_validation << (@admin_ui.info_data_table[0].text.include? "Terminal ID QA12345")
      building_info_validation << (@admin_ui.info_data_table[0].text.include? "Building Eric's Test Building")
      case role
        when "employee"
          # * * * * * * * T E S T R A I L S * * * * * * *
          # C106: On the Doors view, verify that clicking 'More...' opens a view with information for a specific door.
          # Criteria:
          # Verify the info for the door
          # Suite Admin UI
          # ---------------------------------------------

          TestRailsTest.check_106(@env_info, @client, building_info_validation.all?)
        when "installer"
          # * * * * * * * T E S T R A I L S * * * * * * *
          # C147: On the Doors view, verify that clicking 'More...' opens a view with information for a specific door.
          # Criteria:
          # Verify the info for the door
          # Suite Admin UI
          # ---------------------------------------------

          TestRailsTest.check_147(@env_info, @client, building_info_validation.all?)
        when "pma"
          # * * * * * * * T E S T R A I L S * * * * * * *
          # C162: On the Doors view, verify that clicking 'More...' opens a view with information for a specific door.
          # Criteria:
          # Verify the info for the door
          # Suite Admin UI
          # ---------------------------------------------
          TestRailsTest.check_162(@env_info, @client, building_info_validation.all?)
        when "tenant admin"
          # * * * * * * * T E S T R A I L S * * * * * * *
          # C175: On the Doors view, verify that clicking 'More...' opens a view with information for a specific door.
          # Criteria:
          # Verify the info for the door
          # Suite Admin UI
          # ---------------------------------------------

          TestRailsTest.check_175(@env_info, @client, building_info_validation.all?)
      end


    when "Eric's Test Building"
      building_info = []
      building_info << (@admin_ui.info_data_table[0].text.include? "Name Eric's Test Building")
      building_info << (@admin_ui.info_data_table[0].text.include? "Address 460 Saint Catherine")
      building_info << (@admin_ui.info_data_table[0].text.include? "City Montreal, QC")
      building_info << (@admin_ui.info_data_table[0].text.include? "Geo Coords 45.520497 × -73.581492")
      case role
        when "employee"
          # * * * * * * * T E S T R A I L S * * * * * * *
          # C107: On the Buildings view, verify that clicking 'More...' opens a view with information for a specific building.
          # Criteria:
          # Verify that clicking more opens a view with info for a building
          # Suite Admin UI
          # ---------------------------------------------

          TestRailsTest.check_107(@env_info, @client, building_info.all?)
        when "installer"
          # * * * * * * * T E S T R A I L S * * * * * * *
          # C148: On the Buildings view, verify that clicking 'More...' opens a view with information for a specific building.
          # Criteria:
          # Verify that clicking more opens a view with info for a building
          # Suite Admin UI
          # ---------------------------------------------

          TestRailsTest.check_148(@env_info, @client, building_info.all?)
        when "pma"
          # * * * * * * * T E S T R A I L S * * * * * * *
          # C163: On the Buildings view, verify that clicking 'More...' opens a view with information for a specific building.
          # Criteria:
          # Verify that clicking more opens a view with info for a building
          # Suite Admin UI
          # ---------------------------------------------

          TestRailsTest.check_163(@env_info, @client, building_info.all?)
        when "tenant admin"
          # * * * * * * * T E S T R A I L S * * * * * * *
          # C176: On the Buildings view, verify that clicking 'More...' opens a view with information for a specific building.
          # Criteria:
          # Verify that clicking more opens a view with info for a building
          # Suite Admin UI
          # ---------------------------------------------

          TestRailsTest.check_176(@env_info, @client, building_info.all?)
      end


  end
end

When(/I accept the "([^"]*)" invitation/) do |guest|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case guest.downcase
    when "new guest"
      # magic wait combo
      @admin_ui.search.send_keys @guest_first_name
    else
      @admin_ui.search.send_keys @user_hash[guest.to_sym][:first_name]
  end
  wait.until {
    # @admin_ui.loading.wait_until_present
    @admin_ui.loading.wait_while_present
  }
  wait.until {
    @browser.table(:css => '.dataTable').count == 2
  }
  @browser.select_list(:css => 'select').option(:text => "Approved by Admin").select
  wait.until {@browser.element(:css => '.dataTable').text.include? 'accepted'}
  fail "Invite not accepted" unless @browser.element(:css => '.dataTable').text.include? 'accepted'

end

When(/I reject the "([^"]*)" invitation/) do |guest|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case guest.downcase
    when "new guest"
      # magic wait combo
      @admin_ui.search.send_keys @guest_first_name
    else
      @admin_ui.search.send_keys @user_hash[guest.to_sym][:first_name]
  end
  wait.until {
    # @admin_ui.loading.wait_until_present
    @admin_ui.loading.wait_while_present
  }
  wait.until {
    @browser.table(:css => '.dataTable').count == 2
  }
  @browser.select_list(:css => 'select').option(:text => "Rejected By Admin").select
  wait.until {@browser.element(:css => '.dataTable').text.include? 'rejected'}

end