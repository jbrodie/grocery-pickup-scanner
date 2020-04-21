require 'byebug'
require 'capybara'
require 'dotenv'
require 'json'
require 'mail'
require 'nokogiri'
require 'openssl'
require 'selenium-webdriver'
require 'webdrivers'

Dotenv.load

targets = JSON.parse(File.read(ENV['TARGET_FILE']))

Capybara.javascript_driver = :chrome

Capybara.register_driver :selenium do |app|  
  Capybara::Selenium::Driver.new(app, 
    browser: :chrome,
    options: Selenium::WebDriver::Chrome::Options.new(
      args: %w[
        headless
        disable-gpu
        incognito
        disable-geolocation
        disable-popup-blocking
      ]
    )
  )
end

Capybara.javascript_driver = :chrome
Capybara.configure do |config|  
  config.default_max_wait_time = 20 # seconds
  config.default_driver = :selenium
end

# Standard Email Configuration
options = { :address              => ENV['SERVER_ADDRESS'],
            :port                 => ENV['SERVER_PORT'],
            :domain               => ENV['SERVER_DOMAIN'],
            :user_name            => ENV['USER_NAME'],
            :password             => ENV['PASSWORD'],
            :authentication       => :login,
            :openssl_verify_mode  => OpenSSL::SSL::VERIFY_NONE
          }

# Mail Server Specific
options.merge!(:enable_starttls_auto => true) if ENV['SERVER_TYPE'] == "CPANEL"
options.merge!(:ssl => true) if ENV['SERVER_TYPE'] == "GMAIL"

Mail.defaults do
  delivery_method :smtp, options
end

email_message = []

targets.each do |target|
  target[1]['stores'].each do |store|
    browser = Capybara.current_session
    driver = browser.driver.browser
    
    browser.visit target[1]['url']
    
    begin
      modal = browser.find('div[class="modal-dialog__mask"]', visible: false)
      browser.find('button[class="primary-button primary-button--region-selector"]', text: 'Ontario').click if modal
    rescue Capybara::ElementNotFound => e
      # Catch this as we don't need to react to the modal if it isn't there.
    end

    browser.find('a[data-auid="store-locator-link"]').click
    browser.find('.location-search__search__input').set(store['address']).native.send_keys(:return)
    browser.find("button[data-track-pickup-store=\"#{store['store_number']}\"]").click
    browser.find('.store-locator-redirect__button', match: :first).click
    browser.find('button[data-cruller="timeslot-button"]').click

    open_slots = browser.find_all('div[data-cruller="timeslot-selector-slot"]', visible: false)

    if open_slots.size > 0
      email_message << "#{target[0].split('_').map!{|x| x.upcase}.join(' ')}\n" 
      email_message << "Address: #{store['address']}:\n\n" 
      open_slots.each do |slot|
        button = slot.find('button[data-cruller="timeslot-selector-slot-content"]', visible: false)
        email_message << "#{button['aria-label']}\n" unless button.nil?
      end
      email_message << "-------------------------------------\n\n"
    end
    browser.quit
  end
end

# Send out the email.
Mail.deliver do
  to      ENV['EMAIL_TO']
  from    ENV['EMAIL_FROM']
  subject 'Current Available Grocery Delivery Slots'
  body    email_message.join('')
end