When(/I read the user/) do
  response = HTTParty.get(UriBuilder.new.read_user(@env, @env_info, @key, @user_info),
                          :headers => APIHeaderBuilder.new.get_header(@token),
                          :pem => @pem,
                          :verify => false)
  @read_user_info = JSON.parse(response.body)
end