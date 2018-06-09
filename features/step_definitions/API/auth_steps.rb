Given(/I auth into the environment/) do
  #set certificates for lenel
  if @env_info[:base_uri].include? "lenel"
    @lenel_gateway = LenelGateway.new
    @pem = LenelGateway.new.certificate(@env_info[:user])
    # @headers = @lenel_gateway.headers
    @key=nil
    @token=nil
  elsif @env_info[:base_uri].include? @env['API']['base-uri']['qa']
    @account_service = AccountService.new
    @pem = nil
    # @headers = @account_service.headers
    response = HTTParty.post(@env_info[:base_uri]+@env['API']['services']['account']['auth']['sign-in'],
                             :body => {
                                 email: @env['auth']['qa'][@env_info[:user]],
                                 password: @env['password']
                             })
    @key = response['roles'][0]['key']
    @token = response['token']
  else
    # Error message
  end
  # log in to user for QA
end


Given(/I auth into the second environment/) do
  if @env_info[:user] == "matt"
    @pem = LenelGateway.new.certificate("qa")
    @env_info[:user] = "qa"
  end

  @first_name = Faker::Name.first_name + Faker::Number.number(5)
  @last_name  = Faker::Name.last_name

  @email = "#{@first_name}.#{@last_name}#{Faker::Number.number(3)}@mailinator.com"
  @mobile = "000-#{Faker::Number.number(3)}-#{Faker::Number.number(4)}"

end