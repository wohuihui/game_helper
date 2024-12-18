; 此脚本仅用于娱乐和内部交流！
; 我们的口号是：愿天下没有不认路的车车！愿天下没有不敢上的快车！
; 开发者精力有限，此脚本只适用于1080P、2K、2.5K、4K屏幕的电脑端键鼠操作。
;
; 使用教程：
; 一、注意：
;   侧键1指的是鼠标左侧的侧键中处于前面的那个侧键，也被称为向前翻页键
;   侧键2指的是鼠标左侧的侧键中处于后面的那个侧键，也被称为向后翻页键
; 二、功能
;   1、侧键1：快速吃药和快速点击锚点传送。（效果为：按下后单击鼠标，鼠标移动到确认按钮后再次单击鼠标，最后把鼠标移动到原来的位置。）
;   3、键盘右键：自动传送到路线的下一个点位。
;   4、键盘左键：自动传送到路线的上一个点位。
;   5、键盘上键：显示当前所在第几个点位。（处于debug模式下，显示当前鼠标的坐标）
;   6、键盘下键：开始计时和结束计时。（需要配置计时文件）
;
; 三、配置
;   1、在引入路线文件的配置中，修改为你所需要的路线文件进行引入。
;   2、默认第一个点位需要手动传送过去，如果是自己开地，将routeIndex改为0，从而传送到第一个点位。

#HotIf WinActive("ahk_class UnityWndClass") ; 仅在Unity类游戏生效
global routeFile := "小怪丨刀车.lua" ; 路线文件名称
#Include "./func/hotkey.ahk" ; 引入快捷键文件

global routeIndex := 0 ; 路线开始的点位 - 1，设置为29可直达传奇，地主设置为0，到别人世界设置为1
global hintEnabled := false ; 是否开启提示


global timingFile := "D:/codeRepo/game_helper/timing/-6.txt" ; 计时文件的绝对路径


global foodList := [] ; 吃药列表

; 1 慢
; 2 中等
; 3 最快
global tpSpeed := 3

;#MaxThreadsPerHotKey 3
;XButton1::quickPick()
;MButton::aarr()

#MaxThreadsPerHotKey 1
Right::tpNext(false)
Ctrl & Right::tpNext(true)
Left::tpPrev()
Up::showCoord(false)
Ctrl & Up::showCoord(true)
Down::startTiming()
XButton2::quickTp()
tab::eatFood()

global debugMode := true ; 是否开启debug模式

global fastMode := false ; 是否开启超快模式

global waitQmSum := false ; 是否等角色Q完（Q太快会被吞，可以设置为true，防止被吞

global qmMode := false ; 是否开启qm模式

global openMapKey := "m" ; 开图键位

if (tpSpeed = 1) {
    global BUTTON_SLEEP := 80 ; 点击按钮的延时
    global BOOK_SLEEP := 550 ; 不跨怪开书等待时间
    global BOOK_SLEEP2 := 700 ; 跨怪开书等待时间
    global BOOK_SLEEP3 := 650 ; 首次开书等待时间
    global MAP_SLEEP := 900 ; 不跨怪Map等待时间
    global MAP_SLEEP2 := 900 ; 跨怪Map等待时间
    global CANCEL_AND_CLICK_SLEEP := 80 ; 取消后再次点击的等待时间
    global CRUSADE_SLEEP := 200 ; 点击讨伐后的等待时间
    global CLICK_DOWN_SLEEP := 80 ; 长按鼠标的等待时间
    global WHEEL_SLEEP := 120 ; 选怪时滚轮滚动等待时间
    global SELECT_TWO_WAIT_SLEEP := 600 ; 锚点双选时的等待时间
    global SELECT_TWO_CLICK_SLEEP := 180 ; 锚点双选时点击后的等待时间
    global DIRECT_TP_SLEEP := 120 ; 快传等待时间
    global DIRECT_TP_BACK_SLEEP := 100 ; 快传复位等待时间
    global QUICK_PICK_SLEEP := 5 ; 快检等待时间，5不意味着5ms！！！
    global OPEN_MAP_SLEEP := 600 ; 开地图延迟
    global AREA_SLEEP := 200 ; 切换地图延迟
} else if (tpSpeed = 2) {
    global BUTTON_SLEEP := 80 ; 点击按钮的延时
    global BOOK_SLEEP := 470 ; 不跨怪开书等待时间
    global BOOK_SLEEP2 := 600 ; 跨怪开书等待时间
    global BOOK_SLEEP3 := 600 ; 首次开书等待时间
    global MAP_SLEEP := 900 ; 不跨怪Map等待时间
    global MAP_SLEEP2 := 900 ; 跨怪Map等待时间
    global CANCEL_AND_CLICK_SLEEP := 50 ; 取消后再次点击的等待时间
    global CRUSADE_SLEEP := 200 ; 点击讨伐后的等待时间
    global CLICK_DOWN_SLEEP := 60 ; 长按鼠标的等待时间m
    global WHEEL_SLEEP := 100 ; 选怪时滚轮滚动等待时间
    global SELECT_TWO_WAIT_SLEEP := 500 ; 锚点双选时的等待时间
    global SELECT_TWO_CLICK_SLEEP := 160 ; 锚点双选时点击后的等待时间
    global DIRECT_TP_SLEEP := 90 ; 快传等待时间
    global DIRECT_TP_BACK_SLEEP := 80 ; 快传复位等待时间
    global QUICK_PICK_SLEEP := 5 ; 快检等待时间，5不意味着5ms！！！
    global OPEN_MAP_SLEEP := 550 ; 开地图延迟
    global AREA_SLEEP := 200 ; 切换地图延迟
} else if (tpSpeed = 3) {
    global BUTTON_SLEEP := 80 ; 点击按钮的延时
    global BOOK_SLEEP := 470 ; 不跨怪开书等待时间
    global BOOK_SLEEP2 := 600 ; 跨怪开书等待时间
    global BOOK_SLEEP3 := 600 ; 首次开书等待时间
    global MAP_SLEEP := 850 ; 不跨怪Map等待时间
    global MAP_SLEEP2 := 900 ; 跨怪Map等待时间
    global CANCEL_AND_CLICK_SLEEP := 50 ; 取消后再次点击的等待时间
    global CRUSADE_SLEEP := 200 ; 点击讨伐后的等待时间
    global CLICK_DOWN_SLEEP := 60 ; 长按鼠标的等待时间
    global WHEEL_SLEEP := 100 ; 选怪时滚轮滚动等待时间
    global SELECT_TWO_WAIT_SLEEP := 500 ; 锚点双选时的等待时间
    global SELECT_TWO_CLICK_SLEEP := 160 ; 锚点双选时点击后的等待时间
    global DIRECT_TP_SLEEP := 90 ; 快传等待时间
    global DIRECT_TP_BACK_SLEEP := 80 ; 快传复位等待时间
    global QUICK_PICK_SLEEP := 5 ; 快检等待时间，5不意味着5ms！！！
    global OPEN_MAP_SLEEP := 550 ; 开地图延迟
    global AREA_SLEEP := 200 ; 切换地图延迟
}
