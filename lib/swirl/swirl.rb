class Swirl
  include SharedFunctions

  def initialize(browser)
    @login_username = browser.element(:css => 'input[type="email"]')
    @login_password = browser.element(:css => 'input[type="password"]')
    @login_submit   = browser.element(:css => 'button[type="submit"]')

    @applicants = browser.element(:css => 'a[href="http://swirlinsuranceservicesdev.com/admin/applicants"]')

    @applicants_table = browser.element(:css => 'table[id="applicants_table"]')

    @page_buttons = browser.elements(:css => ".paginate_button")

    @fqs_checkboxes = browser.elements(:css => 'input[data-field="prospect_created_in_fqs"]')


    # @browser.elements(:css => 'input[data-field="prospect_created_in_fqs"]')[0].parent.parent.parent.tds[3].text-field="prospect_created_in_fqs"]')[0].parent.parent.parent.tds[3].text



    create_getters
  end
end