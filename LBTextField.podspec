Pod::Spec.new do |spec|
  spec.name         = "LBTextField"
  spec.version      = "0.0.3"
  spec.summary      = "自定义TextField"
  spec.description  = "高效自定义TextField，功能包括Format输入、输入字符限制、输入格式错误判定、输入长度控制。"
  spec.homepage     = "https://github.com/A1129434577/LBTextField"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "刘彬" => "1129434577@qq.com" }
  spec.platform     = :ios
  spec.ios.deployment_target = '8.0'
  spec.source       = { :git => 'https://github.com/A1129434577/LBTextField.git', :tag => spec.version.to_s }
  spec.source_files  = "LBTextField/**/*.{h,m}"
  spec.requires_arc = true
end
