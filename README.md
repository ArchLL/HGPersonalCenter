
### 实现头部视图的下拉放大、分页控制以及解决UIScrollView嵌套滑动手势冲突，适用于个人主页，淘宝、天猫店铺页等  

#### 主要内容：
1.使用Masonry方式布局；
2.解决外层和内层滚动视图的上下滑动冲突问题；
3.解决内层的HGSegmentedPageViewController的scrollView左右滚动和外层tableView上下滑动不能互斥的问题；
4.代码已经重构，更容易理解并移植到自己的项目中； 
5.如果你的个人页更复杂且headerImageView需要跟着最外层的scrollView一起滚动的话，可以关注我另一个项目[HGPersonalCenterExtend](https://github.com/ArchLL/HGPersonalCenterExtend) 
6.后期计划：
扩展新的功能  如：完善HGSegmentedPageViewController，支持pageViewController数据刷新，
支持pod引入；

![image](https://github.com/ArchLL/HGPersonalCenterExtend/blob/master/show.gif)
