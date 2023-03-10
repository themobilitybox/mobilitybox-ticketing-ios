Pod::Spec.new do |spec|

  spec.name         = "mobilitybox-ios-sdk"
  spec.version      = "3.0.1"
  spec.summary      = "Including public transport tickets in your iOS Apps."
  spec.description  = <<-DESC

The Mobilitybox Ticketing Package for iOS is a library build in SwiftUI for embedding Mobilitybox public transit tickets within your iOS applications.
Order Tickets with the Mobilitybox API and receive Coupons for the individual ticket booked. Activate Coupons and display the ticket within your App.

                   DESC
  spec.homepage     = "https://github.com/themobilitybox/mobilitybox-ticketing-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = "Vesputi GmbH"
  spec.platform              = :ios, "14.0"
  spec.ios.deployment_target = "14.0"
  spec.swift_version = "5.6"
  spec.source       = { :git => "https://github.com/themobilitybox/mobilitybox-ticketing-ios.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources", "Sources/**/*.{h,m,swift}"
  spec.resources = "Sources/**/*.{xcassets}"
  spec.resource_bundles = {
    'Mobilitybox' => ["Sources/**/*.{xcassets}"]
  }

end
