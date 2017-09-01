require "paypal/recurring"

PayPal::Recurring.configure do |config|
  config.sandbox = true
  config.username = "artsoftPm_api1.business.com"
  config.password = "8KSTGGPBPL4WLFXH"
  config.signature = "AFcWxV21C7fd0v3bYYYRCpSSRl31AmA8V.iyHwboZRLjPVUWiUl0wLfw"
end