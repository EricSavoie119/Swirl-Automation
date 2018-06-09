When(/I add a user as "([^"]*)"/) do |role|
  @role = role
  case role
    when "Employee"
      response = HTTParty.post(UriBuilder.new.add_user(@env, @env_info, @key),
                               :headers => APIHeaderBuilder.new.get_header(@token),
                               :pem => @pem,
                               :body => BodyBuilder.new.add_user(@first_name, @last_name, @env, @env_info, role, @mobile, @email),
                               :verify => false)
      @user_info = JSON.parse(response.body)
      @is_new_user = JSON.parse(response.body)
      if @key != nil
        add_door = HTTParty.post(@env_info[:base_uri] + @env['API']['services']['terminal']['users-doors']['add-door-to-user'].gsub('uid', @user_info['uid']).gsub('roleKey', @key),
                                 :headers => APIHeaderBuilder.new.get_header(@token),
                                 :pem => @pem,
                                 :body => ([@env['auth']['qa']['door_uuid']]).to_json)

        @add_door = add_door
        add_rfid = HTTParty.post(@env_info[:base_uri] + @env['API']['services']['account']['users']['set-rfid-card'].gsub('uid', @user_info['uid']).gsub('roleKey', @key),
                                 :headers => APIHeaderBuilder.new.get_header(@token),
                                 :pem => @pem,
                                 :body => {"cardId" => ["#{@cardId}"]}.to_json)


        @add_rfid = JSON.parse(add_rfid.body)
        response = HTTParty.get(UriBuilder.new.read_user(@env, @env_info, @key, @user_info),
                                :headers => APIHeaderBuilder.new.get_header(@token),
                                :pem => @pem,
                                :verify => false)
        @user_info = JSON.parse(response.body)
      end
    when "Guest"
      response = HTTParty.post(UriBuilder.new.add_guest(@env, @env_info, @key),
                               :headers => APIHeaderBuilder.new.get_header(@token),
                               :pem => @pem,
                               :body => BodyBuilder.new.add_guest(@first_name, @last_name, @env, @env_info, role, @mobile, @email),
                               :verify => false)
      @user_info = JSON.parse(response.body)
  end
end

Then(/I verify the user was added/) do
  if @key != nil
    fail "user was not added." unless @read_user_info["firstName"].include? @first_name
    File.open("#{File.expand_path('.')}/lib/logs/100k.log", "a") do |handle|
      handle.puts @email
    end
  else
    fail "User was not added." unless @read_user_info['data']['attributes']['firstName'].include? @first_name
  end
  # Would like this to be a straight does add == read but need the string return problem ot be fixed.
end

When(/I add "([^"]*)" users as "([^"]*)" and set their passwords$/) do |number, role|
  @number = number
  number.to_i.times { |num|
    @role = role
    case role
    when "Employee"
      response = HTTParty.post(UriBuilder.new.add_user(@env, @env_info, @key),
                               :headers => APIHeaderBuilder.new.get_header(@token),
                               :pem => @pem,
                               :body => BodyBuilder.new.add_user(@first_name, @last_name, @env, @env_info, role, @mobile, @email),
                               :verify => false)
      @user_info = JSON.parse(response.body)
      if @key != nil
        add_door = HTTParty.post(@env_info[:base_uri] + @env['API']['services']['terminal']['users-doors']['add-door-to-user'].gsub('uid', @user_info['uid']).gsub('roleKey', @key),
                                 :headers => APIHeaderBuilder.new.get_header(@token),
                                 :pem => @pem,
                                 :body => ([@env['auth']['qa']['door_uuid']]).to_json)

        @add_door = add_door
        add_rfid = HTTParty.post(@env_info[:base_uri] + @env['API']['services']['account']['users']['set-rfid-card'].gsub('uid', @user_info['uid']).gsub('roleKey', @key),
                                 :headers => APIHeaderBuilder.new.get_header(@token),
                                 :pem => @pem,
                                 :body => {"cardId" => ["#{@cardId}"]}.to_json)


        @add_rfid = JSON.parse(add_rfid.body)
      end
    end

    # puts num
    # puts @user_info

    response = Automato::MailinatorHelper.getInbox(@email)
    email = Automato::MailinatorHelper.get_individual_email(response['messages'][0]['id'])
    parsed_body = Nokogiri::HTML(email['data']['parts'][0]['body'])

    sign_up_link = parsed_body.search('a')[1].to_h['href']

    @browser.goto sign_up_link


    @admin_ui.sign_up_password.send_keys @env['password']
    @admin_ui.sign_up_button.click

    Watir::Wait.until{ @browser.url == "https://qa.realestate.waltzapp.com/#/set-password/success"}
    Watir::Wait.until{@browser.element(:css => ".box.box-password").visible?}
  @user_hash.merge!(num.to_s.to_sym => {
      :first_name => @first_name,
      :last_name => @last_name,
      :email => @email,
      :mobile => @mobile,
      :uid => @user_info['uid']})

    @first_name = Faker::Name.first_name + Faker::Number.number(5).gsub("'","")
    @last_name  = Faker::Name.last_name.gsub("'","")

    @email = "#{@first_name}.#{@last_name}#{Faker::Number.number(3)}@mailinator.com"
    @mobile = "000-#{Faker::Number.number(3)}-#{Faker::Number.number(4)}"
  }
end