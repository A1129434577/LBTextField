Pod::Spec.new do |spec|
  spec.name         = "LBTextField"
  spec.version      = "0.0.1"
  spec.summary      = "LBTextField"
  spec.description  = "LBTextField"
  spec.homepage     = "https://github.com/A1129434577/LBTextField"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "LiuBin" => "1129434577@qq.com" }
  spec.platform     = :ios
  spec.ios.deployment_target = '8.0'
  spec.source       = { :git => 'https://github.com/A1129434577/LBTextField.git', :tag => spec.version.to_s }
  spec.source_files  = "LBTextField/**/*.{h,m}"
  spec.requires_arc = true
end
