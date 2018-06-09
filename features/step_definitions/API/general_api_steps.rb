Then(/I should not get a confirmation of new user/) do
  if @key != nil
    fail "User is not new" unless @is_new_user['isNewUser'] == false
  else
    fail "409 was not given" unless @user_info['errors'][0]['status'] == 409
  end
end