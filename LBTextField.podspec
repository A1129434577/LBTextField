Pod::Spec.new do |spec|
  spec.name         = "LBTextField"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of LBTextField."
  spec.description  = <<-DESC
                   DESC
  spec.homepage     = "http://EXAMPLE/LBTextField"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "刘彬" => "1129434577@qq.com" }
  spec.platform     = :ios
  spec.source       = { :git => 'https://github.com/A1129434577/LBTextField.git', :tag => s.version.to_s }
  spec.source_files  = "LBTextField", "LBTextField/**/*.{h,m}"
  spec.requires_arc = true
end
