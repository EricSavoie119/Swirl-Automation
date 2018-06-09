class AdminUI
  include SharedFunctions
  include Faker

  def initialize(browser=nil)
    @email    = browser.text_field(:css => "input[type='email']")
    @password = browser.text_field(:css => "input[type='password']")
    @sign_in  = browser.button(:css => ".btn.btn--signin")

    @profile_info = browser.element(:css => ".flyout-trigger")

    #sidebar
    @users   = browser.element(:css => ".icons8-manager")
    @guests  = browser.element(:css => ".icons8-user")
    @guest_tab = browser.element(:css => ".tab-heading-item .icons8-user")
    @support = browser.element(:css => ".icons8-info")
    @tenants = browser.element(:css => ".leftNav .icons8-user-group-man-man")

    @admin_tab = browser.element(:css => ".tab-heading-item .icons8-manager")
    @info_tab  = browser.element(:css => ".tab-heading-item .icons8-info")
    @top_bar = browser.element(:css => ".topBar")
    @top_bar_text = browser.element(:css => ".topBar-text")
    @edit    = browser.element(:css => ".icons8-edit")
    @edit_save = browser.element(:css => ".btn.btn--green")
    @modal   = browser.element(:css => ".modal-body")
    @reset   = browser.element(:css => ".icons8-undo")
    @resets  = browser.elements(:css => ".icons8-undo")
    @doors   = browser.element(:css => ".icons8-door")
    @door_tab = browser.elements(:css => ".icons8-door")[1]
    @buildings = browser.element(:css => ".icons8-building")
    @access_times = browser.elements(:css => ".tab-heading-item")[3]
    @door_groups  = browser.element(:css => ".icons8-layers")
    @info_door_groups = browser.elements(:css => ".icons8-layers")[1]
    @door_groups_users = browser.element(:css => ".tab-heading-item .icons8-user-group-man-man")
    @door_users = browser.element(:css => ".tab-heading-item .icons8-user")
    @door_info  = browser.element(:css => ".tab-heading-item .icons8-door")
    @door_door_groups = browser.element(:css => ".tab-heading-item .icons8-layers")
    @door_groups_doors = browser.elements(:css => ".icons8-door")[1]
    @users_tab = browser.elements(:css => ".icons8-user")[1]
    @right_arrow = browser.element(:css => ".icons8-right")
    @entries_tab = browser.elements(:css => ".icons8-enter")[1]

    # main frame
    @add = browser.element(:css => '.icons8-add')
    @search = browser.element(:css => "input[type='search']")
    @loading= browser.element(:css => ".loading")

    @more = browser.elements(:css => ".btn.btn--more")
    @refresh = browser.element(:css =>".icons8-refresh")
    # Access time
    @date_start = browser.elements(:css => ".react-datepicker__input-container")[0]
    @date_stop = browser.elements(:css => ".react-datepicker__input-container")[1]
    @date_start_text = browser.elements(:css => ".react-datepicker__input-container")[0].element(:css => ".react-datepicker-ignore-onclickoutside")
    @date_stop_text = browser.elements(:css => ".react-datepicker__input-container")[1].element(:css => ".react-datepicker-ignore-onclickoutside")
    @time_select = browser.elements(:css => ".Select-control")


    # Profile button
    @role_change = browser.element(:css => ".flyout-trigger-small")
    @sign_out    = browser.element(:css => ".leftNav-flyout-menu-list-item.leftNav-flyout-menu-list-item--signout")
    @profile     = browser.element(:css => ".leftNav-flyout-menu-list-item.leftNav-flyout-menu-list-item--me")

    @sign_up_password = browser.element(:css => 'input[type="password"]')
    @sign_up_button   = browser.element(:css => ".btn.btn--signin")

    # add user frame
    @first_name = browser.element(:name => "firstName")
    @last_name  = browser.element(:name => "lastName")
    # @email      = browser.element(:name => "email")
    @mobile     = browser.element(:name => "mobile")
    @role       = browser.element(:css => ".Select-control")

    # support frame
    @support_info = browser.table(:css => ".dataTable")
    @user_table = browser.table(:css => '.dataTable')
    @door_table = browser.tables(:css => '.dataTable')[2]
    @users_door_table = browser.tables(:css => '.dataTable')[1]
    @info_data_table = browser.tables(:css => ".dataTable.infoBox")

    @save  = browser.element(:css => ".icons8-save")
    @saves = browser.elements(:css => ".icons8-save")
    @delete = browser.element(:css => ".icons8-delete")

    @errors = browser.elements(:css => ".error")

    # tabs
    @tab_panel = browser.elements(:css => ".tab-panel")
    @tab_users = browser.element(:css => ".tab-heading-item .icons8-user")

    @terminal_id= browser.element(:css => 'input[name="terminalId"]')
    @name       = browser.element(:css => 'input[name="name"]')
    # @building   = browser.elements(:css => ".Select-control")[0]
    @building = browser.element(:css => 'input[id="buildingUid"]')
    @timezone   = browser.elements(:css => ".Select-control")[0]
    @country    = browser.elements(:css => ".Select-control")[1]
    @door_controller = browser.elements(:css => ".Select-control")[1]
    @drop_down  = browser.element(:css => ".Select-menu").children

    @address_num  = browser.element(:css => 'input[name="addressNumber"]')
    @address_street = browser.element(:css => 'input[name="addressStreet"]')
    @address_city   = browser.element(:css => 'input[name="addressCity"]')
    @address_prov   = browser.element(:css => 'input[name="addressProvState"]')
    @address_zip    = browser.element(:css => 'input[name="addressZipPostal"]')
    @radius         = browser.element(:css => 'input[name="radius"]')

    @table_container = browser.element(:css => ".table-container")

    @reports  = browser.element(:css => ".leftNav-list-item .icons8-versions")
    @entries  = browser.element(:css => ".leftNav-list-item .icons8-enter")
    @rejections = browser.element(:css => ".leftNav-list-item .icons8-no-entry")
    @export_to_excel = browser.element(:css => 'a[title="Export to Excel"]')

    @roles_tab = browser.element(:css => ".tab-heading-item .icons8-commercial-development-management")

    @upload_csv = browser.element(:css => ".topBar .btn")

    @add_admin = browser.element(:css => ".tab-panel .icons8-add")

    @show_pass = browser.element(:css => 'input[id="passwordShow"]')

    @is_guest_default = browser.element(:css => 'label[for="isGuestDefault"]').following_sibling.element(:css => ".react-toggle")
    @property_manager = browser.element(:css => '.leftNav-list-item .icons8-client-company')
    @property_manager_name = browser.element(:css => 'input[type="text"]')
    create_getters
  end


  def add_user(admin_ui, role, first_name, last_name, email, mobile, browser)
    admin_ui.users.click
    admin_ui.add.click
    admin_ui.first_name.send_keys first_name
    admin_ui.last_name.send_keys last_name
    admin_ui.email.send_keys email
    admin_ui.mobile.send_keys mobile
    browser.element(:css => ".Select-clear").click
    admin_ui.drop_down.each {|option| if option.text == role then break option.click end}
  end

  def remove_access_time(row_num, browser)
    browser.elements(:css => ".dataTable")[3].tbody.trs[row_num].elements(:css => ".btn")[1].click
    true
  end

  def click_add_access_time(browser)
    browser.elements(:css => ".dataTable")[3].tbody.trs[0].elements(:css => ".btn")[0].click
    true
  end

  def modify_edit_access_times(admin_ui)
    admin_ui.date_start.click
    admin_ui.date_start.click
    admin_ui.date_start_text.send_keys DateTime.now.strftime("%Y-%m-%d")
    admin_ui.date_stop.click
    admin_ui.date_stop_text.send_keys "2019-03-14"
    admin_ui.top_bar.click
    admin_ui.time_select[0].click
    admin_ui.time_select[0].element(:css => '.Select-input input[role="combobox"]').send_keys("00:15")
    admin_ui.time_select[0].element(:css => '.Select-input input[role="combobox"]').send_keys :enter
    admin_ui.time_select[1].click
    admin_ui.time_select[1].element(:css => '.Select-input input[role="combobox"]').send_keys("00:30")
    admin_ui.time_select[1].element(:css => '.Select-input input[role="combobox"]').send_keys :enter
  end

  def modify_access_times(admin_ui)
    admin_ui.date_start.click
    admin_ui.date_start_text.send_keys DateTime.now.strftime("%Y-%m-%d")
    admin_ui.date_stop.click
    admin_ui.date_stop_text.send_keys "2019-03-14"
    admin_ui.top_bar.click
    admin_ui.time_select[1].click
    admin_ui.time_select[1].element(:css => ".Select-input input[id='startTime']").send_keys("00:15")
    admin_ui.time_select[1].element(:css => ".Select-input input[id='startTime']").send_keys :enter
    admin_ui.time_select[2].click
    admin_ui.time_select[2].element(:css => ".Select-input input[id='stopTime']").send_keys("00:30")
    admin_ui.time_select[2].element(:css => ".Select-input input[id='stopTime']").send_keys :enter
  end

  def verify_user_in_table(fname, lname, role)
    sleep(2)
    fname = fname.downcase
    lname = lname.downcase
    role = role.downcase
    information = [fname, lname, role]
    i = 0
    FirePoll.poll("User is in the table", 5) do
      i = i + 1
      information.all? {|info| @user_table.tr(:index => i).text.downcase.include? info}
    end
  end

  def verify_user_profile_info(fname, lname, mobile, role)
    fname = fname.downcase
    lname = lname.downcase
    role = role.downcase
    information = [fname, lname, mobile]
    i = 0
    information.all? {|info| @info_data_table[0].text.downcase.include? info}
    # @info_data_table[1].text.downcase.include? role
  end

  def verify_user_not_in_table(fname, lname, role)
    !verify_user_in_table(fname, lname,role)
  end

  def self.access_level(number)
    if number.to_i % 4 == 0
      size = number.to_i/4.round
      a = :a
      a_ = :a_
      r = :r
      r_ = :r_
      array_a = Array.new(size, a)
      array_a_ = Array.new(size, a_)
      array_r = Array.new(size, r)
      array_r_ = Array.new(size, r_)
      master_ar = [array_a, array_a_, array_r, array_r_].reduce([], :concat)
    else
      Process.exit(0)
    end
  end

  def self.modify_access_level(number,user_hash)
    number.to_i.times {|num|
      @done = false
      modify = num-1
      if num == 0
        if user_hash[num.to_s.to_sym][:access] == :a
          user_hash[num.to_s.to_sym][:access] = :r
        elsif user_hash[num.to_s.to_sym][:access] == :r
          user_hash[num.to_s.to_sym][:access] = :a_
        elsif user_hash[num.to_s.to_sym][:access] == :a_
          user_hash[num.to_s.to_sym][:access] = :r_
        else
          user_hash[num.to_s.to_sym][:access] = :a
        end
      else
        if user_hash[modify.to_s.to_sym][:access] == :a && !@done
          user_hash[num.to_s.to_sym][:access] = :r
          @done = true
        elsif user_hash[modify.to_s.to_sym][:access] == :r && !@done
          user_hash[num.to_s.to_sym][:access] = :a_
          @done = true
        elsif user_hash[modify.to_s.to_sym][:access] == :a_ && !@done
          user_hash[num.to_s.to_sym][:access] = :r_
          @done = true
        elsif user_hash[modify.to_s.to_sym][:access] == :r_ && !@done
          user_hash[num.to_s.to_sym][:access] = :a
          @done = true
        end
      end
    }
    user_hash
  end

  def set_door_access(admin_ui, browser)
    admin_ui.edit.click
    admin_ui.door_tab.click
    FirePoll.poll("This adminUI is going to give me cancer", 10) do
      browser.elements(:css => ".dataTable")[1].text.include? "Eric's 100k Door"
    end
    begin
      browser.elements(:css => ".dataTable")[1].element(:css => ".react-toggle-thumb").click
    rescue Exception => e
      binding.pry
    end
    admin_ui.save.click
  end

  def click_more_button(admin_ui, browser, user_hash=nil, num=nil, name=nil)
    begin
      FirePoll.poll('click the stupid more button', 10) do
        admin_ui.refresh.click
        admin_ui.loading.wait_while_present
        browser.elements(:css => ".btn.btn--more").count == 1
      end
    rescue Exception => e
      binding.pry
      puts e
    end
    @specific_name = name
    if user_hash != nil
      @specific_name = user_hash[num.to_s.to_sym][:first_name]
    end
    FirePoll.poll("click this thing", 10) do
      admin_ui.more[0].click
      sleep(1)
      admin_ui.top_bar_text.text.include? @specific_name
    end
  end

  def click_save_button(browser)
    begin
      if browser.element(:css => ".tab-panel.tab-panel--active").elements(:css => ".btn.btn--green").count == 1
        browser.element(:css => ".tab-panel.tab-panel--active").elements(:css => ".btn.btn--green")[0].element(:css => ".icons8-save").click
      else
        browser.element(:css => ".tab-panel.tab-panel--active").elements(:css => ".btn.btn--green")[1].element(:css => ".icons8-save").click
      end
    rescue Exception => e
      puts e
      # browser.element(:css => ".tab-panel.tab-panel--active").elements(:css => ".btn.btn--green")[1].element(:css => ".icons8-save").click
    end
  end

  def click_access_times(admin_ui, browser)
    FirePoll.poll("Wait for 6") do
      browser.elements(:css => ".tab-heading-item").count == 6
    end
    browser.element(:css => ".tab-heading").text.include? "Access Times"
    admin_ui.access_times.present?
    admin_ui.access_times.click
  end

  def verify_first_name_errors(admin_ui)
    errors = {}
    admin_ui.first_name.send_keys "\t"
    errors.merge!({:first_name_error => (admin_ui.first_name.following_sibling.text.include? "Required")})
    admin_ui.first_name.send_keys "1"
    errors.merge!({:first_name_format => (admin_ui.first_name.following_sibling.text.include? "First name must be 2 or more characters in length")})
    errors.values.all?
  end

  def verify_last_name_errors(admin_ui)
    errors = {}
    admin_ui.last_name.send_keys "\t"
    errors.merge!({:last_name_error => (admin_ui.last_name.following_sibling.text.include? "Required")})
    admin_ui.last_name.send_keys "1"
    errors.merge!({:last_name_format => (admin_ui.last_name.following_sibling.text.include? "Last name must be 2 or more characters in length")})
    errors.values.all?
  end

  def verify_email_errors(admin_ui, browser, email)
    errors = {}
    admin_ui.email.send_keys "\t"
    errors.merge!({:email_error => (admin_ui.email.following_sibling.text.include? "Required")})
    errors.merge!({:is_false_flipped => !(browser.execute_script("return arguments[0].checkValidity();", browser.text_field(:css => "input[type='email']")))})
    errors.merge!({:email_HTML5_message => (browser.execute_script("return arguments[0].validationMessage;", browser.text_field(:css => "input[type='email']")).include? "Please fill out this field.")})
    admin_ui.email.send_keys email
    errors.merge!({:email_HTML5_message => (browser.execute_script("return arguments[0].validationMessage;", browser.text_field(:css => "input[type='email']")).include? "")})
    errors.merge!({:is_true => (browser.execute_script("return arguments[0].checkValidity();", browser.text_field(:css => "input[type='email']")))})
    errors.values.all?
  end

  def verify_mobile_errors(admin_ui, browser)
    errors = {}
    admin_ui.mobile.send_keys "\t"
    errors.merge!({:mobile_error => (admin_ui.mobile.following_sibling.text.include? "Required")})
    admin_ui.mobile.send_keys "q"
    errors.merge!({:mobile_format_error => (admin_ui.mobile.following_sibling.text.include? "Mobile phone number must be 2 or more characters in length")})
    admin_ui.mobile.send_keys "1"
    errors.merge!({:mobile_char_error => (admin_ui.mobile.following_sibling.text.include? "Only numbers, dashes, periods and spaces allowed")})
    errors.merge!({:mobile_HTML5_error => (browser.execute_script("return arguments[0].validationMessage;", browser.element(:name => "mobile")).include? "Please match the requested format.")})
    errors.values.all?
  end

  def toggle_all_sliders(browser)
    browser.element(:css => ".tab-panel.tab-panel--active").elements(:css => ".react-toggle-thumb").each {|toggle| toggle.click}
  end

end