Pod::Spec.new do |s|
  s.name             = 'LBTextField'
  s.version          = '0.0.1'
  s.summary          = 'LBTextField.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/A1129434577/LBTextField'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'A1129434577' => '1129434577@qq.com' }
  s.source           = { :git => 'https://github.com/A1129434577/LBTextField.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'


  s.subspec 'Macros' do |ss|
    ss.source_files = 'LBCommonComponents/Macros/**/*'
    ss.prefix_header_contents = <<-EOS
       #ifdef __OBJC__
       #import "LBSystemMacro.h"
       #import "LBUIMacro.h"
       #import "LBFunctionMacro.h"
       #endif 
    EOS
  end


  s.subspec 'Category' do |ss|
    ss.subspec 'NSNull+InternalNullExtention' do |sss|
      sss.source_files = 'LBCommonComponents/Category/NSNull+InternalNullExtention/**/*.{h,m}'
    end

    ss.subspec 'UIImage+ChangeColor' do |sss|
      sss.source_files = 'LBCommonComponents/Category/UIImage+ChangeColor/**/*.{h,m}'
    end
    
    ss.subspec 'NSDate+ToString' do |sss|
      sss.source_files = 'LBCommonComponents/Category/NSDate+ToString/**/*.{h,m}'
    end

    ss.subspec 'NSString+ToDate' do |sss|
      sss.source_files = 'LBCommonComponents/Category/NSString+ToDate/**/*.{h,m}'
    end

    ss.subspec 'UIColor+ConvertToImage' do |sss|
      sss.source_files = 'LBCommonComponents/Category/UIColor+ConvertToImage/**/*.{h,m}'
    end

    ss.subspec 'UIView+Geometry' do |sss|
      sss.source_files = 'LBCommonComponents/Category/UIView+Geometry/**/*.{h,m}'
    end

  end

   
  s.subspec 'NSObjects' do |ss|
    ss.subspec 'LBCustemPresentTransitions' do |sss|
      sss.source_files = 'LBCommonComponents/NSObjects/LBCustemPresentTransitions/**/*.{h,m}'
    end

    ss.subspec 'LBEncrypt' do |sss|
      sss.source_files = 'LBCommonComponents/NSObjects/LBEncrypt/**/*'
    end

    ss.subspec 'LBUserModel' do |sss|
      sss.source_files = 'LBCommonComponents/NSObjects/LBUserModel/**/*'
    end

    ss.subspec 'LBSystemPhotoPicker' do |sss|
      sss.source_files = 'LBCommonComponents/NSObjects/LBSystemPhotoPicker/**/*'
    end

    ss.subspec 'LBLunarFormatter' do |sss|
      sss.source_files = 'LBCommonComponents/NSObjects/LBLunarFormatter/**/*'
    end

  end

  s.subspec 'UIViewControllers' do |ss|
    ss.subspec 'LBItemsSelectViewController' do |sss|
      sss.source_files = 'LBCommonComponents/UIViewControllers/LBItemsSelectViewController/**/*'
    end
  
    ss.subspec 'LBWebViewController' do |sss|
       sss.source_files = 'LBCommonComponents/UIViewControllers/LBWebViewController/**/*.{h,m}'
       sss.resource = 'LBCommonComponents/UIViewControllers/LBWebViewController/**/*.png'
    end

    ss.subspec 'LBAlertController' do |sss|
      sss.dependency 'LBCommonComponents/NSObjects/LBCustemPresentTransitions'
      sss.source_files = 'LBCommonComponents/UIViewControllers/LBAlertController/**/*'
    end

    ss.subspec 'LBYearMonthPickerVC' do |sss|
      sss.dependency 'LBCommonComponents/NSObjects/LBCustemPresentTransitions'
      sss.source_files = 'LBCommonComponents/UIViewControllers/LBYearMonthPickerVC/**/*'
    end

    ss.subspec 'LBPhotoPreviewController' do |sss|
      sss.dependency 'SDWebImage'
      sss.dependency 'LBCommonComponents/UIViews/LBReusableScrollView'
      sss.source_files = 'LBCommonComponents/UIViewControllers/LBPhotoPreviewController/**/*.{h,m}'
      sss.resource = 'LBCommonComponents/UIViewControllers/LBPhotoPreviewController/**/*.png'
    end


  end


  s.subspec 'UIViews' do |ss|
    ss.subspec 'UIViewInit' do |sss|
      sss.source_files = 'LBCommonComponents/UIViews/UIViewInit/**/*'
    end

    ss.subspec 'LBRichTextView' do |sss|
      sss.source_files = 'LBCommonComponents/UIViews/LBRichTextView/**/*'
    end

   ss.subspec 'LBCodeGetButton' do |sss|
      sss.source_files = 'LBCommonComponents/UIViews/LBCodeGetButton/**/*'
    end

    ss.subspec 'LBTextField' do |sss|
      sss.source_files = 'LBCommonComponents/UIViews/LBTextField/**/*'
    end
   
   ss.subspec 'LBTitleAndInputCell' do |sss|
      sss.dependency 'LBCommonComponents/UIViews/LBTextField'
      sss.source_files = 'LBCommonComponents/UIViews/LBTitleAndInputCell/**/*'
   end

   ss.subspec 'LBPlaceholderTextView' do |sss|
      sss.source_files = 'LBCommonComponents/UIViews/LBPlaceholderTextView/**/*'
   end

   ss.subspec 'LBCodeView' do |sss|
      sss.source_files = 'LBCommonComponents/UIViews/LBCodeView/**/*'
   end

   ss.subspec 'LBUnderlineButton' do |sss|
      sss.source_files = 'LBCommonComponents/UIViews/LBUnderlineButton/**/*'
   end

   ss.subspec 'LBUnderlineSegmentedControl' do |sss|
      sss.source_files = 'LBCommonComponents/UIViews/LBUnderlineSegmentedControl/**/*'
   end

   ss.subspec 'LBVerticalButton' do |sss|
      sss.source_files = 'LBCommonComponents/UIViews/LBVerticalButton/**/*'
   end

   ss.subspec 'LBTableViewCell' do |sss|
      sss.source_files = 'LBCommonComponents/UIViews/LBTableViewCell/**/*'
   end

   ss.subspec 'LBTitleFrontImageBehindButton' do |sss|
      sss.source_files = 'LBCommonComponents/UIViews/LBTitleFrontImageBehindButton/**/*'
   end

   ss.subspec 'LBReusableScrollView' do |sss|
      sss.source_files = 'LBCommonComponents/UIViews/LBReusableScrollView/**/*'
   end


  end

end

  #pod spec lint  --use-libraries
