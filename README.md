# HGPersonalCenter

## Requirements

- iOS 8.0+ 
- Objective-C
- Xcode 9+

## Installation
我通过自己另一个支持`CocoaPods`的库快速集成 - [HGPersonalCenterExtend](https://github.com/ArchLL/HGPersonalCenterExtend)


```ruby
platform :ios, '8.0'

target 'HGPersonalCenter' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!
  pod 'HGPersonalCenterExtend', '~> 1.0.2'
end

```

## Blog 
[简书](https://www.jianshu.com/p/8b87837d9e3a)


## Show  

![image](https://github.com/ArchLL/HGPersonalCenter/blob/master/show.gif)


## Usage
请参照`HGPersonalCenterViewController`

⚠️ Pods里面的第三方库可能不是最新版本，运行demo之前先执行`pod install`

⚠️ 如果你的pageViewController下的scrollView是UICollectionView类型，需要进行如下设置：
```Objc
//解决categoryView在吸顶状态下，且collectionView的显示内容不满屏时，出现竖直方向滑动失效的问题
_collectionView.alwaysBounceVertical = YES;
```

## Author

Arch, mint_bin@163.com

## License

HGPersonalCenterExtend is available under the MIT license. See the LICENSE file for more info.
