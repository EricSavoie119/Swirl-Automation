When(/I edit the door information/) do
  @admin_ui.edit.click
  @admin_ui.tab_users.click
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until { @admin_ui.door_table.exists?}
  wait.until { @admin_ui.door_table.elements(:css => ".react-toggle.react-toggle--checked").count > 5}
  @admin_ui.door_table.tr(:index => 1).element(:css => ".react-toggle").click
  binding.pry
  @admin_ui.saves[1].click
end

Then(/I verify the "([^"]*)" edit was successful/) do |item|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  binding.pry
  wait.until {
  @admin_ui.edit.exists?
  @admin_ui.loading.wait_until_present
  @admin_ui.loading.wait_while_present
  }
  @admin_ui.edit.click
  @admin_ui.tab_users.click
  wait.until {
    @admin_ui.door_table.elements(:css => ".react-toggle.react-toggle--checked").count > 5
  }
  fail "Access was not denied." unless @admin_ui.door_table.tr(:index => 1).text.include? "Access Denied"
  @admin_ui.door_table.tr(:index => 1).element(:css => ".react-toggle").click
  @admin_ui.saves[1].click
  wait.until {
    @admin_ui.edit.exists?
    @admin_ui.loading.wait_until_present
    @admin_ui.loading.wait_while_present
  }
  binding.pry
end

Then(/I verify the door exists/) do
  fail "Door was not created." unless @admin_ui.table_container.text.include? @terminal_id
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C188 Verify that property managers can add a door
  # Criteria:
  # Door Exists
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_188(@env_info, @client, (@admin_ui.table_container.text.include? @terminal_id))

end

Then(/I verify the errors on the add door page/) do
  @admin_ui.terminal_id.send_keys "\t"
  terminal_id_error = (@browser.elements(:css => ".error")[0].text.include? "Required") && (@browser.elements(:css => ".error")[0].parent.parent.text.include? "Terminal ID")
  @admin_ui.name.send_keys "\t"
  door_name_error = (@browser.elements(:css => ".error")[1].text.include? "Required") && (@browser.elements(:css => ".error")[1].parent.parent.text.include? "Name")
  @admin_ui.terminal_id.send_keys "12345"
  terminal_format_error = (@browser.elements(:css => ".error")[0].text.include? "Terminal ID must be two uppercase letters followed by five numbers") && (@admin_ui.errors[0].parent.parent.text.include? "Terminal ID")
  @admin_ui.terminal_id.to_subtype.clear
  @admin_ui.terminal_id.to_subtype.clear
  @admin_ui.name.send_keys "1"
  name_format_error = (@browser.elements(:css => ".error")[1].text.include? "Name must be 2 or more characters in length") && (@browser.elements(:css => ".error")[1].parent.parent.text.include? "Name")
  @admin_ui.terminal_id.send_keys "QA12345"
  @admin_ui.terminal_id.send_keys "\t"
  sleep(1)
  terminal_id_already_in_use_error = (@browser.elements(:css => ".error")[0].text.include? "is already in use") && (@browser.elements(:css => ".error")[0].parent.parent.text.include? "Terminal ID")
  @admin_ui.terminal_id.to_subtype.clear
  @admin_ui.terminal_id.to_subtype.clear
  @admin_ui.terminal_id.send_keys "QA93999"
  @admin_ui.terminal_id.send_keys "\t"
  terminal_id_too_big = (@browser.elements(:css => ".error")[0].text.include? "Terminal ID five numbers cannot be bigger than 65535") && (@browser.elements(:css => ".error")[0].parent.parent.text.include? "Terminal ID")
  @admin_ui.terminal_id.to_subtype.clear
  @admin_ui.terminal_id.to_subtype.clear
  @admin_ui.terminal_id.send_keys "QA12344"
  @admin_ui.name.send_keys "12"
  # @admin_ui.save.click
  message = @browser.execute_script("return arguments[0].validationMessage;", @browser.element(:css => 'input[id="buildingUid"]'))
  is_false = @browser.execute_script("return arguments[0].checkValidity();", @browser.element(:css => 'input[id="buildingUid"]'))
  @admin_ui.building.click
  @admin_ui.drop_down.each { |option| if option.text == "Eric's Test Building" then break option.click end}
  is_true = @browser.execute_script("return arguments[0].checkValidity();", @browser.element(:css => 'input[id="buildingUid"]'))
  @admin_ui.reset.click
  reset_worked = @browser.element(:css => 'button[disabled]').exists?
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C187 On the 'Add a Door' page, verify that required fields need to be filled and show appropriate error messages (details inside).
  # Criteria:
  # Door errors are as expected
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_187(@env_info, @client, terminal_id_error, door_name_error, terminal_format_error, name_format_error, terminal_id_already_in_use_error, terminal_id_too_big, message, is_false, is_true, reset_worked)
end

When(/I add a new "([^"]*)"$/) do |object|
  case object
    when "building"
      @admin_ui.add.click
  end
end

Then(/I verify the errors on the add building page$/) do
  @admin_ui.name.send_keys "\t"
  building_name_error = (@browser.elements(:css => ".error")[0].text.include? "Required") && (@browser.elements(:css => ".error")[0].parent.parent.text.include? "Name")
  @admin_ui.name.send_keys "t"
  building_name_format_error = (@browser.elements(:css => ".error")[0].text.include? "Name must be 2 or more characters in length") && (@browser.elements(:css => ".error")[0].parent.parent.text.include? "Name\nName")
  timezone_message = @browser.execute_script("return arguments[0].validationMessage;", @browser.element(:css => 'input[id="timezoneUid"]'))
  is_false = @browser.execute_script("return arguments[0].checkValidity();", @browser.element(:css => 'input[id="timezoneUid"]'))
  @admin_ui.timezone.click
  @admin_ui.drop_down.each {|option| if option.text == "America/Montreal  (-5)" then break option.click end}
  is_true = @browser.execute_script("return arguments[0].checkValidity();", @browser.element(:css => 'input[id="timezoneUid"]'))
  @admin_ui.address_num.send_keys "\t"
  address_num_error = (@browser.elements(:css => ".error")[1].text.include? "Required") && (@browser.elements(:css => ".error")[1].parent.parent.text.include? "Number")
  @admin_ui.address_street.send_keys "\t"
  address_street_error = (@browser.elements(:css => ".error")[2].text.include? "Required") && (@browser.elements(:css => ".error")[2].parent.parent.text.include? "Street")
  @admin_ui.address_street.send_keys "t"
  address_street_format_error = (@browser.elements(:css => ".error")[2].text.include? "Must be 4 or more characters in length") && (@browser.elements(:css => ".error")[2].parent.parent.text.include? "Street")
  @admin_ui.address_city.send_keys "\t"
  address_city_error = (@browser.elements(:css => ".error")[3].text.include? "Required") && (@browser.elements(:css => ".error")[3].parent.parent.text.include? "City")
  @admin_ui.address_city.send_keys "1"
  address_city_format_error = (@browser.elements(:css => ".error")[3].text.include? "Must be 2 or more characters in length") && (@browser.elements(:css => ".error")[3].parent.parent.text.include? "City")
  @admin_ui.address_prov.send_keys "\t"
  address_prov_error = (@browser.elements(:css => ".error")[4].text.include? "Required") && (@browser.elements(:css => ".error")[4].parent.parent.text.include? "State/Prov")
  @admin_ui.address_prov.send_keys "t"
  address_prov_format_error = (@browser.elements(:css => ".error")[4].text.include? "Must be 2 or more characters in length") && (@browser.elements(:css => ".error")[4].parent.parent.text.include? "State/Prov")
  @admin_ui.address_zip.send_keys "1"
  address_zip_error = (@browser.elements(:css => ".error")[5].text.include? "Must be a valid American or Canadian code") && (@browser.elements(:css => ".error")[5].parent.parent.text.include? "Zip/Postal Code")
  country_message = @browser.execute_script("return arguments[0].validationMessage;", @browser.element(:css => 'input[id="addressCountryUid"]'))
  is_false_2 = @browser.execute_script("return arguments[0].checkValidity();", @browser.element(:css => 'input[id="addressCountryUid"]'))
  @admin_ui.country.click
  @admin_ui.drop_down.each {|option| if option.text == "CAN" then break option.click end}
  is_true_2 = @browser.execute_script("return arguments[0].checkValidity();", @browser.element(:css => 'input[id="addressCountryUid"]'))
  @admin_ui.reset.click
  reset_worked = @browser.element(:css => 'button[disabled]').exists?
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C190 On the 'Add a Building' page, verify that required fields need to be filled and show appropriate error messages (details inside).
  # Criteria:
  # Building errors are as expected
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_190(@env_info, @client, building_name_error, building_name_format_error, timezone_message, is_false, is_true, address_num_error, address_street_error, address_street_format_error, address_city_error, address_city_format_error, address_prov_error, address_prov_format_error, address_zip_error, country_message, is_false_2, is_true_2, reset_worked)
end

When(/I search for the "([^"]*)"$/) do |name|
  @searched_name = name
  if name == "new user"
    name = @first_name
  end
  begin
    @admin_ui.search.send_keys name
  rescue Exception => e
    puts e
  end
end

When(/I search for the "([^"]*)" in guest tab$/) do |name|
  @searched_name = name
  begin
    @browser.elements(:css => "input[type='search']")[1].send_keys name
  rescue Exception => e
    puts e
  end
end

When(/I navigate to the "([^"]*)" page of the door group$/) do |page|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case page
    when "edit"
      @admin_ui.click_more_button(@admin_ui, @browser, nil, nil, @searched_name)
      FirePoll.poll("Click the edit button", 10) do
        @admin_ui.edit.click
        wait.until {@admin_ui.top_bar_text.text.include? "Edit"}
      end
  end
end

When(/I navigate to the "([^"]*)" page of the door$/) do |page|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  case page
    when "edit"
      @admin_ui.click_more_button(@admin_ui, @browser, nil, nil, @searched_name)
      FirePoll.poll("Click the edit button", 10) do
        @admin_ui.edit.click
        wait.until {@admin_ui.top_bar_text.text.include? "Edit"}
      end
  end
end

Then(/I verify the edit door groups page$/) do
  door_list_exists = @browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle-thumb").count > 1
  @browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle-thumb").each {|toggle| toggle.click}
  doors_checked = @browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle.react-toggle--checked").count > 1
  @browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle-thumb").each {|toggle| toggle.click}
  doors_unchecked = (@browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle").count > 1) && (@browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle.react-toggle--checked").count == 0)
  @admin_ui.door_groups_users.click
  user_list_exists = @browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle-thumb").count > 1
  @browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle-thumb").each {|toggle| toggle.click}
  users_checked = @browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle.react-toggle--checked").count > 1
  @browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle-thumb").each {|toggle| toggle.click}
  users_unchecked = (@browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle").count > 1) && (@browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle.react-toggle--checked").count == 0)
  @admin_ui.info_door_groups.click
  guest_default_unchecked = (@browser.element(:css => ".tab-panel.tab-panel--active").elements(:css => ".react-toggle").count == 1) && (@browser.element(:css => ".tab-panel.tab-panel--active").elements(:css => ".react-toggle")[0].parent.parent.text.include? "Is Guest Default")
  @browser.element(:css => ".tab-panel.tab-panel--active").elements(:css => ".react-toggle").each {|toggle| toggle.click}
  name1 = @admin_ui.name.attribute('value')
  @admin_ui.name.send_keys "Test1"
  name2 = @admin_ui.name.attribute('value')
  name_can_be_changed = name1 != name2
  @admin_ui.resets[2].click
  reset_worked = @browser.elements(:css => 'button[disabled]').count == 6
  @admin_ui.door_groups_users.click
  @browser.elements(:css => ".dataTable")[2].elements(:css => ".react-toggle-thumb").each {|toggle| toggle.click}
  @admin_ui.resets[1].click
  reset_worked_2 = @browser.elements(:css => 'button[disabled]').count == 6
  @admin_ui.door_groups_doors.click
  @browser.elements(:css => ".dataTable")[1].elements(:css => ".react-toggle-thumb").each {|toggle| toggle.click}
  @admin_ui.resets[0].click
  reset_worked_3 = @browser.elements(:css => 'button[disabled]').count == 6
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C193 Verify that after pressing 'More...' on Door Groups view, the PMA can select 'edit' and modify properties of the door group (details inside).
  # Criteria:
  # Fields are editable
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_193(@env_info, @client, door_list_exists, doors_checked, doors_unchecked, user_list_exists, users_checked, users_unchecked, guest_default_unchecked, name_can_be_changed, reset_worked, reset_worked_2, reset_worked_3)

end

Then(/I validate there is a list of doors/) do
  @browser.tables(:css => ".dataTable")[0].wait_until_present
  doors_listed = @browser.tables(:css => ".dataTable")[0].tbody.trs.count > 2

  # * * * * * * * T E S T R A I L S * * * * * * *
  # C185 Verify that the Doors tab shows the list of doors assigned by the Property Manager Admin.
  # Criteria:
  # There is a list of doors associated to the PMA
  # Suite Admin UI
  # ---------------------------------------------

  TestRailsTest.check_185(@env_info, @client, doors_listed)
end

Then(/I validate the users page of the door$/) do
  @admin_ui.users_tab.click
  one =  @browser.elements(:css => ".dataTable")[2].tbody.trs.count
  @admin_ui.right_arrow.click
  two =  @browser.elements(:css => ".dataTable")[2].tbody.trs.count
  # @admin_ui.right_arrow.click
  # three =  @browser.elements(:css => ".dataTable")[2].tbody.trs.count
  # @admin_ui.right_arrow.click
  # four =  @browser.elements(:css => ".dataTable")[2].tbody.trs.count

  users_listed = (one + two) == 16
  @browser.execute_script("arguments[0].click();", @admin_ui.more[4])
  more_works = @admin_ui.user_table.text.include? "Malcolm43458 Wyman"
  @test_validation = [users_listed, more_works]
end

Then(/I validate the users page of the door group$/) do
  @admin_ui.door_groups_users.click
  one =  @browser.elements(:css => ".dataTable")[2].tbody.trs.count
  @admin_ui.right_arrow.click
  two =  @browser.elements(:css => ".dataTable")[2].tbody.trs.count
  # @admin_ui.right_arrow.click
  # three =  @browser.elements(:css => ".dataTable")[2].tbody.trs.count
  # @admin_ui.right_arrow.click
  # four =  @browser.elements(:css => ".dataTable")[2].tbody.trs.count

  users_listed = (one + two) == 16
  @browser.execute_script("arguments[0].click();", @admin_ui.more[4])
  more_works = @admin_ui.user_table.text.include? "Ronaldo82293 Kris"
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C4788 For Doors & Door Groups, verify that on a particular door/group the Users tab functions correctly (details inside).
  # Criteria:
  # Door/Door groups users page works as expected
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_4788(@env_info, @client, @test_validation, users_listed, more_works)
end

Then(/I validate the entries tab$/) do
  @admin_ui.entries_tab.click
  number_of_pages = @browser.element(:css => ".pagination-text").children[1].text.to_i
  i = 0
  x = 0
  number_of_pages.times {|num|
    @browser.elements(:css => ".dataTable")[3].wait_until_present
    i += @browser.elements(:css => ".dataTable")[3].tbody.trs.count
    @admin_ui.right_arrow.click
    if num == number_of_pages - 1
      @browser.elements(:css => ".dataTable")[3].wait_until_present
      x = @browser.elements(:css => ".dataTable")[3].tbody.trs.count
    end
  }
  entries_are_visible = ((number_of_pages-1) * 10 + x) == i
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C4789 On an individual Door verify that the Entries tab displays each entry and that each page of entries can be accessed.
  # Criteria:
  # Entries are visible and accessible
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_4789(@env_info, @client, entries_are_visible)
end

Then(/I validate I can see the door groups of the door/) do
  txt = @browser.elements(:css => ".dataTable")[1].text
  door_groups_visible = (txt.include? "Fart") && (txt.include? "Office") && (txt.include? "Washrooms")

  # * * * * * * * T E S T R A I L S * * * * * * *
  # C4790 On an individual Door, verify that any Door groups it is a part of is listed on the Door Groups tab.
  # Criteria:
  # Doors list their door groups
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_4790(@env_info, @client, door_groups_visible)
end

Then(/I validate I can see the doors of the door group/) do
  doors_listed_in_door_group = @browser.elements(:css => ".dataTable")[1].tbody.trs.count
  # * * * * * * * T E S T R A I L S * * * * * * *
  # C4791 On an individual Door Group, verify that all Doors in that group is listed in the Door tab.
  # Criteria:
  # Doors listed in their door groups
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_4791(@env_info, @client, doors_listed_in_door_group)
end

Then(/I validate that there is 1 Guest Default group$/) do
  one_guest_default_exists = @browser.elements(:css => ".dataTable")[0].text.include? "Guest Default Yes"
  @test_validation = [one_guest_default_exists]
end

Then(/I validate that I cannot make two Guest Default groups/) do
  @admin_ui.edit.click
  @admin_ui.info_door_groups.click
  guest_default_toggle_disabled = (@browser.element(:css => ".react-toggle.react-toggle--disabled").present?) && (@browser.element(:css => ".react-toggle.react-toggle--disabled").parent.parent.text.include? "Is Guest Default")

  # * * * * * * * T E S T R A I L S * * * * * * *
  # C4793 When adding a door group, verify that the 'Is Guest Default' can be toggled on or off if there are no pre-existing Guest default doors (can only have 1).
  # Criteria:
  # Only one Guest Default door group allowed
  # Suite Admin UI
  # ---------------------------------------------
  TestRailsTest.check_4793(@env_info, @client, @test_validation[0], guest_default_toggle_disabled)
end

