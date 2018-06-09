When(/I update the "([^"]*)"/) do |attribute|

  # Lenel does a patch
  # Account service does a put

  if @env_info[:base_uri].include? @env['API']['base-uri']['lenel']
    uri = UriBuilder.new.update_user(@env, @env_info, @key, @user_info)
    body = BodyBuilder.new.update_user(@env, @env_info, @user_info, attribute)
    response = HTTParty.patch(uri,
                              :headers => APIHeaderBuilder.new.get_header(@token),
                              :pem => @pem,
                              :body => body,
                              :verify => false)
    @updated_user_info = JSON.parse(response.body)
  elsif @env_info[:base_uri].include? @env['API']['base-uri']['qa']
    uri = UriBuilder.new.update_user_(@env, @env_info, @key, @user_info, attribute)
    body = BodyBuilder.new.update_user(@env, @env_info, @user_info, attribute)
    case attribute
      when "destination floor", "card id"
        response = HTTParty.post(uri,
                                 :headers => APIHeaderBuilder.new.get_header(@token),
                                 :pem => @pem,
                                 :body => body,
                                 :verify => false)
        @updated_user_info = JSON.parse(response.body)
      when "door schedule"
        response = HTTParty.put(uri,
                                :headers => APIHeaderBuilder.new.get_header(@token),
                                :pem => @pem,
                                :body => body,
                                :verify => false)
      @updated_user_info = JSON.parse(response.body)
    end
#     Can update Firstname, lastname, email
#     can't update mobile
#     Can update with different endpoint: RFID
#     response = HTTParty.put(uri,
#                             :headers => APIHeaderBuilder.new.get_header(@token),
#                             :pem => @pem,
#                             :verify => false)
#     @updated_user_info = JSON.parse(response.body)
  end
end

  # account service return
  # account service is PUT
  # {"uid"=>"d4ee0110-15c2-42c9-bd2b-6a259dadd42b", "isNewUser"=>true}
  # /account/0.3/users/uid?key=roleKey
  #
  # lenel return
  # lenel is patch
  # {"data"=>{"attributes"=>{"firstName"=>"Elda", "lastName"=>"Cassin", "email"=>"elda.cassin528@mailinator.com", "mobile"=>"000-308-1329", "doorSchedule"=>[{"days"=>[1, 2, 3, 4, 5]}], "cardId"=>["987654-abcdef-000"], "destinationFloor"=>40, "createdAt"=>1519683543, "updatedAt"=>nil}, "id"=>"048d4748-eec1-431b-8cc1-8f113841da19", "type"=>"users"}, "links"=>{"self"=>"/lenel/v1/users/048d4748-eec1-431b-8cc1-8f113841da19"}, "jsonapi"=>{"version"=>"1.0"}}
  # /lenel/v1/tenants/tenantId/relationships/users/userId


  #update destination floor for account service
  # https://re-qa.waltzlabs.com/account/0.3/users/4079c56c-acf7-4568-8c58-7afc097f75cb/dest-floor?key=e2553d7e-cfbf-4d78-9d8c-79c60235e2e4&ts=1519683024847
  # cardId: "["987654-abcdef-000"]"
  # destinationFloor: "30"
  # doorSchedule: "[{"days":[1,2,3,4,5]}]"
  # email: "bobbie.schowalter714@example.com"
  # firstName: "Bobbie"
  # lastName: "Schowalter"
  # mobile: "555-000-0000"
  # uid: "4079c56c-acf7-4568-8c58-7afc097f75cb"
  # userId: 3773

  # read user for account service
  # https://re-qa.waltzlabs.com/account/0.3/users/4079c56c-acf7-4568-8c58-7afc097f75cb?key=e2553d7e-cfbf-4d78-9d8c-79c60235e2e4&ts=1519683025169

Then(/I verify "([^"]*)" was updated/) do |attribute|
  if @key != nil
    fail "Card Id was set to nil." unless @read_user_info['cardId'] != nil
    fail "Door Schedule was set to nil." unless {@read_user_info['doorSchedule'].scan(/[A-Za-z0-9\-\_]+/)[0] => @read_user_info['doorSchedule'].scan(/\d/).map { |s| s.to_i }} != nil
    fail "Destination Floor was set to nil." unless @read_user_info['destinationFloor'] != nil
    fail "Mobile phone was set to nil." unless @read_user_info['mobile'] != ''

    case attribute
      when "destination floor"
        fail "Destination Floor was not update." unless @user_info['destinationFloor'] != @read_user_info['destinationFloor']
      when "door schedule"
        fail "Door Schedule was not update." unless {@user_info['doorSchedule'].scan(/[A-Za-z0-9\-\_]+/)[0] => @user_info['doorSchedule'].scan(/\d/).map { |s| s.to_i }} != {@read_user_info['doorSchedule'].scan(/[A-Za-z0-9\-\_]+/)[0] => @read_user_info['doorSchedule'].scan(/\d/).map { |s| s.to_i }}
      when "card id"
        fail "Card Id was not update." unless @user_info['cardId'].scan(/[A-Za-z0-9\-\_]+/) != @read_user_info['cardId'].scan(/[A-Za-z0-9\-\_]+/)
    end

  else
    fail "Card Id was set to nil." unless @read_user_info['data']['attributes']['cardId'].scan(/[A-Za-z0-9\-\_]+/) != nil
    fail "Door Schedule was set to nil." unless {@read_user_info['data']['attributes']['doorSchedule'].scan(/[A-Za-z0-9\-\_]+/)[0] => @read_user_info['data']['attributes']['doorSchedule'].scan(/\d/).map { |s| s.to_i }} != nil
    fail "Destination Floor was set to nil." unless @read_user_info['data']['attributes']['destinationFloor'] != nil
    fail "Mobile phone was set to nil." unless @read_user_info['data']['attributes']['mobile'] != ""

    case attribute
      when "destination floor"
        fail "Destination Floor was not updated." unless @user_info['data']['attributes']['destinationFloor'] != @read_user_info['data']['attributes']['destinationFloor']
      when "door schedule"
        fail "Door Schedule was not update." unless @user_info['data']['attributes']['doorSchedule'][0].values[0] != {@read_user_info['data']['attributes']['doorSchedule'].scan(/[A-Za-z0-9\-\_]+/)[0] => @read_user_info['data']['attributes']['doorSchedule'].scan(/\d/).map { |s| s.to_i }}.values[0]
      when "card id"
        fail "Card Id was not update." unless @user_info['data']['attributes']['cardId'] != @read_user_info['data']['attributes']['cardId'].scan(/[A-Za-z0-9\-\_]+/)
    end
  end

end