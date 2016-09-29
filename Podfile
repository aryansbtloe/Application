platform :ios, "10.0"
use_frameworks!

target 'Application' do
    
    pod 'IQKeyboardManagerSwift'
    pod 'AFNetworking'
    pod 'ReachabilitySwift'
    pod 'MagicalRecord'
    pod 'ActionSheetPicker-3.0'
    pod 'CWStatusBarNotification'
    pod 'Toaster'
    pod 'DZNEmptyDataSet'
    pod 'UIAlertView+Blocks'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'JFMinimalNotifications'
    pod 'iVersion'
    pod 'CTFeedback'
    pod 'EZSwiftExtensions'
    
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
            end
        end
    end
    #Dont forget to update optimisation settings of pods target for release every time after updating pod file
end

