require 'selenium-webdriver'
require 'pry'


$driver = Selenium::WebDriver.for :firefox
$wait = Selenium::WebDriver::Wait.new(:timeout => 10)

$driver.manage.window.maximize

def screenshot_noter_or_lektier(resource, name)
  resource.each_with_index do |resource, index|
    resource.click

    ok = nil
    $wait.until do
      ok = $driver.find_element(:xpath, "//img[contains(@src, '_4f')]")
    end

    $driver.save_screenshot("#{$prefix}/#{name}-#{index}.png")

    ok.click

    loop do
      begin
        $driver.find_element(:xpath, "//img[contains(@src, '_4f')]")
      rescue Selenium::WebDriver::Error::NoSuchElementError
        break
      end

      sleep 0.1
    end
  end
end

klasser = [
  "3 l",
  "1 a", "1 d", "1 e", "1 h", "1 k", "1 l", "1 n", "1 r", "1 s", "1 t",
  "2 a", "2 d", "2 e", "2 h", "2 k", "2 l", "2 n", "2 r", "2 s", "2 t",
  "3 a", "3 d", "3 e", "3 h", "3 k", "3 n", "3 r", "3 s", "3 t"
]

$driver.get "http://ludusweb.akat.dk/"

$wait.until do
  skemaer = $driver.find_element(:xpath, '//div[text() = "Skemaer"]')
  skemaer && skemaer.click
end


klasser.each_with_index do |klasse, index|
  puts "Loading #{klasse}.."

  $prefix = "skemaer/#{klasse.gsub(" ", ".")}/"

  $wait.until do
    skema = $driver.find_element(:xpath, "//div[text() = \"#{klasse}\"]")
    skema && skema.click
  end

  # wait till new skema is loaded..
  $wait.until do
    $driver.find_element(:xpath, "//span[text() = \"#{klasse}\"]")
  end

  `mkdir -p #{$prefix} && rm #{$prefix}*`

  puts "Screenshotting skema.."
  $driver.save_screenshot("#{$prefix}/skema.png")

  puts "Lektier.."
  p lektier = $driver.find_elements(:xpath, "//img[contains(@src, '_53')]")
  screenshot_noter_or_lektier(lektier, :lektie)

  puts "Noter.."
  p noter = $driver.find_elements(:xpath, "//img[contains(@src, '_57')]")
  screenshot_noter_or_lektier(noter, :note)

  puts "Sleeping for next class.."
  sleep(5)
end

$driver.close
