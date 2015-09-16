Pod::Spec.new do |s|
  s.name         = "VZPickerView"
  s.version      = "0.0.7"
  s.summary      = "Picker"
  s.description  = "Small library that can pick date, strings, views"
  s.homepage     = "https://github.com/alekoleg/VZPickerView"
  s.license      = 'MIT'
  s.author       = { "Oleg Alekseenko" => "alekoleg@gmail.com" }
  s.source       = { :git => "https://github.com/romabakenbard/VZPickerView", :tag => s.version.to_s}
  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Classes/*.{h,m}'

  s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation', 'UIKit'

end
