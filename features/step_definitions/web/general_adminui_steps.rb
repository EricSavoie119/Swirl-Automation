Given(/I am on the Waltz log in page/) do
  @browser.goto @env['AdminUI']['url']
end

Given(/I sign in to the admin UI as a "([^"]*)"/) do |user|
  if @browser.exists?
    if @browser.url != "data:,"
      @browser.close
      @browser = Watir::Browser.new BROWSER_TYPE.to_sym
      @admin_ui = AdminUI.new(@browser)
    end
  end

  @browser.goto @env['AdminUI']['url']

  if user.include? ' '; user.sub!(' ','_') end
  @user = user
  if @env_info != {} && @env_info[:base_uri] == "https://lenel.re-qa.waltzlabs.com"
    @admin_ui.email.send_keys @env['auth']['lenel']['building'][@env_info[:user]][user]
  else
    @admin_ui.email.send_keys @env['auth']['qa'][user]
  end

  @admin_ui.password.send_keys @env['password']
  @admin_ui.sign_in.click
  fail "Not logged in." unless @admin_ui.profile_info.wait_until_present
end

When(/I navigate to the "([^"]*)" page$/) do |page|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  case page
    when "support"
      @admin_ui.support.click
    when "edit profile"
      @admin_ui.role_change.click
      @admin_ui.profile.click
      @admin_ui.edit.click
      wait.until {@admin_ui.top_bar_text.text.include? "Edit My Profile"}
      @test_rails_hash.merge!({:my_profile_works => (@admin_ui.top_bar_text.text.include? "Edit My Profile")})
    when "doors"
      @admin_ui.doors.click
    when "buildings"
      @admin_ui.buildings.click
    when "guests"
      @admin_ui.guests.click
    when "users"
      @admin_ui.users.click
    when "door groups"
      @admin_ui.door_groups.click
    when "tenants"
      @admin_ui.tenants.click
    when "entries"
      @admin_ui.entries.click
    when "rejections"
      @admin_ui.rejections.click
    when "reports"
      @admin_ui.reports.click
    when "guest"
      @admin_ui.guests.click
      @admin_ui.guest_tab.click
  end
end

When(/I sign in to the admin UI as the "([^"]*)"$/) do |user|
  case user
    when "new user"
      if @browser.exists?
        if @browser.url != "data:,"
          @browser.close
          @browser = Watir::Browser.new BROWSER_TYPE.to_sym
          @admin_ui = AdminUI.new(@browser)
        end
      end
    @browser.goto @env['AdminUI']['url']
    @admin_ui.email.send_keys @email
    @admin_ui.password.send_keys @env['password']
    @admin_ui.sign_in.click
  end
end

When(/I sign in to the admin UI as the "([^"]*)" user/) do |user|
  if @browser.exists?
    if @browser.url != "data:,"
      @browser.close
      @browser = Watir::Browser.new BROWSER_TYPE.to_sym
      @admin_ui = AdminUI.new(@browser)
    end
  end

  @browser.goto @env['AdminUI']['url']

  case user
    when "1"
      @admin_ui.email.send_keys @user_hash[user.to_sym][:email]
      @admin_ui.password.send_keys @env['password']
      @admin_ui.sign_in.click
  end
  fail "Not logged in." unless @admin_ui.profile_info.wait_until_present
end

Then(/I change the name of my "([^"]*)" user/) do |num|
  first_name = Faker::Name.first_name + Faker::Number.number(5).gsub("'","")
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  number = @user_hash.count
  @admin_ui.users.click
  begin
    @admin_ui.search.send_keys @user_hash[num.to_s.to_sym][:first_name]
  rescue Exception => e
  end
  @admin_ui.click_more_button(@admin_ui, @browser, @user_hash, num)
  @admin_ui.edit.click
  @admin_ui.info_tab.click
  @admin_ui.first_name.to_subtype.clear
  @admin_ui.first_name.send_keys first_name
  @user_hash[num.to_s.to_sym][:first_name] = first_name
  @user_hash[num.to_s.to_sym][:name_changed] = :true
  @admin_ui.click_save_button(@browser)
  FirePoll.poll("Wait for screen") do
    @admin_ui.user_table.text.include? @user_hash[num.to_s.to_sym][:first_name]
  end
  fail "Name wasn't changed" unless @admin_ui.user_table.text.include? @user_hash[num.to_s.to_sym][:first_name]
end

When(/I navigate to the "([^"]*)" screen/) do |page|
  case page
    when "add users"
      @admin_ui.users.click
      @admin_ui.add.click
  end
end

When(/I add "([^"]*)" "([^"]*)" with adminUI/) do |number, role|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  @number = number
  @role = role
  @access_array = AdminUI.access_level(@number)
  case role
    when "Employee"
      number.to_i.times { |num|
        @admin_ui.add_user(@admin_ui, role, @first_name, @last_name, @email, @mobile, @browser)
        wait.until {@browser.execute_script("return document.readyState;") == "complete"
        sleep(0.3)}
        @admin_ui.save.click
        @admin_ui.delete.wait_until_present
        @user_hash.merge!(num.to_s.to_sym => {
            :first_name => @first_name,
            :last_name  => @last_name,
            :email => @email,
            :mobile => @mobile,
            :access => @access_array[num],
            :password => @env['password'],
            :name_changed => :false,
            :pass_changed => :false
        })
        @first_name = Faker::Name.first_name + Faker::Number.number(5).gsub("'","")
        @last_name  = Faker::Name.last_name.gsub("'","")

        @email = "#{@first_name}.#{@last_name}#{Faker::Number.number(3)}@mailinator.com"
        @mobile = "000-#{Faker::Number.number(3)}-#{Faker::Number.number(4)}"
      }
    # * * * * * * * T E S T R A I L S * * * * * * *
    # C10752: Verify that the TA can add employees to the Tenant.
    # Criteria:
    # @user == "tenant admin"
    # @user_hash has users that are discoverable by searching in the user section
    # Suite = Admin UI - XYZ
    # ----------------------------------------------
    if @user == "tenant_admin"
      TestRailsTest.check_10752(@env_info, @client, @user_hash, @admin_ui, @number)
    end

  end
end

When(/I test the "([^"]*)" errors for "([^"]*)" "([^"]*)"/) do |type, page, role|
  case page
    when "new user"
      case type
        when "required"
          @admin_ui.first_name.send_keys :tab
          fail "Required error is required." unless @admin_ui.errors[0].visible?
          fail "Required message was not as expected." unless @admin_ui.errors[0].text == "Required"
          @admin_ui.last_name.send_keys :tab
          fail "Required error is required." unless @admin_ui.errors[1].visible?
          fail "Required message was not as expected." unless @admin_ui.errors[1].text == "Required"
          @admin_ui.email.send_keys :tab
          fail "Required error is required." unless @admin_ui.errors[2].visible?
          fail "Required message was not as expected." unless @admin_ui.errors[2].text == "Required"
          @admin_ui.mobile.send_keys :tab
          fail "Required error is required." unless @admin_ui.errors[3].visible?
          fail "Required message was not as expected." unless @admin_ui.errors[3].text == "Required"
        when "format"
          @admin_ui.first_name.send_keys "Q"
          fail "Format error is required." unless @admin_ui.errors[0].visible?
          fail "Format message was not as expected." unless @admin_ui.errors[0].text == "First name must be 2 or more characters in length"
          @admin_ui.last_name.send_keys "Q"
          fail "Format error is required." unless @admin_ui.errors[1].visible?
          fail "Format message was not as expected." unless @admin_ui.errors[1].text == "Last name must be 2 or more characters in length"
          @admin_ui.mobile.send_keys "1"
          fail "Format error is required." unless @admin_ui.errors[3].visible?
          fail "Format message was not as expected." unless @admin_ui.errors[3].text == "Mobile phone number must be 2 or more characters in length"
          @admin_ui.mobile.send_keys "eric"
          fail "Format error is required." unless @admin_ui.errors[3].visible?
          fail "Format message was not as expected." unless @admin_ui.errors[3].text == "Only numbers, dashes, periods and spaces allowed"
          @admin_ui.email.send_keys "q"
          @admin_ui.first_name.send_keys "eric"
          @admin_ui.last_name.send_keys "savoie"
          @admin_ui.mobile.to_subtype.clear
          @admin_ui.mobile.send_keys "123-435-6789"
          @admin_ui.save.click
          fail "Format error is required." unless !@browser.execute_script("return arguments[0].checkValidity();", @admin_ui.email)
          fail "Format message was not as expected." unless @browser.execute_script("return arguments[0].validationMessage;", @admin_ui.email) == "Please include an '@' in the email address. 'q' is missing an '@'."
      end
    when "edit profile"
      case type
        when "required"
          @admin_ui.email.to_subtype.clear
          @admin_ui.email.send_keys :tab
          @email_required_error = @admin_ui.email.following_sibling.text == "Required"
          @admin_ui.mobile.to_subtype.clear
          @admin_ui.mobile.send_keys :tab
          @mobile_required_error = @admin_ui.mobile.following_sibling.text == "Required"
        when "format"
          @admin_ui.mobile.to_subtype.clear
          @admin_ui.mobile.send_keys "qwe"
          mobile_format_error = @admin_ui.mobile.following_sibling.text == "Only numbers, dashes, periods and spaces allowed"
          @admin_ui.mobile.to_subtype.clear
          @admin_ui.mobile.send_keys "1"
          mobile_format_error_2 = @admin_ui.mobile.following_sibling.text == "Mobile phone number must be 2 or more characters in length"
          @admin_ui.mobile.send_keys "231234123"
          @admin_ui.email.send_keys "q"
          @admin_ui.save.click
          invalid_email = !@browser.execute_script("return arguments[0].checkValidity();", @admin_ui.email)
          invalid_email_message = @browser.execute_script("return arguments[0].validationMessage;", @admin_ui.email) == "Please include an '@' in the email address. 'q' is missing an '@'."
          @admin_ui.email.to_subtype.clear
          @admin_ui.email.send_keys @env['auth']['qa'][@user]
          @admin_ui.password.send_keys '1'
          invalid_password = @admin_ui.password.attribute('validationMessage') == "Please match the requested format."
          invalid_password_2 = @admin_ui.password.attribute('title') == "Password must contain a lowercase letter, an uppercase letter, a number and 6 characters"
          case role
            when "employee"
              # * * * * * * * T E S T R A I L S * * * * * * *
              # C102: Verify that pressing Save on edit profile view with an invalid email returns an error message.
              # Criteria:
              # Pressing save with invalid email returns errors
              # Suite Admin UI
              # ---------------------------------------------
              TestRailsTest.check_102(@env_info, @client, invalid_email, invalid_email_message, @email_required_error)
              # * * * * * * * T E S T R A I L S * * * * * * *
              # C103: Verify that pressing Save on edit profile view with an invalid Mobile number (10 digits) returns an error message.
              # Criteria:
              # Pressing save with an invalid mobile sets off errors
              # Suite Admin UI
              # ---------------------------------------------
              TestRailsTest.check_103(@env_info, @client, mobile_format_error, mobile_format_error_2, @mobile_required_error)
              # * * * * * * * T E S T R A I L S * * * * * * *
              # C104: Verify that pressing Save on edit profile view with an invalid password returns an error message (details inside).
              # Criteria:
              # Pressing save with invalid password returns error
              # Suite Admin UI
              # ---------------------------------------------
              TestRailsTest.check_104(@env_info, @client, invalid_password, invalid_password_2)
            when "installer"
              # * * * * * * * T E S T R A I L S * * * * * * *
              # C143: Verify that pressing Save on edit profile view with an invalid email returns an error message.
              # Criteria:
              # Pressing save with invalid email returns errors
              # Suite Admin UI
              # ---------------------------------------------
              TestRailsTest.check_143(@env_info, @client, invalid_email, invalid_email_message, @email_required_error)
              # * * * * * * * T E S T R A I L S * * * * * * *
              # C144: Verify that pressing Save on edit profile view with an invalid Mobile number (10 digits) returns an error message.
              # Criteria:
              # Pressing save with an invalid mobile sets off errors
              # Suite Admin UI
              # ---------------------------------------------
              TestRailsTest.check_144(@env_info, @client, mobile_format_error, mobile_format_error_2, @mobile_required_error)
              # * * * * * * * T E S T R A I L S * * * * * * *
              # C145: Verify that pressing Save on edit profile view with an invalid password returns an error message (details inside).
              # Criteria:
              # Pressing save with invalid password returns error
              # Suite Admin UI
              # ---------------------------------------------
              TestRailsTest.check_145(@env_info, @client, invalid_password, invalid_password_2)
            when "pma"
              # * * * * * * * T E S T R A I L S * * * * * * *
              # C158: Verify that pressing Save on edit profile view with an invalid email returns an error message.
              # Criteria:
              # Pressing save with invalid email returns errors
              # Suite Admin UI
              # ---------------------------------------------
              TestRailsTest.check_158(@env_info, @client, invalid_email, invalid_email_message, @email_required_error)
              # * * * * * * * T E S T R A I L S * * * * * * *
              # C159: Verify that pressing Save on edit profile view with an invalid Mobile number (10 digits) returns an error message.
              # Criteria:
              # Pressing save with an invalid mobile sets off errors
              # Suite Admin UI
              # ---------------------------------------------
              TestRailsTest.check_159(@env_info, @client, mobile_format_error, mobile_format_error_2, @mobile_required_error)
              # * * * * * * * T E S T R A I L S * * * * * * *
              # C160: Verify that pressing Save on edit profile view with an invalid password returns an error message (details inside).
              # Criteria:
              # Pressing save with invalid password returns error
              # Suite Admin UI
              # ---------------------------------------------
              TestRailsTest.check_160(@env_info, @client, invalid_password, invalid_password_2)
            when "tenant admin"
              # * * * * * * * T E S T R A I L S * * * * * * *
              # C171: Verify that pressing Save on edit profile view with an invalid email returns an error message.
              # Criteria:
              # Pressing save with invalid email returns errors
              # Suite Admin UI
              # ---------------------------------------------
              TestRailsTest.check_171(@env_info, @client, invalid_email, invalid_email_message, @email_required_error)
              # * * * * * * * T E S T R A I L S * * * * * * *
              # C172: Verify that pressing Save on edit profile view with an invalid Mobile number (10 digits) returns an error message.
              # Criteria:
              # Pressing save with an invalid mobile sets off errors
              # Suite Admin UI
              # ---------------------------------------------
              TestRailsTest.check_172(@env_info, @client, mobile_format_error, mobile_format_error_2, @mobile_required_error)
              # * * * * * * * T E S T R A I L S * * * * * * *
              # C173: Verify that pressing Save on edit profile view with an invalid password returns an error message (details inside).
              # Criteria:
              # Pressing save with invalid password returns error
              # Suite Admin UI
              # ---------------------------------------------
              TestRailsTest.check_173(@env_info, @client, invalid_password, invalid_password_2)
          end


      end
  end
end

When(/I sign out of the admin ui/) do
  @admin_ui.role_change.click
  @admin_ui.sign_out.click
  @test_rails_hash.merge!({:sign_out => (@browser.url.include? "sign-in")})
end

When(/I give users access to the test door/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  number = @user_hash.count
  @admin_ui.users.click
  number.times {|num|
    begin
      @admin_ui.search.send_keys @user_hash[num.to_s.to_sym][:first_name]
    rescue Exception => e
    end

    @admin_ui.click_more_button(@admin_ui, @browser, @user_hash, num)
    # **********
    # :a
    #
    # **********
    if @user_hash[num.to_s.to_sym][:access] == :a
      @admin_ui.set_door_access(@admin_ui, @browser)

    # **********
    # :a_
    # **********
    elsif @user_hash[num.to_s.to_sym][:access] == :a_
      @admin_ui.set_door_access(@admin_ui, @browser)
      @admin_ui.edit.click
      @admin_ui.click_access_times(@admin_ui, @browser)
      @browser.elements(:css => 'span[class="btn"]')[0].click
      @day_toggles = @browser.elements(:css => ".grid-middle")
      @day_toggles.each_with_index {|num, index|
        if index == @day_toggles.size - 1
          nil
        else
          num.element(:css => ".react-toggle").click unless num.text.strip == Date.today.strftime("%A")[0...3]
        end
      }
      @admin_ui.click_save_button(@browser)
    # ****************
    # :r
    # ***************
    elsif @user_hash[num.to_s.to_sym][:access] == :r
      @admin_ui.set_door_access(@admin_ui, @browser)
      @admin_ui.edit.click
      @admin_ui.click_access_times(@admin_ui,@browser)
      @browser.elements(:css => 'span[class="btn"]')[0].click
      @day_toggles.each_with_index {|num, index|
        if index == @day_toggles.size-1
          nil
        else
          num.element(:css => ".react-toggle").click
        end
      }
      @admin_ui.click_save_button(@browser)
    # ****************
    # :r_
    # ****************
    elsif @user_hash[num.to_s.to_sym][:access] == :r_
      @admin_ui.set_door_access(@admin_ui, @browser)
      @admin_ui.edit.click
      @admin_ui.click_access_times(@admin_ui, @browser)
      @browser.elements(:css => 'span[class="btn"]')[0].click
      @day_toggles.each_with_index { |num, index|
        if index == @day_toggles.size - 1
          nil
        else
          num.element(:css => ".react-toggle").click if num.text.strip == Date.today.strftime("%A")[0...3]
        end
      }
      # @admin_ui.click_a_save_button(@browser)
      #

      @admin_ui.click_save_button(@browser)
    end

    wait.until{
      @admin_ui.top_bar_text.text.include? @user_hash[num.to_s.to_sym][:first_name]
    }
    @admin_ui.users.click
  }
end

When(/I shuffle the users access to the test door/) do
  @user_hash = AdminUI.modify_access_level(@number, @user_hash)
  # four methods
  # 1 access everyday all day
  # access_level => :a
  # 2 access now but not later
  # access_level => :a_
  # 3 rejected every day all day
  # access_level => :r
  # 4 rejected now but not later
  # access_level => :r_
end

Then(/I pause the script and see if it worked/) do
  binding.pry
end

When(/I reset each users access/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  number = @user_hash.count
  @admin_ui.users.click
  number.times {|num|
    begin
      @admin_ui.search.send_keys @user_hash[num.to_s.to_sym][:first_name]
    rescue Exception => e
    end

    @admin_ui.click_more_button(@admin_ui, @browser, @user_hash, num)

    if @user_hash[num.to_s.to_sym][:access] == :a
      nil
    elsif @user_hash[num.to_s.to_sym][:access] == :a_
      @admin_ui.edit.click
      @admin_ui.click_access_times(@admin_ui, @browser)
      @browser.elements(:css => 'span[class="btn"]')[0].click
      @day_toggles = @browser.elements(:css => ".grid-middle")
      @day_toggles.each_with_index {|num, index|
        if index == @day_toggles.size - 1
          nil
        else
          num.element(:css => ".react-toggle").click if num.text.strip == Date.today.strftime("%A")[0...3]
        end
      }
      @day_toggles.each_with_index {|num, index|
        if index == @day_toggles.size - 1
          nil
        else
          num.element(:css => ".react-toggle").click
        end
      }
      @admin_ui.click_save_button(@browser)
    elsif @user_hash[num.to_s.to_sym][:access] == :r
      @admin_ui.edit.click
      @admin_ui.click_access_times(@admin_ui, @browser)
      @browser.elements(:css => 'span[class="btn"]')[0].click
      @day_toggles.each_with_index {|num, index|
        if index == @day_toggles.size-1
          nil
        else
          num.element(:css => ".react-toggle").click
        end
      }
      @admin_ui.click_save_button(@browser)
    elsif @user_hash[num.to_s.to_sym][:access] == :r_
      @admin_ui.edit.click
      @admin_ui.click_access_times(@admin_ui, @browser)
      @browser.elements(:css => 'span[class="btn"]')[0].click
      @day_toggles.each_with_index { |num, index|
        if index == @day_toggles.size - 1
          nil
        else
          num.element(:css => ".react-toggle").click unless num.text.strip == Date.today.strftime("%A")[0...3]
        end
      }
      @day_toggles.each_with_index {|num, index|
        if index == @day_toggles.size-1
          nil
        else
          num.element(:css => ".react-toggle").click
        end
      }
      @admin_ui.click_save_button(@browser)
    end

    wait.until{
      @admin_ui.top_bar_text.text.include? @user_hash[num.to_s.to_sym][:first_name]
    }
    @admin_ui.users.click
  }
end

When(/I modify each users access/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  number = @user_hash.count
  @admin_ui.users.click
  number.times {|num|
    begin
      @admin_ui.search.send_keys @user_hash[num.to_s.to_sym][:first_name]
    rescue Exception => e
    end

    @admin_ui.click_more_button(@admin_ui, @browser, @user_hash, num)

    if @user_hash[num.to_s.to_sym][:access] == :a
      nil
    elsif @user_hash[num.to_s.to_sym][:access] == :a_
      @admin_ui.edit.click
      @admin_ui.click_access_times(@admin_ui, @browser)
      @browser.elements(:css => 'span[class="btn"]')[0].click
      @day_toggles = @browser.elements(:css => ".grid-middle")
      @day_toggles.each_with_index {|num, index|
        if index == @day_toggles.size - 1
          nil
        else
          num.element(:css => ".react-toggle").click unless num.text.strip == Date.today.strftime("%A")[0...3]
        end
      }
      @admin_ui.click_save_button(@browser)
    elsif @user_hash[num.to_s.to_sym][:access] == :r
      @admin_ui.edit.click
      @admin_ui.click_access_times(@admin_ui, @browser)
      @browser.elements(:css => 'span[class="btn"]')[0].click
      @day_toggles.each_with_index {|num, index|
        if index == @day_toggles.size-1
          nil
        else
          num.element(:css => ".react-toggle").click
        end
      }
      @admin_ui.click_save_button(@browser)
    elsif @user_hash[num.to_s.to_sym][:access] == :r_
      @admin_ui.edit.click
      @admin_ui.click_access_times(@admin_ui, @browser)
      @browser.elements(:css => 'span[class="btn"]')[0].click
      @day_toggles.each_with_index { |num, index|
        if index == @day_toggles.size - 1
          nil
        else
          num.element(:css => ".react-toggle").click if num.text.strip == Date.today.strftime("%A")[0...3]
        end
      }
      @admin_ui.click_save_button(@browser)
    end

    wait.until{
      @admin_ui.top_bar_text.text.include? @user_hash[num.to_s.to_sym][:first_name]
    }
    @admin_ui.users.click
  }
end

When(/I click the "([^"]*)" button/) do |button|
  case button
    when "add"
      @admin_ui.add.click
    when "forgot password"
      @browser.element(:css => 'a[href="#/forgot-password"]').click
  end
end

When(/I navigate to "([^"]*)" more page/) do |name|
  case name
    when "new user"
      @admin_ui.click_more_button(@admin_ui, @browser, nil, nil, @first_name)
    else
      @admin_ui.click_more_button(@admin_ui, @browser, nil, nil, name)
  end

end

When(/I reset the password for "([^"]*)"/) do |email|
  @email = email
  @browser.element(:css => 'input[name="email"]').send_keys email
  @browser.element(:css => ".btn.btn--signin").click
end

Then(/I validate the reset password email brings me to the correct page/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  response = Automato::MailinatorHelper.getInbox(@email)
  email = Automato::MailinatorHelper.get_individual_email(response['messages'][0]['id'])
  parsed_body = Nokogiri(email['data']['parts'][0]['body'])
  reset_link = parsed_body.search('a')[1].to_h['href']

  @browser.goto reset_link
  wait.until {@browser.url.include?  "forgot-password/new"}




  forgot_password_page = @browser.url.include? "forgot-password/new"
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C403: Verify that clicking on the reset password email link opens the browser on the change password page in the default browser.
  # Criteria:
  # Forgot password email brings you to forgot password page
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_403(@env_info, @client, forgot_password_page)
end

When(/I search for my new user/) do
  @admin_ui.users.click
  @admin_ui.search.send_keys @first_name
end

When(/I modify their info/) do
  @admin_ui.edit.click
  @browser.element(:css => ".tab-heading-item .icons8-info").click
  @browser.element(:css => 'input[name="firstName"]').to_subtype.clear
  @new_first_name = Faker::Name.first_name + Faker::Number.number(5).gsub("'","")
  @browser.element(:css => 'input[name="firstName"]').send_keys @new_first_name
  @admin_ui.click_save_button(@browser)
end

Then(/I validate the new info/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  wait.until {@admin_ui.user_table.text.include? @new_first_name}
  old_name = @admin_ui.user_table.text.include? @first_name
  new_name = @admin_ui.user_table.text.include? @new_first_name

  array = [!old_name, new_name]
  edit_info_worked = array.all?

  # * * * * * * * T E S T R A I L S * * * * * * *
  # C240: Verify that if the user info is changed via Edit User menu, it is reflected on their account.
  # Criteria:
  # Edit user changes info on user page
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_240(@env_info, @client, edit_info_worked)

end

When(/I modify their floor number/) do
  @admin_ui.edit.click
  @browser.element(:css => ".tab-heading-item .icons8-info").click
  @browser.element(:css => 'input[name="destinationFloor"]').to_subtype.clear
  @browser.element(:css => 'input[name="destinationFloor"]').to_subtype.clear
  @browser.element(:css => 'input[name="destinationFloor"]').send_keys "40"
  @admin_ui.click_save_button(@browser)
end

When(/I modify their first name/) do
  @admin_ui.edit.click
  @first_name_2 = Faker::Name.first_name + Faker::Number.number(5).gsub("'","")
  @last_name_2 = Faker::Name.last_name
  @admin_ui.info_tab.click
  @admin_ui.first_name.to_subtype.clear
  @admin_ui.first_name.send_keys @first_name_2
  @admin_ui.last_name.to_subtype.clear
  @admin_ui.last_name.send_keys @last_name_2
  @admin_ui.click_save_button(@browser)
end

Then(/I validate the new floor number "([^"]*)"/) do |role|

  @admin_ui.edit.click
  edit_floor_worked = @browser.element(:css => 'input[name="destinationFloor"]').attribute('value') == "40"
  case role
    when "pma"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C6120: In the info tab verify that a floor number can be assigned to a user.
      # Criteria:
      # Can edit the floor number for a user
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_6120(@env_info, @client, edit_floor_worked)
    when "tenant admin"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C6121: In the info tab verify that a floor number can be assigned to a user.
      # Criteria:
      # Can edit the floor number for a user
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_6121(@env_info, @client, edit_floor_worked)
  end
end

Then(/I validate the access times tab "([^"]*)"/) do |role|
  @admin_ui.edit.click
  @browser.element(:css => ".tab-heading .icons8-clock").click
  @admin_ui.remove_access_time(1, @browser)
  remove_works = !@browser.elements(:css => ".dataTable")[3].tbody.trs[1].exists?
  @admin_ui.click_add_access_time(@browser)
  access_works = @browser.elements(:css => ".dataTable")[3].tbody.trs[1].exists?
  @admin_ui.modify_edit_access_times(@admin_ui)
  @day_toggles = @browser.elements(:css => ".grid-middle")

  @toggle_validation = []

  @day_toggles.each_with_index {|num, index|
    if index == @day_toggles.size - 1
      nil
    else
      @toggle_validation << !num.element(:css => ".react-toggle.react-toggle--checked").exists?
      num.element(:css => ".react-toggle").click
      @toggle_validation << num.element(:css => ".react-toggle.react-toggle--checked").exists?
    end
  }

  @day_toggles.each_with_index {|num, index|
    if index == @day_toggles.size - 1
      nil
    else
      @toggle_validation << num.element(:css => ".react-toggle.react-toggle--checked").exists?
      num.element(:css => ".react-toggle").click
      @toggle_validation << !num.element(:css => ".react-toggle.react-toggle--checked").exists?
    end
  }

  day_toggles_work = @toggle_validation.all?
  @day_toggles.each_with_index {|num, index|
    if index == @day_toggles.size - 1
      nil
    else
      if num.text.strip == Date.today.strftime("%A")[0...3]
        num.element(:css => ".react-toggle").click
      end
    end
  }

  @admin_ui.click_save_button(@browser)

  @access_time_save_validation = []
  @admin_ui.edit.wait_until_present
  @access_time_save_validation << (@browser.elements(:css => ".dataTable")[0].text.include? "#{Date.today.strftime("%A")[0...3]} between 00:15 and 00:30 beginning #{DateTime.now.strftime("%Y-%m-%d")} ending 2019-03-14")

  @admin_ui.edit.click
  @browser.element(:css => ".tab-heading .icons8-clock").click

  @access_time_save_validation << @browser.elements(:css => ".dataTable")[3].tbody.trs[1].exists?
  before = @browser.elements(:css => ".dataTable")[3].tbody.trs.count
  5.times {@admin_ui.click_add_access_time(@browser)}
  after =     @browser.elements(:css => ".dataTable")[3].tbody.trs.count
  access_time_save = @access_time_save_validation.all?
  add_access_times = before < after
  case role
    when "pma"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C241: Verify the functionality of the Access Times tab in the Edit User menu (details inside).
      # Criteria:
      # Access time tab has functionality as expected
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_241(@env_info, @client, remove_works, access_works, day_toggles_work, access_time_save, add_access_times)
    when "tenant admin"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C271: Verify the functionality of the Access Times tab in the Edit User menu (details inside).
      # Criteria:
      # Access time tab has functionality as expected
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_241(@env_info, @client, remove_works, access_works, day_toggles_work, access_time_save, add_access_times)
  end

end

When(/I toggle the users roles "([^"]*)"/) do |role|
  @admin_ui.edit.click
  @admin_ui.roles_tab.click
  case role
    when "pma"
      @browser.elements(:css => ".tab-panel.tab-panel--active .react-toggle")[1].click
      @browser.elements(:css => ".tab-panel.tab-panel--active .react-toggle")[2].click
      @browser.elements(:css => ".tab-panel.tab-panel--active .react-toggle")[3].click
    when "tenant admin"
      @browser.elements(:css => ".tab-panel.tab-panel--active .react-toggle")[1].click
  end

  @admin_ui.click_save_button(@browser)
end

Then(/I log in and check the user's roles "([^"]*)"/) do |role|
  @admin_ui.profile_info.click
  @admin_ui.profile.click
  case role
    when "pma"
      available_roles_can_be_applied = {
          :PMA => (@browser.elements(:css => ".dataTable")[1].text.include? "Property Manager Admin"),
          :Employee => (@browser.elements(:css => ".dataTable")[1].text.include? "Employee"),
          :Installer => (@browser.elements(:css => ".dataTable")[1].text.include? "Installer"),
          :Security_Guard => (@browser.elements(:css => ".dataTable")[1].text.include? "Security Guard")
      }
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C244: Verify that all available roles can be toggled on/off via Edit a User menu and the changes are applied on their next log in if they are saved (details inside).
      # Criteria:
      # All roles can be toggled
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_244(@env_info, @client, available_roles_can_be_applied.values.all?)
    when "tenant admin"
      available_roles_can_be_applied = {
          :Employee => (@browser.elements(:css => ".dataTable")[1].text.include? "Employee"),
          :Tenant_admin => (@browser.elements(:css => ".dataTable")[1].text.include? "Tenant Admin")
      }
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C274: Verify that all available roles can be toggled on/off via Edit a User menu and the changes are applied on their next log in if they are saved (details inside).
      # Criteria:
      # All roles can be toggled
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_274(@env_info, @client, available_roles_can_be_applied.values.all?)
  end
end

When(/I verify I can delete my user "([^"]*)"/) do |role|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  @admin_ui.edit.click
  @admin_ui.delete.click
  delete_validation = {}
  reset_validation = {}
  delete_validation.merge!({:delete_confirm_exits => (@browser.element(:css => 'label[for="deleteConfirm"]').text.include? "Do you really wish to permanently delete this user? This action cannot be undone.")})
  @browser.element(:css => ".react-toggle").click
  reset_validation.merge!({:reset_button_exists => (@browser.element(:css => ".icons8-undo").exists?)})
  @admin_ui.reset.click
  reset_validation.merge!({
      :reset_butto_works => !(@browser.element(:css => ".react-toggle.react-toggle--checked").exists?)
  })

  @browser.element(:css => ".react-toggle").click
  @admin_ui.save.click
  wait.until {@admin_ui.top_bar_text.text.include? "Users"}
  @admin_ui.search.send_keys @first_name

  delete_validation.merge!({
      :user_deleted => !(@browser.elements(:css => ".btn.btn--more").count == 1)
  })
  case role
    when "pma"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C245: Verify that all available roles can be toggled on/off via Edit a User menu and the changes are applied on their next log in if they are saved (details inside).
      # Criteria:
      # User can be deleted
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_245(@env_info, @client, delete_validation.values.all?, reset_validation.values.all?)
    when "tenant admin"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C275: Verify that a user can be deleted via the Edit a User menu (details inside).
      # Criteria:
      # User can be deleted
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_275(@env_info, @client, delete_validation.values.all?, reset_validation.values.all?)
  end


end

Then(/I verify the add user by CSV button/) do
  @admin_ui.add.click
  @admin_ui.upload_csv.click

  upload_csv_page_exists = @admin_ui.top_bar_text.text.include? "Add Multiple Employees"
  choose_file_button     = @browser.element(:css => 'input[id="csv-file"]').exists?

  # * * * * * * * T E S T R A I L S * * * * * * *
  # C390: After clicking 'Add' on the users tab, verify that clicking on 'Upload CSV' button opens up a page to choose a file to upload.
  # Criteria:
  # Upload CSV button open a page to upload a file
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_390(@env_info, @client, upload_csv_page_exists, choose_file_button)
end

Then(/I verify I can upload multiple users with CSV file/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  number = 4
  File.truncate("#{File.expand_path('.')}/sample.csv", 0)
  @user_csv = {}
  CSV.open("#{File.expand_path('.')}/sample.csv", "a") do |handle|
    handle <<  ["firstName","lastName","email","mobile"]
  end
  number.to_i.times { |num|
    @user_csv.merge!(num.to_s.to_sym => {
        :first_name => @first_name,
        :last_name  => @last_name,
        :email => @email,
        :mobile => @mobile,
    })
    CSV.open("#{File.expand_path('.')}/sample.csv", "a") do |handle|
      handle <<  ["#{@user_csv[num.to_s.to_sym][:first_name]}", "#{@user_csv[num.to_s.to_sym][:last_name]}", "#{@user_csv[num.to_s.to_sym][:email]}", "#{@user_csv[num.to_s.to_sym][:mobile]}"]
    end
    @first_name = Faker::Name.first_name + Faker::Number.number(5).gsub("'","")
    @last_name  = Faker::Name.last_name.gsub("'","")

    @email = "#{@first_name}.#{@last_name}#{Faker::Number.number(3)}@mailinator.com"
    @mobile = "000-#{Faker::Number.number(3)}-#{Faker::Number.number(4)}"
  }
  @admin_ui.add.click
  @admin_ui.upload_csv.click
  @browser.element(:css => 'input[id="csv-file"]').send_keys File.expand_path("sample.csv")
  @browser.element(:css => 'button[id="upload"]').click
  @browser.element(:id => "csvContent").element(:css => "h2").exists?
  csv_can_be_uploaded = @browser.element(:id => "csvContent").element(:css => "h2").text.include? "Your CSV file has been successfully uploaded!"


  @admin_ui.users.click
  users_created_by_csv = {}
  number.to_i.times { |num|
    @admin_ui.search.send_keys @user_csv[num.to_s.to_sym][:first_name]
    sleep(1)
    FirePoll.poll("Wait for more", 10) do
      @browser.elements(:css => ".btn.btn--more").count == 1
    end
    users_created_by_csv.merge!({num.to_s.to_sym => @browser.elements(:css => ".btn.btn--more").count == 1})
    @admin_ui.search.to_subtype.clear

  }

  # * * * * * * * T E S T R A I L S * * * * * * *
  # C395: Verify that importing a valid CSV file will create all the users with the Employee role under the PMA.
  # Criteria:
  # Users can be uploaded with CSV
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_395(@env_info, @client, csv_can_be_uploaded, users_created_by_csv.values.all?)
end

Then(/I verify I can upload multiple users despite bad data in CSV/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  number = 4
  File.truncate("#{File.expand_path('.')}/sample.csv", 0)
  @user_csv = {}
  CSV.open("#{File.expand_path('.')}/sample.csv", "a") do |handle|
    handle <<  ["firstName","lastName","email","mobile"]
  end

  number.to_i.times {|num|
    @user_csv.merge!(num.to_s.to_sym => {
        :first_name => @first_name,
        :last_name => @last_name,
        :email => @email,
        :mobile => @mobile,
    })
    CSV.open("#{File.expand_path('.')}/sample.csv", "a") do |handle|
      handle <<  ["#{@user_csv[num.to_s.to_sym][:first_name]}", "#{@user_csv[num.to_s.to_sym][:last_name]}", "#{@user_csv[num.to_s.to_sym][:email]}", "#{@user_csv[num.to_s.to_sym][:mobile]}"]
      handle << ["fart", "fart", "la", "la"]
    end
    @first_name = Faker::Name.first_name + Faker::Number.number(5).gsub("'","")
    @last_name  = Faker::Name.last_name.gsub("'","")

    @email = "#{@first_name}.#{@last_name}#{Faker::Number.number(3)}@mailinator.com"
    @mobile = "000-#{Faker::Number.number(3)}-#{Faker::Number.number(4)}"
  }
  @admin_ui.add.click
  @admin_ui.upload_csv.click
  @browser.element(:css => 'input[id="csv-file"]').send_keys File.expand_path("sample.csv")
  @browser.element(:css => 'button[id="upload"]').click
  @browser.element(:id => "csvContent").element(:css => "h2").exists?
  csv_can_be_uploaded_with_errors = @browser.element(:css => ".csv-errors").text.include? "Errors were found in the CSV file"



  # * * * * * * * T E S T R A I L S * * * * * * *
  # C397: Verify that the import function gives error CSV files where some of the users have incorrect/invalid data while others do.
  # Criteria:
  # Users can be uploaded with a CSV despite bad data
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_397(@env_info, @client, csv_can_be_uploaded_with_errors)

end

Then(/I verify they received a welcome email "([^"]*)"$/) do |role|
  response = Automato::MailinatorHelper.getInbox(@email)
  email = Automato::MailinatorHelper.get_individual_email(response['messages'][0]['id'])
  user_receives_email = email['data']['subject'].include? "Get Started with Waltz"
  case role
    when "user"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C397: Verify that after adding a user successfully, they receive the welcome email to enroll their password.
      # Criteria:
      # USers receives email
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_397(@env_info, @client, user_receives_email)
    when "pma"
      # pma_info = email['data']['parts'][0]['body']

      # * * * * * * * T E S T R A I L S * * * * * * *
      # C249: Verify that adding a Tenant Admin will successfully send an email to the user's email address containing accurate information (details inside).
      # Criteria:
      # tenant admin receives email
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_249(@env_info, @client, user_receives_email)
  end


end

Then(/I verify that uploading an unaccepted file type triggers an error/) do
  @admin_ui.add.click
  @admin_ui.upload_csv.click
  @browser.element(:css => 'input[id="csv-file"]').send_keys File.expand_path("report.txt")
  @browser.element(:css => 'button[id="upload"]').click
  invalid_file_error = @browser.element(:css => ".csv-errors").text.include? "Errors were found in the CSV file"
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C394: Verify that adding an incorrect file type triggers an accurate error message.
  # Criteria:
  # Incorrect file type triggers error
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_394(@env_info, @client, invalid_file_error)
end

Then(/I verify the sample CSV after error is valid/) do
  @admin_ui.add.click
  @admin_ui.upload_csv.click
  @browser.element(:css => 'input[id="csv-file"]').send_keys File.expand_path("report.txt")
  @browser.element(:css => 'button[id="upload"]').click
  validator = Csvlint::Validator.new("https://qa.realestate.waltzapp.com/sample/sample.csv")

  # * * * * * * * T E S T R A I L S * * * * * * *
  # C4773: After adding an incorrect file type, verify that the 'Check sample file here' link downloads an excel sheet with the sample format.
  # Criteria:
  # Incorrect file type triggers correct sample
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_4773(@env_info, @client, validator.valid?)
end

Then(/I verify fields and add a tenant/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  error_messages = {}
  @admin_ui.add.click
  @admin_ui.name.send_keys "\t"
  error_messages.merge!({:name_required => (@browser.elements(:css => ".error")[0].text.include? "Required") && (@browser.elements(:css => ".error")[0].parent.parent.text.include? "Name")})
  @admin_ui.name.send_keys "t"
  error_messages.merge!({:name_format_error => (@browser.elements(:css => ".error")[0].text.include? "Name must be 2 or more characters in length") && (@browser.elements(:css => ".error")[0].parent.parent.text.include? "Name")})
  @admin_ui.building.click
  @admin_ui.drop_down.each {|option| if option.text == "Eric's Test Building" then break option.click end}
  error_messages.merge!({:building_is_selectable => (@browser.element(:css => ".Select-value-label").text.include? "Eric's Test Building")})
  @admin_ui.name.to_subtype.clear
  @admin_ui.name.to_subtype.clear
  @admin_ui.name.send_keys "#{@first_name} #{@last_name}"
  @admin_ui.save.click
  wait.until {@admin_ui.top_bar_text.text.include? @first_name}
  @admin_ui.tenants.click
  @admin_ui.search.send_keys @first_name
  FirePoll.poll("Wait for search to load", 10) do
    @admin_ui.refresh.click
    sleep(0.5)
    @browser.elements(:css => ".btn.btn--more").count == 1
  end

  tenant_exists = @browser.elements(:css => ".btn.btn--more").count == 1

  # * * * * * * * T E S T R A I L S * * * * * * *
  # C246: In the Tenants tab/view, clicking 'Add' allows the PMA to add a new Tenant to the Property Manager if all the fields are entered correctly (details inside).
  # Criteria:
  # Add tenant and verify error messages
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_246(@env_info, @client, error_messages.values.all?, tenant_exists)
end

Then(/I validate the tenant page/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  wait.until {@admin_ui.top_bar_text.text.include? "Eric's Test Tenant"}
  @browser.element(:css => ".tab-panel .dataTable").tbody.td(:text => "Eric's 100k Door").parent.element(:css => ".align--right").click
  buttons = {}
  wait.until {@admin_ui.top_bar_text.text.include? "Eric's 100k Door"}
  buttons.merge!({:more_opens_door_page => (@admin_ui.top_bar_text.text.include? "Eric's 100k Door")})
  @browser.back
  @admin_ui.admin_tab.click
  text = @admin_ui.more[1].parent.parent.td.text
  @browser.execute_script("arguments[0].click();", @admin_ui.more[1])
  wait.until{@admin_ui.top_bar_text.text.include? text }
  buttons.merge!({:more_opens_user_page => (@admin_ui.top_bar_text.text.include? text)})
  @browser.back

  buttons.merge!({:refresh_works => FirePoll.poll("Refresh worked", 10) do
    @admin_ui.refresh.click
    @admin_ui.loading.exists?
  end
  })

  @admin_ui.admin_tab.click
  @browser.element(:css => ".tab-panel .icons8-add").click
  wait.until{@admin_ui.top_bar_text.text.include? "Add a Tenant Admin"}
  buttons.merge!({:add_admin_works => (@admin_ui.top_bar_text.text.include? "Add a Tenant Admin")})
  @browser.back

  @admin_ui.edit.click
  wait.until{@browser.element(:css => ".tab-heading-item .icons8-info").exists?}
  buttons.merge!({:edit_works => @browser.element(:css => ".tab-heading-item .icons8-info").exists?})

  # * * * * * * * T E S T R A I L S * * * * * * *
  # C247: In the Tenants tab/view, when clicking on the 'More..' option for a specific Tenant, verify that all clickable elements function and relevant data is present (details inside).
  # Criteria:
  # Buttons work in the more page of a tenant
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_247(@env_info, @client, buttons.values.all?)
end

Then(/I verify I can add an admin to my tenant and see errors/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  @admin_ui.admin_tab.click
  @admin_ui.add_admin.click
  @admin_ui.first_name.send_keys "\t"
  errors = []
  errors << @admin_ui.verify_first_name_errors(@admin_ui)
  errors << @admin_ui.verify_last_name_errors(@admin_ui)
  errors << @admin_ui.verify_email_errors(@admin_ui, @browser, @email)
  errors << @admin_ui.verify_mobile_errors(@admin_ui, @browser)
  @admin_ui.modify_edit_access_times(@admin_ui)
  @admin_ui.first_name.to_subtype.clear
  @admin_ui.first_name.to_subtype.clear
  @admin_ui.last_name.to_subtype.clear
  @admin_ui.last_name.to_subtype.clear
  @admin_ui.email.to_subtype.clear
  @admin_ui.email.to_subtype.clear
  @admin_ui.mobile.to_subtype.clear
  @admin_ui.mobile.to_subtype.clear
  @admin_ui.first_name.send_keys @first_name
  @admin_ui.last_name.send_keys @last_name
  @admin_ui.email.send_keys @email
  @admin_ui.mobile.send_keys @mobile
  @admin_ui.save.click
  wait.until{@admin_ui.top_bar_text.text.include? "Eric's Test Tenant"}
  wait.until{@browser.element(:css => ".tab-panel.tab-panel--active .dataTable").tbody.trs.count > 5}
  number_of_pages = @browser.element(:css => ".pagination-text").children[1].text.to_i
  wait = Selenium::WebDriver::Wait.new(:timeout => 2)
  number_of_pages.times {|num|
    wait.until {@browser.element(:css => ".tab-panel.tab-panel--active .dataTable").tbody.exists?}
    break if @browser.element(:css => ".tab-panel.tab-panel--active .dataTable").tbody.text.include? @first_name
    @admin_ui.right_arrow.click
  }
  @browser.element(:css => ".tab-panel.tab-panel--active .dataTable").tbody.trs.each {|tr| if tr.text.include? @first_name then break tr.element(:css => ".btn").click  end}
  wait.until{@admin_ui.top_bar_text.text.include? @first_name}
  access_time_validation = @browser.elements(:css => ".dataTable")[0].text.include? "Every day between 00:15 and 00:30 beginning #{DateTime.now.strftime("%Y-%m-%d")} ending 2019-03-14"
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C248: In the Admin tab of a Tenant (click 'More..'), clicking 'Add admin' allows the PMA to add a new Tenant Administrator if all the fields are entered correctly (details inside).
  # Criteria:
  # Verify the add admin page for tenant
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_248(@env_info, @client, errors.all?, access_time_validation)
end

Then(/I verify the refresh button on the pages "([^"]*)"/) do |role|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  @admin_ui.doors.click
  wait.until {@admin_ui.top_bar_text.text.include? "Doors"}
  refresh_works = {}
  refresh_works.merge!({:refresh_1 => FirePoll.poll("Refresh worked", 10) do
    @admin_ui.refresh.click
    @admin_ui.loading.exists?
  end})
  @admin_ui.profile_info.click
  @admin_ui.profile.click
  wait.until {@admin_ui.top_bar_text.text.include? "My Profile"}
  refresh_works.merge!({:refresh_2 => FirePoll.poll("Refresh worked", 10) do
    @admin_ui.refresh.click
    @admin_ui.loading.exists?
  end})
  @admin_ui.buildings.click
  wait.until {@admin_ui.top_bar_text.text.include? "Buildings"}
  refresh_works.merge!({:refresh_3 => FirePoll.poll("Refresh worked",  10) do
    @admin_ui.refresh.click
    @admin_ui.loading.exists?
  end})

  case role
    when "employee"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C91: Verify the Refresh button works on the Doors, Buildings and My Profile views.
      # Criteria:
      # Verify the refresh button works home slice
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_91(@env_info, @client, refresh_works.values.all?)
    when "installer"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C136: Verify the Refresh button works on the Doors, Buildings and My Profile views.
      # Criteria:
      # Verify the refresh button works home slice
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_136(@env_info, @client, refresh_works.values.all?)
    when "pma"
      @admin_ui.door_groups.click
      wait.until {@admin_ui.top_bar_text.text.include? "Door Groups"}
      refresh_works.merge!({:refresh_4 => FirePoll.poll("Refresh worked", 10) do
        @admin_ui.refresh.click
        @admin_ui.loading.exists?
      end})
      @admin_ui.users.click
      wait.until {@admin_ui.top_bar_text.text.include? "Users"}
      refresh_works.merge!({:refresh_5 => FirePoll.poll("Refresh worked", 10) do
        @admin_ui.refresh.click
        @admin_ui.loading.exists?
      end})
      @admin_ui.guests.click
      wait.until {@admin_ui.top_bar_text.text.include? "Guest"}
      refresh_works.merge!({:refresh_6 => FirePoll.poll("Refresh worked", 10) do
        @admin_ui.refresh.click
        @admin_ui.loading.exists?
      end})
      @admin_ui.tenants.click
      wait.until {@admin_ui.top_bar_text.text.include? "Tenants"}
      refresh_works.merge!({:refresh_7 => FirePoll.poll("Refresh WOrked", 10) do
        @admin_ui.refresh.click
        @admin_ui.loading.exists?
        end})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C151: Verify the Refresh button works on the Doors, Buildings, Door Groups, Guests, Users, Tenants and My Profile views.
      # Criteria:
      # Verify the refresh button works home slice
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_151(@env_info, @client, refresh_works.values.all?)
    when "tenant admin"
      @admin_ui.door_groups.click
      wait.until {@admin_ui.top_bar_text.text.include? "Door Groups"}
      refresh_works.merge!({:refresh_4 => FirePoll.poll("Refresh worked", 10) do
        @admin_ui.refresh.click
        @admin_ui.loading.exists?
      end})
      @admin_ui.users.click
      wait.until {@admin_ui.top_bar_text.text.include? "Users"}
      refresh_works.merge!({:refresh_5 => FirePoll.poll("Refresh worked", 10) do
        @admin_ui.refresh.click
        @admin_ui.loading.exists?
      end})
      @admin_ui.guests.click
      wait.until {@admin_ui.top_bar_text.text.include? "Guest"}
      refresh_works.merge!({:refresh_6 => FirePoll.poll("Refresh worked", 10) do
        @admin_ui.refresh.click
        @admin_ui.loading.exists?
      end})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C164: Verify the Refresh button works on the Doors, Buildings, Door Groups, Users, Guests and My Profile views.
      # Criteria:
      # Verify the refresh button works home slice
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_164(@env_info, @client, refresh_works.values.all?)
  end

end

When(/I add a new tenant admin/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  @admin_ui.admin_tab.click
  @admin_ui.add_admin.click
  @admin_ui.first_name.send_keys @first_name
  @admin_ui.last_name.send_keys @last_name
  @admin_ui.email.send_keys @email
  @admin_ui.mobile.send_keys @mobile
  @admin_ui.save.click
end

Then(/I should be on the admin UI welcome page "([^"]*)"/) do |role|

  my_profile_log_out = @test_rails_hash.values.all?
  case role
    when "employee"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C97: Verify that clicking on the dropdown menu at the top opens the My Profile view or allows user to log out.
      # Criteria:
      # Verify the My Profile and Log out menu
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_97(@env_info, @client, my_profile_log_out)
    when "installer"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C139: Verify that clicking on the dropdown menu at the top opens the My Profile view or allows user to log out.
      # Criteria:
      # Verify the My Profile and Log out menu
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_139(@env_info, @client, my_profile_log_out)
    when "pma"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C154: Verify that clicking on the dropdown menu at the top opens the My Profile view or allows user to log out.
      # Criteria:
      # Verify the My Profile and Log out menu
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_154(@env_info, @client, my_profile_log_out)
    when "tenant admin"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C167: Verify that clicking on the dropdown menu at the top opens the My Profile view or allows user to log out.
      # Criteria:
      # Verify the My Profile and Log out menu
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_167(@env_info, @client, my_profile_log_out)
  end



end

Then(/Verify the show password checkbox toggles visibility "([^"]*)"/) do |role|
  show_pass_validation = []

  show_pass_validation << (@browser.element(:css => 'input[name="password"]').attribute('type') == 'password')
  @admin_ui.show_pass.click
  show_pass_validation << (@browser.element(:css => 'input[name="password"]')).attribute('type') == 'text'
  case role
    when "employee"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C105: Verify that the 'Show password' checkbox toggles visibility on the password field.
      # Criteria:
      # Verify Show password works
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_105(@env_info, @client, show_pass_validation.all?)
    when "installer"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C146: Verify that the 'Show password' checkbox toggles visibility on the password field.
      # Criteria:
      # Verify Show password works
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_146(@env_info, @client, show_pass_validation.all?)
    when "pma"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C161: Verify that the 'Show password' checkbox toggles visibility on the password field.
      # Criteria:
      # Verify Show password works
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_161(@env_info, @client, show_pass_validation.all?)
    when "tenant admin"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C174: Verify that the 'Show password' checkbox toggles visibility on the password field.
      # Criteria:
      # Verify Show password works
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_174(@env_info, @client, show_pass_validation.all?)
  end

end

Then(/I see a list of doors/) do

  door_list_exists = (@browser.element(:css => ".dataTable").text.include? "QA12345 Eric's 100k Door Eric's Test Building")

  # * * * * * * * T E S T R A I L S * * * * * * *
  # C211: Verify that the Doors tab shows the list of doors assigned by the Property Manager Admin.
  # Criteria:
  # Verify the list of doors
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_211(@env_info, @client, door_list_exists)
end

Then(/I verify the tenant edit door groups page/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  door_group_validation = {}
  wait.until {@browser.elements(:css => ".dataTable")[1].present?}
  door_group_validation.merge!({:door_list_exists => (@browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle-thumb").count == @browser.elements(:css => ".dataTable")[1].tbody.trs.count)})
  @admin_ui.toggle_all_sliders(@browser)
  door_group_validation.merge!({:doors_checked => (@browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle.react-toggle--checked").count == @browser.elements(:css => ".dataTable")[1].tbody.trs.count)})
  @admin_ui.toggle_all_sliders(@browser)
  door_group_validation.merge!({:doors_unchecked => (@browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle").count == @browser.elements(:css => ".dataTable")[1].tbody.trs.count) && (@browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle.react-toggle--checked").count == 0)})
  @admin_ui.door_groups_users.click
  wait.until {@browser.elements(:css => ".dataTable")[2].present?}
  door_group_validation.merge!({:user_list_exists => (@browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle-thumb").count == 10)})
  @admin_ui.toggle_all_sliders(@browser)
  door_group_validation.merge!({:users_checked => (@browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle.react-toggle--checked").count == 10)})
  @admin_ui.toggle_all_sliders(@browser)
  door_group_validation.merge!({:users_unchecked => (@browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle").count == 10) && (@browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle.react-toggle--checked").count == 0)})
  @admin_ui.info_door_groups.click
  door_group_validation.merge!({:guest_default_unchecked => (@browser.element(:css => ".tab-panel.tab-panel--active").elements(:css => ".react-toggle").count == 1) && (@browser.element(:css => ".tab-panel.tab-panel--active").elements(:css => ".react-toggle")[0].parent.parent.text.include? "Is Guest Default")})
  @admin_ui.toggle_all_sliders(@browser)
  name1 = @admin_ui.name.attribute('value')
  @admin_ui.name.send_keys "Test1"
  name2 = @admin_ui.name.attribute('value')
  door_group_validation.merge!({:name_can_be_changed => (name1 != name2)})
  @admin_ui.resets[2].click
  door_group_validation.merge!({:reset_worked => (@browser.elements(:css => 'button[disabled]').count == 6)})
  @admin_ui.door_groups_users.click
  @admin_ui.toggle_all_sliders(@browser)
  @admin_ui.resets[1].click
  door_group_validation.merge!({:reset_worked_2 => (@browser.elements(:css => 'button[disabled]').count == 6)})
  @admin_ui.door_groups_doors.click
  @admin_ui.toggle_all_sliders(@browser)
  @admin_ui.resets[0].click
  door_group_validation.merge!({:reset_worked_3 => (@browser.elements(:css => 'button[disabled]').count == 6)})
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C217 Verify that after pressing 'More...' on Door Groups view, the TA can select 'edit' and modify properties of the door group (details inside).
  # Criteria:
  # The editable fields in door groups work
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_217(@env_info, @client, door_group_validation.values.all?)

end

Then(/I verify the pma edit door page/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  door_validation = {}
  wait.until {@browser.elements(:css => ".dataTable")[1].present?}
  door_validation.merge!({:door_list_exists => (@browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle-thumb").count == @browser.elements(:css => ".dataTable")[1].tbody.trs.count)})
  @admin_ui.toggle_all_sliders(@browser)
  door_validation.merge!({:doors_checked => (@browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle.react-toggle--checked").count == @browser.elements(:css => ".dataTable")[1].tbody.trs.count)})
  @admin_ui.toggle_all_sliders(@browser)
  door_validation.merge!({:doors_unchecked => (@browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle").count == @browser.elements(:css => ".dataTable")[1].tbody.trs.count) && (@browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle.react-toggle--checked").count == 0)})
  @admin_ui.door_users.click
  wait.until {@browser.elements(:css => ".dataTable")[2].present?}
  door_validation.merge!({:user_list_exists => (@browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle-thumb").count == 10)})
  @admin_ui.toggle_all_sliders(@browser)
  door_validation.merge!({:users_checked => (@browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle.react-toggle--checked").count == 10)})
  @admin_ui.toggle_all_sliders(@browser)
  door_validation.merge!({:users_unchecked => (@browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle").count == 10) && (@browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle.react-toggle--checked").count == 0)})
  @admin_ui.door_info.click
  @admin_ui.toggle_all_sliders(@browser)
  door_validation.merge!({:doors_is_common => (@browser.element(:css => ".tab-panel--active").elements(:css => ".react-toggle.react-toggle--checked").count == 2)})
  @admin_ui.toggle_all_sliders(@browser)
  door_validation.merge!({:doors_is_common_unchecked => (@browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle").count == @browser.elements(:css => ".dataTable")[1].tbody.trs.count) && (@browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle.react-toggle--checked").count == 0)})
  name1 = @admin_ui.name.attribute('value')
  @admin_ui.name.send_keys "Test1"
  name2 = @admin_ui.name.attribute('value')
  door_validation.merge!({:name_can_be_changed => (name1 != name2)})
  @admin_ui.resets[2].click
  door_validation.merge!({:reset_worked => (@browser.elements(:css => 'button[disabled]').count == 6)})
  @admin_ui.door_users.click
  @admin_ui.toggle_all_sliders(@browser)
  @admin_ui.resets[1].click
  door_validation.merge!({:reset_worked_2 => (@browser.elements(:css => 'button[disabled]').count == 6)})
  @admin_ui.door_door_groups.click
  @admin_ui.toggle_all_sliders(@browser)
  @admin_ui.resets[0].click
  door_validation.merge!({:reset_worked_3 => (@browser.elements(:css => 'button[disabled]').count == 6)})
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C186 Verify that after pressing 'More...' on Doors view, the PMA can select 'edit' and modify properties of the door (details inside).
  # Criteria:
  # The editable fields in door work
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_186(@env_info, @client, door_validation.values.all?)
end

Then(/I add a door group$/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  door_group_validation = {}
  @admin_ui.add.click
  @admin_ui.name.send_keys "\t"
  door_group_validation.merge!({:required_error => (@admin_ui.name.following_sibling.text.include? "Required")})
  @admin_ui.name.send_keys @first_name + @last_name
  door_group_validation.merge!({:is_guest_default_off => (@browser.elements(:css => ".react-toggle.react-toggle--checked").count == 0)})
  @admin_ui.is_guest_default.click
  door_group_validation.merge!({:can_toggle_guest_default => (@browser.elements(:css => ".react-toggle.react-toggle--checked").count == 1)})
  @admin_ui.is_guest_default.click
  @admin_ui.reset.click
  door_group_validation.merge!({:reset_worked => (@browser.elements(:css => 'button[disabled]').count == 2)})
  @admin_ui.name.send_keys @first_name + @last_name
  @admin_ui.save.click
  @admin_ui.save.click
  wait.until {@admin_ui.top_bar_text.text.include? "Edit a Door Group"}
  door_group_validation.merge!({:door_added => (@browser.elements(:css => ".dataTable")[0].text.include? @first_name + @last_name)})
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C400 Verify that a TA can successfully add a new door group (details inside).
  # Criteria:
  # Can add a door group
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_400(@env_info, @client, door_group_validation.values.all?)
end

When(/I add a door group "([^"]*)"/) do |name|
  @admin_ui.add.click
  @admin.name.send_keys name
  if name == "Guest Default"
    @admin_ui.is_guest_default.click
  end
end

Then(/I validate the user was added "([^"]*)"/) do |test|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  add_user_validation = {}
  wait.until {@admin_ui.top_bar_text.text.include? "Edit a User"}
  add_user_validation.merge!({:first_name => (@browser.elements(:css => '.dataTable')[0].text.include? @first_name)})
  add_user_validation.merge!({:last_name => (@browser.elements(:css => '.dataTable')[0].text.include? @last_name)})
  add_user_validation.merge!({:email => (@browser.elements(:css => '.dataTable')[0].text.include? @email.downcase)})

  if @test_validation != nil
    add_user_validation.merge!({:error_messages => (@test_validation.values.all?)})
  end
  case test
    when "234"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C234 In the Users tab/view, verify error handling when attempting to add a user with invalid/incomplete fields (details inside).
      # Criteria:
      # Add user and check errors
      # Suite Admin UI
      # ---------------------------------------------
      TestRailsTest.check_234(@env_info, @client, add_user_validation.values.all?)
    when "10752"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C10752 Verify that the TA can add employees to the Tenant.
      # Criteria:
      # Add user
      # Suite Admin UI
      # ---------------------------------------------
      TestRailsTest.check_10752_2(@env_info, @client, add_user_validation.values.all?)
  end

end

Then(/I validate the tenant admin was added/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  wait.until {@admin_ui.top_bar_text.text.include? "Edit a User"}
  @admin_ui.roles_tab.click
  tenant_added_validation = {}
  tenant_added_validation.merge!({:tenant_admin_toggled => ((@browser.elements(:css => ".dataTable")[5].tbody.trs[1].tds[0].text.include? "Tenant Admin") && (@browser.elements(:css => ".dataTable")[5].tbody.trs[1].tds[1].elements(:css => ".react-toggle--checked").count == 1))})
  tenant_added_validation.merge!({:first_name => (@browser.elements(:css => '.dataTable')[0].text.include? @first_name)})
  tenant_added_validation.merge!({:last_name => (@browser.elements(:css => '.dataTable')[0].text.include? @last_name)})
  tenant_added_validation.merge!({:email => (@browser.elements(:css => '.dataTable')[0].text.include? @email.downcase)})

  # * * * * * * * T E S T R A I L S * * * * * * *
  # C10753 Verify that the TA can add a tenant admin
  # Criteria:
  # Add tenant admin
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_10753(@env_info, @client, tenant_added_validation.values.all?)
end

When(/I go to the password set page/) do
  response = Automato::MailinatorHelper.getInbox(@email)
  email = Automato::MailinatorHelper.get_individual_email(response['messages'][0]['id'])
  parsed_body = Nokogiri::HTML(email['data']['parts'][0]['body'])

  sign_up_link = parsed_body.search('a')[1].to_h['href']

  @browser.goto sign_up_link
end

Then(/I validate I can set my password/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  wait.until {@browser.element(:css => 'input[type="password"]').present?}
  set_password_validation = {}
  set_password_validation.merge!({:browser_url => (@browser.url.include? "set-password/new-password")})
  set_password_validation.merge!({:password_field_exists => (@browser.element(:css => 'input[type="password"]').present?)})
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C405 Verify that clicking on the enroll email link opens the browser on the change password page in the default browser.
  # Criteria:
  # Add tenant admin
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_405_2(@env_info, @client, set_password_validation.values.all?)
end

Then(/I validate I can log in with my new user/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  wait.until {@admin_ui.top_bar_text.text.include? "My Profile"}
  sign_in_validation = {}
  sign_in_validation.merge!({:user_first_name => (@browser.elements(:css => ".dataTable")[0].text.include? @first_name)})
  sign_in_validation.merge!({:user_last_name => (@browser.elements(:css => ".dataTable")[0].text.include? @last_name)})
  sign_in_validation.merge!({:email => (@browser.elements(:css => ".dataTable")[0].text.include? @email.downcase)})
  sign_in_validation.merge!({:mobile => (@browser.elements(:css => ".dataTable")[0].text.include? @mobile)})
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C10754 Verify new user can sign into the Admin UI.
  # Criteria:
  # New user can sign in to admin ui
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_10754(@env_info, @client, sign_in_validation.values.all?)
end

Then(/I verify the name was changed/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  wait.until{@admin_ui.user_table.text.include? @first_name_2}
  name_changed_validation = {}
  name_changed_validation.merge!({:new_is_new => (@first_name_2 != @first_name) && (@last_name_2 != @last_name)})
  name_changed_validation.merge!({:first_is_changed => (@admin_ui.user_table.text.include? @first_name_2)})
  name_changed_validation.merge!({:last_is_changed => (@admin_ui.user_table.text.include? @last_name_2)})

  # * * * * * * * T E S T R A I L S * * * * * * *
  # C270 Verify that if the user name is changed via Edit User menu, it is reflected on their account.
  # Criteria:
  # User name can be changed
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_270_2(@env_info, @client, name_changed_validation.values.all?)
end

When(/I validate that the event tabs are not visible "([^"]*)"/) do |role|
  @test_rails_hash.merge!({"#{role}_rejections".to_sym => !(@admin_ui.rejections.exists?)})
  @test_rails_hash.merge!({"#{role}_entries".to_sym => !(@admin_ui.entries.exists?)})
end

Then(/I validate that the event tabs were not visible/) do
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C66 Verify that Events tabs are not visible to Employees, Guests or Installer roles.
  # Criteria:
  # Event tabs are not visible to certain roles
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_66(@env_info, @client, @test_rails_hash.values.all?)
end

When(/I validate "([^"]*)" search by date/) do |event|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  case event
    when "entries"
      @admin_ui.date_start.click
      @browser.element(:css => ".react-datepicker-ignore-onclickoutside").send_keys "2018-04-27"
      @browser.element(:css => ".react-datepicker-ignore-onclickoutside").send_keys :enter
      @admin_ui.date_stop.click
      @browser.element(:css => ".react-datepicker-ignore-onclickoutside").send_keys "2018-04-27"
      @browser.element(:css => ".react-datepicker-ignore-onclickoutside").send_keys :enter
      entries_valid = []
      wait.until {@browser.element(:css => ".dataTable").present?}
      @browser.element(:css => ".dataTable").tbody.trs.each {|tr|  entries_valid << (tr.text.include? "4/27/2018")}
      @test_rails_hash.merge!({:entries_valid => entries_valid.all?})
    when "rejections"
      @admin_ui.date_start.click
      @browser.element(:css => ".react-datepicker-ignore-onclickoutside").send_keys "2018-04-27"
      @browser.element(:css => ".react-datepicker-ignore-onclickoutside").send_keys :enter
      @admin_ui.date_stop.click
      @browser.element(:css => ".react-datepicker-ignore-onclickoutside").send_keys "2018-04-27"
      @browser.element(:css => ".react-datepicker-ignore-onclickoutside").send_keys :enter
      rejections_valid = []
      wait.until {@browser.element(:css => ".dataTable").present?}
      @browser.element(:css => ".dataTable").tbody.trs.each {|tr| rejections_valid << (tr.text.include? "4/27/2018")}
      @test_rails_hash.merge!({:rejections_valid => rejections_valid.all?})
    when "reports"
      @browser.element(:css => 'label[for="startDate"]').following_sibling.click
      @browser.element(:css => ".rdt.datetime-picker .form-control").send_keys "2018-04-30 00:00:00"
      @browser.element(:css => ".rdt.datetime-picker .form-control").send_keys :enter
      @browser.element(:css => 'label[for="stopDate"]').following_sibling.click
      @browser.element(:css => 'label[for="stopDate"]').following_sibling.element(:css => ".form-control").send_keys "2018-04-30 23:59:59"
      reports_valid = []
      wait.until {@browser.element(:css => ".dataTable").present?}
      @browser.element(:css => ".dataTable").tbody.trs.each {|tr| reports_valid << (tr.text.include? "2018-04-30")}
      @test_rails_hash.merge!({:reports_valid => reports_valid.all?})
  end
end

Then(/I validate that the event search by date works/) do
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C68 Validate that the search via date option filters accordingly.
  # Criteria:
  # Date time on event tabs is searchable
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_68(@env_info, @client, @test_rails_hash.values.all?)
end

When(/I validate scrolling through "([^"]*)" pages/) do |event|
  number = 10
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  case event
    when "entries"
      entries_valid = []
      number.times {|num|
        wait.until {@browser.element(:css => ".dataTable").present?}
        @browser.element(:css => ".dataTable").tbody.trs.each {|tr| entries_valid << (tr.text.chars.count > 40)}
        @admin_ui.right_arrow.click
      }
    @test_rails_hash.merge!({:entries_valid => entries_valid.all?})
    when "rejections"
      rejections_valid = []
      number.times {|num|
        wait.until {@browser.element(:css => ".dataTable").present?}
        @browser.element(:css => ".dataTable").tbody.trs.each {|tr| rejections_valid << (tr.text.chars.count > 40)}
        @admin_ui.right_arrow.click
      }
    @test_rails_hash.merge!({:rejections_valid => rejections_valid.all?})
    when "reports"
      reports_valid = []
      number.times {|num|
        wait.until {@browser.element(:css => ".dataTable").present?}
        @browser.element(:css => ".dataTable").tbody.trs.each {|tr| reports_valid << (tr.text.chars.count > 40)}
        @admin_ui.right_arrow.click
      }
    @test_rails_hash.merge!({:reports_valid => reports_valid.all?})
  end
end

Then(/I validate that the page scrolling causes no issues/) do
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C69 Validate that scrolling through multiple pages causes no issues.
  # Criteria:
  # Entries/Reports/Rejections pages have no issues
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_69(@env_info, @client, @test_rails_hash.values.all?)
end

When(/I validate that the report tab is not visible "([^"]*)"/) do |role|
  @test_rails_hash.merge!({"#{role}_reports".to_sym => !(@admin_ui.reports.exists?)})
end

Then(/I validate that the report tab is not visible$/) do
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C79 Verify that the Reports tab is not visible to Employee, Installer, Guest or Tenant Administrator roles.
  # Criteria:
  # Event tabs are not visible to certain roles
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_79(@env_info, @client, @test_rails_hash.values.all?)
end

Then(/I validate that the report search by date works/) do
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C80 Validate that the search via date option filters events accordingly.
  # Criteria:
  # Date time on report tab is searchable
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_80(@env_info, @client, @test_rails_hash.values.all?)
end

Then(/I validate that search for "([^"]*)" by name works "([^"]*)"/) do |object, role|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  case object
    when "door"
      case role
        when "employee"
          FirePoll.poll("Wait for things to chill out", 10) do
            @browser.element(:css => ".dataTable").tbody.wait_until_present
            @browser.element(:css => ".dataTable").tbody.trs.count == 1
          end
          @test_rails_hash.merge!({:door_search_by_name => (@browser.element(:css => ".dataTable").tbody.td(:text => "Eric's 100k Door").parent.element(:css => ".align--right").exists?) && (@browser.element(:css => ".dataTable").tbody.trs.count == 1)})
        when "installer"
          FirePoll.poll("Wait for things to chill out", 10) do
            @browser.element(:css => ".dataTable").tbody.wait_until_present
            @browser.element(:css => ".dataTable").tbody.trs.count == 1
          end
          @test_rails_hash.merge!({:door_search_by_name => (@browser.element(:css => ".dataTable").tbody.td(:text => "Eric's 100k Door").parent.element(:css => ".align--right").exists?) && (@browser.element(:css => ".dataTable").tbody.trs.count == 1)})
        when "pma"
          FirePoll.poll("Wait for things to chill out", 10) do
            @browser.element(:css => ".dataTable").tbody.wait_until_present
            @browser.element(:css => ".dataTable").tbody.trs.count == 1
          end
          @test_rails_hash.merge!({:door_search_by_name => (@browser.element(:css => ".dataTable").tbody.td(:text => "Eric's 100k Door").parent.element(:css => ".align--right").exists?) && (@browser.element(:css => ".dataTable").tbody.trs.count == 1)})
      end
    when "building"
      case role
        when "employee"
          FirePoll.poll("Wait for things to chill out", 10) do
            @browser.element(:css => ".dataTable").tbody.wait_until_present
            @browser.element(:css => ".dataTable").tbody.trs.count == 1
          end
          @test_rails_hash.merge!({:building_search_by_name => (@browser.element(:css => ".dataTable").tbody.td(:text => "Eric's Test Building").parent.element(:css => ".align--right").exists?) && (@browser.element(:css => ".dataTable").tbody.trs.count == 1)})
        when "installer"
          FirePoll.poll("Wait for things to chill out", 10) do
            @browser.element(:css => ".dataTable").tbody.wait_until_present
            @browser.element(:css => ".dataTable").tbody.trs.count == 1
          end
          @test_rails_hash.merge!({:building_search_by_name => (@browser.element(:css => ".dataTable").tbody.td(:text => "Eric's Test Building").parent.element(:css => ".align--right").exists?) && (@browser.element(:css => ".dataTable").tbody.trs.count == 1)})
        when "pma"
          FirePoll.poll("Wait for things to chill out", 10) do
            @browser.element(:css => ".dataTable").tbody.wait_until_present
            @browser.element(:css => ".dataTable").tbody.trs.count == 1
          end
          @test_rails_hash.merge!({:building_search_by_name => (@browser.element(:css => ".dataTable").tbody.td(:text => "Eric's Test Building").parent.element(:css => ".align--right").exists?) && (@browser.element(:css => ".dataTable").tbody.trs.count == 1)})
      end
    when "door groups"
      case role
        when "pma"
          # binding.pry
          FirePoll.poll("Wait for things to chill out", 10) do
            @browser.element(:css => ".dataTable").wait_until_present
            begin
              @browser.element(:css => ".dataTable").tbody.trs.count == 1
            rescue Exception => e
            end
          end
          @test_rails_hash.merge!({:door_groups_search_by_name => (@browser.element(:css => ".dataTable").tbody.td(:text => "Washrooms").parent.element(:css => ".align--right").exists?) && (@browser.element(:css => ".dataTable").tbody.trs.count == 1)})
      end
    when "guest"
      case role
        when "pma"
          wait.until {@browser.elements(:css => ".dataTable")[1]}
          FirePoll.poll("Wait for things to chill out", 10) do
            @browser.elements(:css => ".dataTable")[1].wait_until_present
            @browser.elements(:css => ".dataTable")[1].tbody.trs.count == 1
          end
          @test_rails_hash.merge!({:guest_search_by_name => (@browser.elements(:css => ".dataTable")[1].tbody.td(:text => "Harmony").parent.element(:css => ".align--right").exists?) && (@browser.elements(:css => ".dataTable")[1].tbody.trs.count == 1)})
      end
    when "user"
      case role
        when "pma"
          FirePoll.poll("Wait for things to chill out", 10) do
            @browser.element(:css => ".dataTable").tbody.wait_until_present
            begin
              @browser.element(:css => ".dataTable").tbody.trs.count == 1
            rescue Exception => e
            end
          end
          @test_rails_hash.merge!({:user_search_by_name => (@browser.element(:css => ".dataTable").tbody.td(:text => "Friedrich13315").parent.element(:css => ".align--right").exists?) && (@browser.element(:css => ".dataTable").tbody.trs.count == 1)})
      end
    when "tenant"
      case role
        when "pma"
          FirePoll.poll("Wait for things to chill out", 10) do
            @browser.element(:css => ".dataTable").tbody.wait_until_present
            begin
              @browser.element(:css => ".dataTable").tbody.trs.count == 1
            rescue Exception => e
            end
          end
          @test_rails_hash.merge!({:tenant_search_by_name => (@browser.element(:css => ".dataTable").tbody.td(:text => "Eric's Test Tenant").parent.element(:css => ".align--right").exists?) && (@browser.element(:css => ".dataTable").tbody.trs.count == 1)})
      end
  end
end

Then(/I validate that search by name works for "([^"]*)"/) do |role|
  case role
    when "employee"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C92 Verify that the search by name function works on both Doors and Buildings view.
      # Criteria:
      # Search by name works
      # Suite Admin UI
      # ---------------------------------------------
      TestRailsTest.check_92(@env_info, @client, @test_rails_hash.values.all?)
    when "installer"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C137 Verify that the search by name function works on both Doors and Buildings view.
      # Criteria:
      # Search by name works
      # Suite Admin UI
      # ---------------------------------------------
      TestRailsTest.check_137(@env_info, @client, @test_rails_hash.values.all?)
    when "pma"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C152 Verify the search by name function works on the Doors, Buildings, Door Groups, Guests (invitations/guests tabs), Users and Tenants views.
      # Criteria:
      # Search by name works
      # Suite Admin UI
      # ---------------------------------------------
      TestRailsTest.check_152(@env_info, @client, @test_rails_hash.values.all?)
  end
end

When(/I give my user access to "([^"]*)"$/) do |door|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  @admin_ui.edit.click
  @admin_ui.door_tab.click
  @browser.elements(:css => ".dataTable")[1].element(:css => ".react-toggle-thumb").click
  @admin_ui.click_save_button(@browser)
end

Then(/I perform a single entry "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  transaction_validation = {}
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
  transaction_validation.merge!({:first_name => (@entry[0]['userFirstName'] == @first_name)})
  transaction_validation.merge!({:last_name => (@entry[0]['userLastName'] == @last_name)})
  transaction_validation.merge!({:door_name => (@entry[0]['doorName'] == "Eric's 100k Door")})

  transaction_validation.merge!({:transaction_time => (@entry[0]['transactionAt'].between?((DateTime.now.to_i - 30), (DateTime.now.to_i + 30)))})
  case os
    when "iOS"
      transaction_validation.merge!({:device_type => (@entry[0]['deviceType'] == "iOS")})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C72: Validate that each successful door transaction is captured as an Entry with accurate data and OS is not marked as 'pending' (details inside).
      # Criteria: Can change contact name
      #
      message = "Transaction was not valid"
      suite = "Integrated End-to-End Validation Suite"
      case_id = 72
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, transaction_validation.values.all?, message)
    when "android"
      transaction_validation.merge!({:device_type => (@entry[0]['deviceType'] == "android")})
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C14098: Validate that each successful door transaction is captured as an Entry with accurate data and OS is not marked as 'pending' (details inside).
      # Criteria: Can change contact name
      #
      message = "Transaction was not valid"
      suite = "Integrated End-to-End Validation Suite"
      case_id = 14098
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, transaction_validation.values.all?, message)
  end
end

Then(/I validate the entries page is user specific/) do
  @admin_ui.entries_tab.click
  valid_entries = {}
  valid_entries.merge!({:valid_entries => ((@browser.element(:css => ".tab-panel--active .dataTable").trs.count-1) == (@entry_info['data'].select {|entry| entry['userFirstName'] == @first_name}.count))})
  valid_entries.merge!({:valid_entries_2 => (@browser.element(:css => ".tab-panel--active .dataTable").trs[1].text.include? @entry[0]['deviceType'])})
  valid_entries.merge!({:valid_entries_3 => (@browser.element(:css => ".tab-panel--active .dataTable").trs[1].text.include? @entry[0]['doorName'])})

  # * * * * * * * T E S T R A I L S * * * * * * *
  # C11992: Verify that on the user view, entries listed are specific for that user
  # Criteria: Can change contact name
  #
  message = "Entries were not user specific"
  suite = "Integrated End-to-End Validation Suite"
  case_id = 11992
  # ---------------------------------------------

  TestRailsTest.validator(@env_info, @client, suite, case_id, valid_entries.values.all?, message)
end

Then(/I perform a single rejection "([^"]*)"$/) do |os|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  transaction_validation = {}
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
  FirePoll.poll("Wait for rejections to update", 30) do
    rejection = HTTParty.get(@env_info[:base_uri]+ @env['API']['services']['ledger']['rejections']['list-search'].gsub('roleKey', @key),
                             :headers => APIHeaderBuilder.new.get_header(@token),
                             :pem => @pem)
    @rejection_info = JSON.parse(rejection.body)
    @first_name == @rejection_info['data'][0]['userFirstName']
  end
  AMQPHelper.new.lock_terminal(@env)
  @rejection = @rejection_info['data'].select {|entry| entry['userFirstName'] == @first_name}
  transaction_validation.merge!({:first_name => (@rejection[0]['userFirstName'] == @first_name)})
  transaction_validation.merge!({:last_name => (@rejection[0]['userLastName'] == @last_name)})
  transaction_validation.merge!({:door_name => (@rejection[0]['doorName'] == "Eric's 100k Door")})
  transaction_validation.merge!({:transaction_time => (@rejection[0]['transactionAt'].between?((DateTime.now.to_i - 30), (DateTime.now.to_i + 30)))})
  case os
    when "iOS"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C73: Validate that each failed transaction is captured as a rejection with accurate data (details inside).
      # Criteria: Can change contact name
      #
      message = "Rejection was not as expected"
      suite = "Integrated End-to-End Validation Suite"
      case_id = 73
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, transaction_validation.values.all?, message)
    when "android"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C14099: Validate that each failed transaction is captured as a rejection with accurate data (details inside).
      # Criteria: Can change contact name
      #
      message = "Rejection was not as expected"
      suite = "Integrated End-to-End Validation Suite"
      case_id = 14099
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, transaction_validation.values.all?, message)
  end
end

Then(/I perform a single rejection "([^"]*)" with "([^"]*)"$/) do |os, reason|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  transaction_validation = {}
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
  FirePoll.poll("Wait for rejections to update", 30) do
    rejection = HTTParty.get(@env_info[:base_uri]+ @env['API']['services']['ledger']['rejections']['list-search'].gsub('roleKey', @key),
                             :headers => APIHeaderBuilder.new.get_header(@token),
                             :pem => @pem)
    @rejection_info = JSON.parse(rejection.body)
    @first_name == @rejection_info['data'][0]['userFirstName']
  end
  AMQPHelper.new.lock_terminal(@env)
  @rejection = @rejection_info['data'].select {|entry| entry['userFirstName'] == @first_name}
  transaction_validation.merge!({:first_name => (@rejection[0]['userFirstName'] == @first_name)})
  transaction_validation.merge!({:last_name => (@rejection[0]['userLastName'] == @last_name)})
  transaction_validation.merge!({:door_name => (@rejection[0]['doorName'] == "Eric's 100k Door")})
  transaction_validation.merge!({:transaction_time => (@rejection[0]['transactionAt'].between?((DateTime.now.to_i - 30), (DateTime.now.to_i + 30)))})
  transaction_validation.merge!({:rejection_reason => (@rejection[0]['reason'] == reason)})
  case os
    when "android"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C74: If user does not have a concurrent access time with their mobile device during the transaction should show: AD_NORIGHTS
      # Criteria: Can change contact name
      #
      message = "Rejection reason was not as expected"
      suite = "Integrated End-to-End Validation Suite"
      case_id = 74
      # ---------------------------------------------

      TestRailsTest.validator(@env_info, @client, suite, case_id, transaction_validation.values.all?, message)
  end
end

When(/I count the total number of doors "([^"]*)"$/) do |role|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until {@browser.element(:css => ".pagination-text").exists?}
  case role
    when "pma"
      number_of_pages = @browser.element(:css => ".pagination-text").children[1].text.to_i
      i = 0
      x = 0
      number_of_pages.times {|num|
        @browser.elements(:css => ".dataTable")[0].wait_until_present
        i += @browser.elements(:css => ".dataTable")[0].tbody.trs.count
        @admin_ui.right_arrow.click
        if num == number_of_pages - 1
          @browser.elements(:css => ".dataTable")[0].wait_until_present
          x = @browser.elements(:css => ".dataTable")[0].tbody.trs.count
        end
      }
      @doors_pma = ((number_of_pages-1) * 10 + x)
    when "installer"
      number_of_pages = @browser.element(:css => ".pagination-text").children[1].text.to_i
      i = 0
      x = 0
      number_of_pages.times {|num|
        @browser.elements(:css => ".dataTable")[0].wait_until_present
        i += @browser.elements(:css => ".dataTable")[0].tbody.trs.count
        @admin_ui.right_arrow.click
        if num == number_of_pages - 1
          @browser.elements(:css => ".dataTable")[0].wait_until_present
          x = @browser.elements(:css => ".dataTable")[0].tbody.trs.count
        end
      }
      @doors_installer = ((number_of_pages-1) * 10 + x)
  end
end

Then(/I verify the count is the same for PMA and installer/) do
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C177: Verify that the installer shows the list of doors available to the Property Manager.
  # Criteria: Can change contact name
  #
  message = "PMA and Installer see same doors"
  suite = "Integrated End-to-End Validation Suite"
  case_id = 177
  # ---------------------------------------------

  TestRailsTest.validator(@env_info, @client, suite, case_id, (@doors_installer == @doors_pma), message)
end

Then(/I verify I am signed in to the "([^"]*)"$/) do |app|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case app
    when "admin ui"
      wait.until {@admin_ui.top_bar_text.text == "My Profile"}
      @test_rails_hash.merge!({:signed_in => (@admin_ui.top_bar_text.text == "My Profile")})
    when "iOS"
      @qr_page = QRPage.new(@ios_driver.driver)
      @test_rails_hash.merge!({:qr_user_message_iOS => (@qr_page.user_message.displayed?)})
      @test_rails_hash.merge!({:qr_displayed => @qr_page.qr_code.present?})
    when "android"
      @qr_page = AndroidQRPage.new(@android_driver.driver)
      @test_rails_hash.merge!({:qr_user_message => (@qr_page.user_message.displayed?)})
  end
end

Then(/I verify C236/) do
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C236: Verify that the new user can sign in to Admin UI and mobile apps immediately and their new role is assigned.
  # Criteria: Can change contact name
  #
  message = "User could not sign in immediately"
  suite = "Integrated End-to-End Validation Suite"
  case_id = 236
  # ---------------------------------------------

  TestRailsTest.validator(@env_info, @client, suite, case_id, @test_rails_hash.values.all?, message)
end