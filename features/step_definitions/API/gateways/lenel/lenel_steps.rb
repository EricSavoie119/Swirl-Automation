Then(/I should see my "([^"]*)" when I poll for guests/) do |who|
  response = HTTParty.get("https://lenel.re-qa.waltzlabs.com/lenel/v1/guests?since=#{@poll_time}",
                          :pem => @pem,
                          :verify => false)
  @poll = JSON.parse(response.body)
  fail "Guest didn't show up in poll" unless @poll['data'][0]['attributes']['firstName'] == @guest_fname
end