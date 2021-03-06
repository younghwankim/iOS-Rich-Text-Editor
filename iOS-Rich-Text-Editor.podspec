Pod::Spec.new do |s|
    s.name = 'iOS-Rich-Text-Editor'
    s.version = '0.0.1'
    s.summary = 'A RichTextEditor for iPhone & iPad.'
    s.homepage = 'github.com/younghwankim/iOS-Rich-Text-Editor'
    s.license = {
      :type => 'MIT',
      :file => 'License.txt'
    }
    s.author = {'Aryan Gh' => 'https://github.com/younghwankim/iOS-Rich-Text-Editor'}
    s.source = {:git => 'https://github.com/younghwankim/iOS-Rich-Text-Editor', :tag => '0.0.1'}
    s.platform = :ios, '6.0'
    s.source_files = 'RichTextEditor/Source/**/*.{h,m}'
    s.resources = ['RichTextEditor/Source/Assets/**/*','RichTextEditor/Source/iphone Popover/Assets/*']
    s.framework = 'Foundation', 'UIKit'
    s.requires_arc = true
end
