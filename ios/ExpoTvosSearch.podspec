Pod::Spec.new do |s|
  s.name           = 'ExpoTvosSearch'
  s.version        = '1.6.0'
  s.summary        = 'Native tvOS search view with SwiftUI .searchable modifier'
  s.description    = 'Provides a native tvOS search experience using SwiftUI searchable modifier for proper focus and keyboard navigation'
  s.author         = 'Keiver Hernandez'
  s.homepage       = 'https://github.com/keiver/expo-tvos-search'
  s.license        = { :type => 'MIT', :file => '../LICENSE' }
  s.source         = { :git => 'https://github.com/keiver/expo-tvos-search.git', :tag => s.version.to_s }

  s.platforms      = { :ios => '15.1', :tvos => '15.0' }
  s.swift_version  = '5.9'
  s.source_files   = '*.swift'

  s.dependency 'ExpoModulesCore'
end
