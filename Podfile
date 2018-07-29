# Uncomment this line to define a global platform for your project
platform :ios, '10.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'MapTodo' do
	pod 'Firebase/Core'
	pod 'Fabric', '~> 1.7.2'
	pod 'Crashlytics', '~> 3.9.3'
	pod 'GoogleMaps'
	pod 'GooglePlaces'
	pod 'Instructions', '~> 1.1.0'
	pod 'RealmSwift'
	pod 'R.swift'
	pod 'SwiftLint'
end

target 'MapTodoTests' do

end

target 'MapTodoUITests' do

end
post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-MapTodo/Pods-MapTodo-acknowledgements.plist', 'MapTodo/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
