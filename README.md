# HGPersonalCenter

## Requirements

- iOS 9.0+ 
- Objective-C
- Xcode 10+

## Installation
我通过自己另一个支持`CocoaPods`的库快速集成 - [HGPersonalCenterExtend](https://github.com/ArchLL/HGPersonalCenterExtend)


```ruby
pod 'HGPersonalCenterExtend', '~> 1.2.9'
```

## Blog 
[简书](https://www.jianshu.com/p/8b87837d9e3a)

## Show  

![image](https://github.com/ArchLL/HGPersonalCenter/blob/master/show.gif)


## Usage
主要逻辑已经封装到`HGNestedScrollViewController`中，稍加改动即可将其添加到项目中使用，使用请参照`HGPersonalCenterViewController`；  

⚠️ 如果你的`pageViewController`下的`scrollView`是`UICollectionView`类型，需要进行如下设置：
```Objc
// collectionView的内容不满一屏时，为了避免categoryView在吸顶后页面在竖直方向滑动失效，需要进行如下设置：
_collectionView.alwaysBounceVertical = YES;
```

## Author

Arch, mint_bin@163.com

## License

HGPersonalCenterExtend is available under the MIT license. See the LICENSE file for more info.
