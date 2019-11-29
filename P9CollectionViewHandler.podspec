Pod::Spec.new do |s|

  s.name         = "P9CollectionViewHandler"
  s.version      = "0.9.0"
  s.summary      = "CollectionView handling library. Reduce typing and manage simple."
  s.homepage     = "https://github.com/P9SOFT/P9CollectionViewHandler"
  s.license      = { :type => 'MIT' }
  s.author       = { "Tae Hyun Na" => "taehyun.na@gmail.com" }

  s.ios.deployment_target = '8.0'

  s.source       = { :git => "https://github.com/P9SOFT/P9CollectionViewHandler.git", :tag => "0.9.0" }
  s.swift_version = "4.2"
  s.source_files  = "Sources/*.swift"

end
