# HGPersonalCenter

## Requirements

- iOS 9.0+ 
- Objective-C
- Xcode 10+

## Installation
我通过自己另一个支持`CocoaPods`的库快速集成 - [HGPersonalCenterExtend](https://github.com/ArchLL/HGPersonalCenterExtend)


```ruby
pod 'HGPersonalCenterExtend', '~> 1.3.1'
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

### 温馨提示
当时为了实验不同导航栏框架的效果，在该项目中引入了`GKNavigationBarViewController`，但是这个第三方库对代码侵入性较高，还有一些bug未解决（比如：在我这个项目的场景下系统左滑操作失效，不得已我接入了`FDFullscreenPopGesture`来解决这个问题；左滑返回时，导航栏会闪屏）.  

所以不建议大家在自己的项目中使用`GKNavigationBarViewController`，推荐使用`RTRootNavigationController`，可以参考[HGPersonalCenterExtend](https://github.com/ArchLL/HGPersonalCenterExtend)中的使用方法

## Author

Arch, mint_bin@163.com

## License

HGPersonalCenterExtend is available under the MIT license. See the LICENSE file for more info.
