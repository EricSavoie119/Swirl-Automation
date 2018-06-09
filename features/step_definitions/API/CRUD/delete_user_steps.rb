When(/I delete the user/) do
  uri = UriBuilder.new.delete_user(@env, @env_info, @key, @user_info)

  if @env_info[:base_uri].include? @env['API']['base-uri']['lenel']
    response = HTTParty.delete(uri,
                               :headers => APIHeaderBuilder.new.get_header(@token),
                               :pem => @pem,
                               :verify => false)
    @delete_user = JSON.parse(response.body)
  elsif @env_info[:base_uri].include? @env['API']['base-uri']['qa']
    response = HTTParty.delete(uri,
                               :headers => APIHeaderBuilder.new.get_header(@token),
                               :pem => @pem,
                               :verify => false)
    @delete_user = JSON.parse(response.body)
  end
end

Then(/I verify the user is deleted/) do
  response = HTTParty.get(UriBuilder.new.read_user(@env, @env_info, @key, @user_info),
                          :headers => APIHeaderBuilder.new.get_header(@token),
                          :pem => @pem,
                          :verify => false)
  @read_user_info = JSON.parse(response.body)
  if @key != nil
    fail "User was not deleted." unless @delete_user['status'] == 'deleted'
  else
    fail "User was not deleted." unless @read_user_info['errors'][0]['detail'].include? "One or more of the provided UUID values was not found"
  end
end