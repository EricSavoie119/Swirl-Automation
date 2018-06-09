And(/I add a "([^"]*)"$/) do |role|
  @role = role
  case role
    when "Employee", "Tenant Admin"
      @admin_ui.add_user(@admin_ui, role, @first_name, @last_name, @email, @mobile, @browser)
    when "Guest"
      @admin_ui.add_user(@admin_ui, role, @first_name, @last_name, @email, @mobile, @browser)
  end
end

And(/I add "([^"]*)" "([^"]*)"$/) do |who, role|
  @role = role
  case who
    when "my"
      case role
        when "PMA"
          @admin_ui.admin_tab.click
          @admin_ui.add_admin.click
          @admin_ui.first_name.send_keys "Eric"
          @admin_ui.last_name.send_keys "Savoie"
          @admin_ui.email.send_keys "eric.savoie@waltzapp.com"
          @admin_ui.mobile.send_keys "5062607249"
          @admin_ui.save.click
        when "property manager"
          @admin_ui.property_manager.click
          @admin_ui.add.click
          @admin_ui.property_manager_name.send_keys "Eric Savoie"
          @admin_ui.save.click
        when "QA Test Cert Building", "Eric's Test Building"
          @admin_ui.buildings.click
          @admin_ui.add.click
          @admin_ui.name.send_keys role
          @admin_ui.timezone.click
          @admin_ui.drop_down.each {|option| if option.text == "America/Montreal  (-5)" then break option.click end}
          @admin_ui.address_num.send_keys "460"
          @admin_ui.address_street "Saint Catherine"
          @admin_ui.address_city "Montreal"
          @admin_ui.address_prov "QC"
          @admin_ui.address_zip "H2W 2H3"
          @admin_ui.country.click
          @admin_ui.drop_down.each {|option| if option.text == "CAN" then break option.click end}
          @admin_ui.radius.send_keys "150"
          @admin_ui.save.click
        when "Pollich-Reichel 9986 and Sons"
          @admin_ui.buildings.click
          @admin_ui.terminal_id.send_keys "QA12342"
          @admin_ui.name.send_keys role
          @admin_ui.building.click
          @admin_ui.drop_down.each { |option| if option.text == "Eric's Test Building" then break option.click end}
          @admin_ui.door_controller.click
          @admin_ui.drop_down.each { |option| if option.text.include? "Relay Board" then break option.click end}
          @admin_ui.save.click
          @admin_ui.table_container.wait_until_present
        when "12345Braun, Ziemann and Cronin 7303 Inc"
          @admin_ui.buildings.click
          @admin_ui.terminal_id.send_keys "QA12312"
          @admin_ui.name.send_keys role
          @admin_ui.building.click
          @admin_ui.drop_down.each { |option| if option.text == "Eric's Test Building" then break option.click end}
          @admin_ui.door_controller.click
          @admin_ui.drop_down.each { |option| if option.text.include? "Relay Board" then break option.click end}
          @admin_ui.save.click
          @admin_ui.table_container.wait_until_present
        when "Eric's 100k Door"
          @admin_ui.buildings.click
          @admin_ui.terminal_id.send_keys "QA12345"
          @admin_ui.name.send_keys role
          @admin_ui.building.click
          @admin_ui.drop_down.each { |option| if option.text == "Eric's Test Building" then break option.click end}
          @admin_ui.door_controller.click
          @admin_ui.drop_down.each { |option| if option.text.include? "Relay Board" then break option.click end}
          @admin_ui.save.click
          @admin_ui.table_container.wait_until_present
        when "installer"
          @email = "eric.installer12345@mailinator.com"
          @admin_ui.add_user(@admin_ui, "Installer", "Eric", "Installer", "eric.installer12345@mailinator.com", "5062607249", @browser)
        when "employee"
          @email = "eric.employee1234@mailinator.com"
          @admin_ui.add_user(@admin_ui, "Employee", "Eric", "Savoie", "eric.employee1234@mailinator.com", "5062607249", @browser)
        when "tenant"
          @admin_ui.tenants.click
          @admin_ui.add.click
          @admin_ui.building.click
          @admin_ui.drop_down.each { |option| if option.text == "Eric's Test Building" then break option.click end}
          @admin_ui.name.send_keys "Eric's Test Tenant"
          @admin_ui.save.click
        when "tenant admin"
          @email = "eric.savoie1@mailinator.com"
          @admin_ui.admin_tab.click
          @admin_ui.add_admin.click
          @admin_ui.first_name.send_keys "Eric"
          @admin_ui.last_name.send_keys "Savoie"
          @admin_ui.email.send_keys "eric.savoie1@mailinator.com"
          @admin_ui.mobile.send_keys "5062607249"
      end
  end
end

And(/I add a "([^"]*)" to "([^"]*)" with "([^"]*)"/) do |object, building, controller|
  case object
    when "door"
      @admin_ui.add.click
      @admin_ui.terminal_id.send_keys  @terminal_id
      @admin_ui.name.send_keys @business_name
      @admin_ui.building.click
      @admin_ui.drop_down.each { |option| if option.text == building then break option.click end}
      @admin_ui.door_controller.click
      @admin_ui.drop_down.each { |option| if option.text.include? controller then break option.click end}
  end
end

Then(/I "([^"]*)" see the user in the admin ui/) do |verb|
  @admin_ui.users.click
  @admin_ui.search.send_keys @first_name + ' ' + @last_name
  case verb
    when "should"
      fail "Can't find user in admin UI" unless @admin_ui.verify_user_in_table(@first_name, @last_name, @role)
    when "shouldn't"
      fail "Can find user in admin UI" unless @admin_ui.verify_user_not_in_table(@first_name, @last_name, @role)
  end
end

When(/I set the user's password/) do
  response = Automato::MailinatorHelper.getInbox(@email)
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

Then(/I validate my user/) do
  @browser.back
  @admin_ui.email.send_keys @email
  @admin_ui.password.send_keys @env['password']
  @admin_ui.sign_in.click
  fail "Profile info did not match." unless @admin_ui.verify_user_profile_info(@first_name, @last_name, @mobile, @role)
  fail "Not logged in." unless @admin_ui.profile_info.wait_until_present
end

Then(/I modify the access times/) do
  @admin_ui.modify_access_times(@admin_ui)
end

When(/I save my "([^"]*)"/) do |thing|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until {@browser.execute_script("return document.readyState;") == "complete"
  sleep(0.3)}
  @admin_ui.save.click
  case thing
    when "door"
      @admin_ui.table_container.wait_until_present
    when "user"
      @admin_ui.delete.wait_until_present
    when "door group"
      @admin_ui.save.click
      @admin_ui.save.click
  end
end

Then(/I verify the user has access to the door/) do
  if @key != nil
  else
    fail "User does not have door." unless @admin_ui.users_door_table.text.include? @env['auth']['lenel']['building'][@env_info[:user]]['door_name']
  end
end

Then(/I validate the add user error messages/) do
  @test_validation = {}
  @admin_ui.first_name.send_keys "\t"
  @test_validation.merge!({:first_name_error => ((@browser.elements(:css => ".error")[0].text.include? "Required") && (@browser.elements(:css => ".error")[0].parent.parent.text.include? "First Name"))})
  @admin_ui.first_name.send_keys "1"
  @test_validation.merge!({:first_name_format_error => ((@browser.elements(:css => ".error")[0].text.include? "First name must be 2 or more characters in length") && (@browser.elements(:css => ".error")[0].parent.parent.text.include? "First Name"))})
  @admin_ui.last_name.send_keys "\t"
  @test_validation.merge!({:last_name_error => ((@browser.elements(:css => ".error")[1].text.include? "Required") && (@browser.elements(:css => ".error")[1].parent.parent.text.include? "Last Name"))})
  @admin_ui.last_name.send_keys "1"
  @test_validation.merge!({:last_name_format_error => ((@browser.elements(:css => ".error")[1].text.include? "Last name must be 2 or more characters in length") && (@browser.elements(:css => ".error")[1].parent.parent.text.include? "Last Name"))})
  @admin_ui.email.send_keys "\t"
  @test_validation.merge!({:email_error => ((@browser.elements(:css => ".error")[2].text.include? "Required") && (@browser.elements(:css => ".error")[2].parent.parent.text.include? "Email"))})
  @test_validation.merge!({:is_false => (@browser.execute_script("return arguments[0].checkValidity();", @admin_ui.email) == false)})
  @test_validation.merge!({:message_1  => (@browser.execute_script("return arguments[0].validationMessage;", @admin_ui.email) == "Please fill out this field.")})
  @admin_ui.email.send_keys "eric"
  @test_validation.merge!({:message_2 => (@browser.execute_script("return arguments[0].validationMessage;", @admin_ui.email) == "Please include an '@' in the email address. 'eric' is missing an '@'.")})
  @admin_ui.email.send_keys "@eric.com"
  @test_validation.merge!({:is_true => (@browser.execute_script("return arguments[0].checkValidity();", @admin_ui.email))})
  @admin_ui.mobile.send_keys "\t"
  @test_validation.merge!({:mobile_error => ((@browser.elements(:css => ".error")[2].text.include? "Required") && (@browser.elements(:css => ".error")[2].parent.parent.text.include? "Mobile"))})
  @admin_ui.mobile.send_keys "1"
  @test_validation.merge!({:mobile_format_error => ((@browser.elements(:css => ".error")[2].text.include? "Mobile phone number must be 2 or more characters in length") && (@browser.elements(:css => ".error")[2].parent.parent.text.include? "Mobile"))})
  @test_validation.merge!({:message_3 => (@browser.execute_script("return arguments[0].validationMessage;", @admin_ui.mobile) == "Please match the requested format.")})
  @admin_ui.mobile.send_keys "tt"
  @test_validation.merge!({:mobile_num_error => ((@browser.elements(:css => ".error")[2].text.include? "Only numbers, dashes, periods and spaces allowed") && (@browser.elements(:css => ".error")[2].parent.parent.text.include? "Mobile"))})
  @browser.element(:css => ".Select-clear").click
  @test_validation.merge!({:message_4 => (@browser.execute_script("return arguments[0].validationMessage;", @browser.element(:css => 'input[id="roleUid"]')) == "Please fill out this field.")})
  @admin_ui.reset.click
end

Then(/I validate I can add a user of each role/) do
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  @first_name = Faker::Name.first_name + Faker::Number.number(5).gsub("'","")
  @last_name  = Faker::Name.last_name.gsub("'","")

  @email = "#{@first_name}.#{@last_name}#{Faker::Number.number(3)}@mailinator.com"
  @mobile = "000-#{Faker::Number.number(3)}-#{Faker::Number.number(4)}"
  number = 4
  number.to_i.times { |num|
    if num == 0
      role = "Employee"
    elsif num == 1
      role = "Property Manager Admin"
    elsif num == 2
      role = "Installer"
    elsif num == 3
      role = "Security Guard"
    end
    @admin_ui.add_user(@admin_ui, role, @first_name, @last_name, @email, @mobile, @browser)
    if num == 3
      @admin_ui.modify_access_times(@admin_ui)
    end
    wait.until {@browser.execute_script("return document.readyState;") == "complete"
    sleep(0.3)}
    @admin_ui.save.click
    if num == 3
      @admin_ui.refresh.wait_until_present
      @test_validation.merge!({:access_times_check => ((@admin_ui.info_data_table[0].text.include? DateTime.now.strftime("%Y-%m-%d")) && (@admin_ui.info_data_table[0].text.include? "between 00:15 and 00:30 beginning") && (@admin_ui.info_data_table[0].text.include? "ending 2019-03-14"))})
    else
      @admin_ui.delete.wait_until_present
    end
    @test_validation.merge!({:info => (@admin_ui.verify_user_profile_info(@first_name, @last_name, @mobile, role))})
    @user_hash.merge!(num.to_s.to_sym => {
        :first_name => @first_name,
        :last_name  => @last_name,
        :email => @email,
        :mobile => @mobile,
        :password => @env['password']
    })
    @first_name = Faker::Name.first_name + Faker::Number.number(5).gsub("'","")
    @last_name  = Faker::Name.last_name.gsub("'","")

    @email = "#{@first_name}.#{@last_name}#{Faker::Number.number(3)}@mailinator.com"
    @mobile = "000-#{Faker::Number.number(3)}-#{Faker::Number.number(4)}"
  }
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C233 In the Users tab/view, clicking 'Add' allows the PMA to add a new user of equal or lesser role if all the fields are entered correctly (details inside).
  # Criteria:
  # Add users
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_233(@env_info, @client, @test_validation.values.all?)
end

Then(/I validate the welcome email was sent "([^"]*)"/) do |test|

  response = Automato::MailinatorHelper.getInbox(@email)
  email = Automato::MailinatorHelper.get_individual_email(response['messages'][0]['id'])
  email_subject = email['data']['subject'].include? "Get Started with Waltz"

  case test
    when "235"
      email_pma = email['data']['parts'][0]['body'].include? "Eric Savoie"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C235 Verify that adding a user will successfully send an email to the user's email address containing accurate information (details inside).
      # Criteria:
      # Email has expected information
      # Suite Admin UI
      # ---------------------------------------------
      TestRailsTest.check_235(@env_info, @client, email_subject, email_pma)
    when "265"
      email_tenant = email['data']['parts'][0]['body'].include? "Eric's Test Tenant"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C265 Verify that adding a user will successfully send an email to the user's email address containing accurate information (details inside).
      # Criteria:
      # Email has expected information
      # Suite Admin UI
      # ---------------------------------------------
      TestRailsTest.check_265(@env_info, @client, email_subject, email_tenant)
  end

end

Then(/I validate that all the buttons work "([^"]*)"$/) do |test|
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  @browser.element(:css => ".dataTable.infoBox .btn").click
  @browser.element(:css => 'img[alt="Loading"]').wait_while_present
  @browser.element(:css => '.modal .btn').click
  email_was_sent = {}
  FirePoll.poll("Wait for most recent email", 10) do
    response = Automato::MailinatorHelper.getInbox(@browser.element(:css => ".dataTable.infoBox").tbody.trs[1].text.split[1])
    email_was_sent =  response['messages'].select {|message| message['seconds_ago'] < 15}
    email_was_sent != []

  end
  welcome_email_received = email_was_sent[0]['subject'] == "Get Started with Waltz"


  valid = []
  case test
    when "pma"
      @door_list_exists = (@browser.elements(:css => ".dataTable")[1].text.include? "QA12312 12345Braun, Ziemann and Cronin 7303 Inc") && (@browser.elements(:css => ".dataTable")[1].text.include? "CR12345 Cloud Reader 1") && (@browser.elements(:css => ".dataTable")[1].text.include? "CR22345 Cloud Reader 2") && (@browser.elements(:css => ".dataTable")[1].text.include? "QA12345 Eric's 100k Door") && (@browser.elements(:css => ".dataTable")[1].text.include? "LD12345 Larrys Door") && (@browser.elements(:css => ".dataTable")[1].text.include? "MF12345 Matt Cert Test Door")
      @admin_ui.more[1].wait_until_present
      @browser.execute_script("arguments[0].click();", @admin_ui.more[1])
      wait.until{@admin_ui.top_bar_text.text.include? "Cloud Reader 1"}
      valid.push(@admin_ui.top_bar_text.text.include? "Cloud Reader 1")
      @browser.back
      wait.until{@admin_ui.more[2].present?}
      @browser.execute_script("arguments[0].click();", @admin_ui.more[2])
      wait.until{@admin_ui.top_bar_text.text.include? "Cloud Reader 2"}
      valid.push(@admin_ui.top_bar_text.text.include? "Cloud Reader 2")
      @browser.back
      wait.until{@admin_ui.more[3].present?}
      @browser.execute_script("arguments[0].click();", @admin_ui.more[3])
      wait.until{@admin_ui.top_bar_text.text.include? "Eric's 100k Door"}
      valid.push(@admin_ui.top_bar_text.text.include? "Eric's 100k Door")
      @browser.back
      wait.until{@admin_ui.more[4].present?}
      @browser.execute_script("arguments[0].click();", @admin_ui.more[4])
      wait.until{@admin_ui.top_bar_text.text.include? "Larrys Door"}
      valid.push(@admin_ui.top_bar_text.text.include? "Larrys Door")
      @browser.back
      wait.until{@admin_ui.more[5].present?}
      @browser.execute_script("arguments[0].click();", @admin_ui.more[5])
      wait.until{@admin_ui.top_bar_text.text.include? "Matt Cert Test Door"}
      valid.push(@admin_ui.top_bar_text.text.include? "Matt Cert Test Door")
      @browser.back
      wait.until{@browser.element(:css => ".tab-heading .icons8-layers").present?}
      @browser.element(:css => ".tab-heading .icons8-layers").click
      @door_group_list_exists = (@browser.elements(:css => ".dataTable")[2].text.include? "Office")
      wait.until{@admin_ui.more[6].present?}
      @browser.execute_script("arguments[0].click();", @admin_ui.more[6])
      wait.until{@admin_ui.top_bar_text.text.include? "Office"}
      valid.push(@admin_ui.top_bar_text.text.include? "Office")
      @browser.back
      @browser.element(:css => ".tab-heading .icons8-enter").click
      @entries_list_exists = (@browser.elements(:css => ".dataTable")[3].tbody.trs.count == 10) && (@browser.elements(:css => ".dataTable")[3].text.include? "Eric's 100k Door")
      @refresh_works = FirePoll.poll("Refresh worked", 10) do
        @admin_ui.refresh.click
        @admin_ui.loading.exists?
      end

      @admin_ui.edit.click
      wait.until {@browser.element(:css => ".tab-heading-item .icons8-info").exists?}
      @edit_works = @browser.element(:css => ".tab-heading-item .icons8-info").exists?
      @more_buttons_work = valid.all?
    when "tenant admin"
      @door_list_exists = (@browser.elements(:css => ".dataTable")[1].text.include? "QA12345 Eric's 100k Door")
      @admin_ui.more[0].wait_until_present
      @browser.execute_script("arguments[0].click();", @admin_ui.more[0])
      wait.until{@admin_ui.top_bar_text.text.include? "Eric's 100k Door"}
      valid.push(@admin_ui.top_bar_text.text.include? "Eric's 100k Door")
      @browser.back
      wait.until{@browser.element(:css => ".tab-heading .icons8-layers").present?}
      @browser.element(:css => ".tab-heading .icons8-layers").click
      @door_group_list_exists = (@browser.elements(:css => ".dataTable")[2].text.include? "Office")
      wait.until{@browser.element(:css => ".tab-panel--active .dataTable .btn.btn--more").present?}
      @browser.execute_script("arguments[0].click();", @browser.element(:css => ".tab-panel--active .dataTable .btn.btn--more"))
      wait.until{@admin_ui.top_bar_text.text.include? "Office"}
      valid.push(@admin_ui.top_bar_text.text.include? "Office")
      @browser.back
      @browser.element(:css => ".tab-heading .icons8-enter").click
      @entries_list_exists = (@browser.elements(:css => ".dataTable")[3].tbody.trs.count > 1) && (@browser.elements(:css => ".dataTable")[3].text.include? "Eric's 100k Door")
      @refresh_works = FirePoll.poll("Refresh worked", 10) do
        @admin_ui.refresh.click
        @admin_ui.loading.exists?
      end
      @admin_ui.edit.click
      wait.until {@browser.element(:css => ".tab-heading-item .icons8-info").exists?}
      @edit_works = @browser.element(:css => ".tab-heading-item .icons8-info").exists?
      @more_buttons_work = valid.all?
  end

  case test
    when "pma"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C237 In the Users tab/view, when clicking on the 'More..' option for a specific user, verify that all clickable elements function (details inside).
      # Criteria:
      # User page buttons work
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_237(@env_info, @client, welcome_email_received, @door_list_exists, @door_group_list_exists, @entries_list_exists, @refresh_works, @edit_works, @more_buttons_work)
    when "tenant admin"
      # * * * * * * * T E S T R A I L S * * * * * * *
      # C267 In the Users tab/view, when clicking on the 'More..' option for a specific user, verify that all clickable elements function (details inside).
      # Criteria:
      # User page buttons work
      # Suite Admin UI
      # ---------------------------------------------

      TestRailsTest.check_267(@env_info, @client, welcome_email_received, @door_list_exists, @door_group_list_exists, @entries_list_exists, @refresh_works, @edit_works, @more_buttons_work)
  end


end