#Include "./base.ahk" ; 引入函数
#Include "./route.ahk" ; 引入路线解析

global screenWidth := A_ScreenWidth
global screenHeight := A_ScreenHeight

global screenKind := screenHeight / screenWidth
global K169 := 0.5625
global K1610 := 0.625

global routes

if (screenKind = K169) {
    routes := newRoute("./text_route/" . routeFile)
} else if (screenKind = K1610) {
    routes := newRoute("./text_route1610/" . routeFile)
}

global waitQmSum := false ; 是否等夜兰Q完

; 后面的参数不用修改
global crusadePos := [9884, 33238] ; 讨伐按钮的位置
global clearWheelPos := [32622, 17241] ; 清空滚轮的位置
global monsterColumnPos := [17242, 23046, 29362] ; 三列怪的不同x值
global monsterRowPos := 20944 ; 怪的y值
global rowWheelNum := 9 ; 滚动一行需要的滚轮数
global trackMonsterPos := [49420, 51238] ; 追踪怪的位置
global confirmPos := [57546, 61225] ; 确认按钮的位置
global selection := [[46552, 44560]] ; 点击锚点时多选按钮的位置
global foodPos := [29464, 3096]
global narrowPos := [1502, 39461]
global enlargePos := [1502, 25923]
global mapAreas := [[49574, 10867], [59492, 11079], [49335, 17484], [59475, 17606], [49642, 23555], [58416, 23707], [49335, 30992], [59458, 30961], [49284, 37154]]

if (screenKind = K169) {
    tip("当前屏幕比例支持自动传送！", 2000)
} else if (screenKind = K1610) {
    tip("当前屏幕比例16:10支持部分自动传送！", 2000)

    global crusadePos := [10167, 32993] ; 讨伐按钮的位置
    global clearWheelPos := [32575, 18771] ; 清空滚轮的位置
    global monsterColumnPos := [17005, 23305, 29528] ; 三列怪的不同x值
    global monsterRowPos := 22419 ; 怪的y值
    global rowWheelNum := 9 ; 滚动一行需要的滚轮数
    global trackMonsterPos := [49196, 49387] ; 追踪怪的位置
    global confirmPos := [56187, 61559] ; 确认按钮的位置
    global selection := [[46917, 46641]] ; 点击锚点时多选按钮的位置
    global foodPos := [29374, 2746]
    global narrowPos := [1613, 38772]
    global enlargePos := [1537, 26599]
} else {
    tip("当前屏幕比例不支持自动传送！", 2000)
}

global BUTTON_SLEEP := 60 ; 点击按钮的延时
global BOOK_SLEEP := 470 ; 不跨怪开书等待时间
global BOOK_SLEEP2 := 600 ; 跨怪开书等待时间
global BOOK_SLEEP3 := 600 ; 首次开书等待时间
global MAP_SLEEP := 300 ; 不跨怪Map等待时间
global MAP_SLEEP2 := 350 ; 跨怪Map等待时间
global CANCEL_AND_CLICK_SLEEP := 50 ; 取消后再次点击的等待时间
global CRUSADE_SLEEP := 200 ; 点击讨伐后的等待时间
global CLICK_DOWN_SLEEP := 60 ; 长按鼠标的等待时间
global WHEEL_SLEEP := 100 ; 选怪时滚轮滚动等待时间
global SELECT_TWO_WAIT_SLEEP := 500 ; 锚点双选时的等待时间
global SELECT_TWO_CLICK_SLEEP := 160 ; 锚点双选时点击后的等待时间
global DIRECT_TP_SLEEP := 90 ; 快传等待时间
global DIRECT_TP_BAG_SLEEP := 80 ; 快传复位等待时间
global QUICK_PICK_SLEEP := 5 ; 快检等待时间，5不意味着5ms！！！
global BAG_SLEEP := 500 ; 开背包的延迟
global OPEN_MAP_SLEEP := 550 ; 开地图延迟
global AREA_SLEEP := 200 ; 切换地图延迟
global TP_COOL_DOWN := 3000 ; 传送冷却时间

SetDefaultMouseSpeed 16 ; 拖动地图时的鼠标移速

; 关闭进程名为Snipaste.exe的程序
ProcessClose "Snipaste.exe"

InstallKeybdHook
InstallMouseHook
ProcessSetPriority "Low" ; 低优先模式
global quickPickPause := false
global crusade := true

global tpForbidden := false
global fastMode := false
global qmMode := false
global FAST_TP := 1
global F2_TP := 2
global AREA_TP := 3

; 上一次追踪的怪
global prevMonster := [0, 0]

; 开图键位
global openMapKey := "m"

; 传送至下一个点位
tpNext(qm) {
    global tpForbidden
    if (tpForbidden) {
        return
    }
    tpForbidden := true
    global routeIndex, routes
    if (routeIndex >= 0 && routeIndex <= routes.Length) {
        routeIndex++
    }
    if (routeIndex > 0 && routeIndex <= routes.Length) {
        executeStep routes[routeIndex], qm
    }
    SetTimer () => tpForbidden := false , -TP_COOL_DOWN
}

; 传送至上一个点位
tpPrev() {
    if (tpForbidden) {
        return
    }
    global routeIndex, routes
    if (routeIndex > 0 && routeIndex <= routes.Length + 1) {
        routeIndex--
        if (routeIndex = 0) {
            routeIndex := routes.Length
        }
    }
    if (routeIndex > 0 && routeIndex <= routes.Length) {
        executeStep routes[routeIndex], false
    }
    SetTimer () => tpForbidden := false , -TP_COOL_DOWN
}

; 执行每一步
executeStep(step, qmParam) {
    global quickPickPause
    global prevMonster
    global crusade
    global fastMode
    global qmMode

    ; 暂停快捡
    quickPickPause := true

    ; 获取值
    selectX := 0
    selectY := 0
    wait := 0
    qm := true
    wheel := 0
    x := 0
    y := 0
    narrow := 0
    qmTp := false
    tpMethod := F2_TP

    ; 记录开图总时间
    sum := 0

    if (HasProp(step, "select")) {
        selectX := selection[step.select - 1][1]
        selectY := selection[step.select - 1][2]
    }
    if (HasProp(step, "wait")) {
        wait := step.wait
    }
    if (HasProp(step, "qm")) {
        qm := step.qm
    }
    if (fastMode && HasProp(step, "fastPos")) {
        x := step.fastPos[1]
        y := step.fastPos[2]
        tpMethod := FAST_TP
    } else if (HasProp(step, "pos")) {
        x := step.pos[1]
        y := step.pos[2]

        row := step.monster[1]
        column := step.monster[2]
        sameMonster := prevMonster[1] = row && prevMonster[2] = column

        tpMethod := F2_TP
    } else {
        x := step.posArea[1]
        y := step.posArea[2]
        tpMethod := AREA_TP
    }

    if (fastMode && (tpMethod = FAST_TP) && HasProp(step, "fastWheel")) {
        wheel := step.fastWheel
    } else if ((tpMethod = F2_TP) && HasProp(step, "wheel")) {
        wheel := step.wheel
    }

    ; 如果你是处于快速模式，且你的点位有标记，就采用开地图直传的方式
    if (fastMode && (tpMethod = FAST_TP) && HasProp(step, "fastNarrow")) {
        narrow := step.fastNarrow
    } else if ((tpMethod = F2_TP) && HasProp(step, "narrow")) {
        narrow := step.narrow
    }

    ; 直接开图拖动
    if (fastMode && (tpMethod = FAST_TP) && HasProp(step, "fastDrag")) {
        drag := step.fastDrag
        op("drag", drag, BUTTON_SLEEP)
        sum += BUTTON_SLEEP
    }

    if (qmParam) {
        qmTp := qmParam
    } else {
        qmTp := (qmMode && qm)
    }

    ; 开书
    ; 开书前开大招
    if (qmTp) {
        Send "{Blind}w"
        Click "Right"
        Sleep 50
        Send "{Blind}q"
        Sleep 10
    }

    if (fastMode && (tpMethod = FAST_TP)) {
        Send openMapKey
        Sleep OPEN_MAP_SLEEP
    } else if (tpMethod = F2_TP) {
        Send "{F1}"
        if (crusade) {
            Sleep BOOK_SLEEP3
            sum += BOOK_SLEEP3
        } else if (sameMonster) {
            Sleep BOOK_SLEEP
            sum += BOOK_SLEEP
        } else {
            Sleep BOOK_SLEEP2
            sum += BOOK_SLEEP2
        }

        ; 额外等开书
        if (HasProp(step, "waitBook")) {
            Sleep step.waitBook
            sum += step.waitBook
        }

        ; 点击讨伐
        if (crusade) {
            op("click", crusadePos, CRUSADE_SLEEP)
            sum += CRUSADE_SLEEP
            crusade := false
        }

        if (!sameMonster) {
            op("longClick", clearWheelPos, CLICK_DOWN_SLEEP) ; 清空滚轮
            sum += CLICK_DOWN_SLEEP

            op("wheel", (row - 1) * rowWheelNum, WHEEL_SLEEP)
            sum += WHEEL_SLEEP

            map := monsterColumnPos
            monsterPosX := map[column]
            op("click", [monsterPosX, monsterRowPos], BUTTON_SLEEP)
            sum += BUTTON_SLEEP
        }

        ; 追踪怪
        if (sameMonster) {
            op("click", trackMonsterPos, CANCEL_AND_CLICK_SLEEP)
            sum += CANCEL_AND_CLICK_SLEEP
            op("click", trackMonsterPos, MAP_SLEEP)
            sum += MAP_SLEEP
        } else {
            op("click", trackMonsterPos, 5)
            op("click", trackMonsterPos, MAP_SLEEP2)
            sum += MAP_SLEEP2
            prevMonster[1] := row
            prevMonster[2] := column
        }

        ; 额外等开地图
        if (HasProp(step, "waitMap")) {
            Sleep step.waitMap
            sum += step.waitMap
        }
    } else if (tpMethod = AREA_TP) {
        Send openMapKey
        Sleep OPEN_MAP_SLEEP
        op("click", confirmPos, BUTTON_SLEEP)
        op("click", mapAreas[step.area], AREA_SLEEP)
    }

    ; 缩小
    if (narrow != 0) {
        if (narrow > 0) {
            Loop narrow {
                op("click", narrowPos, 5)
            }
        } else {
            Loop -narrow {
                op("click", enlargePos, 5)
            }
        }
    }

    ; 拖动
    if (HasProp(step, "drag")) {
        drag := step.drag
        op("drag", drag, BUTTON_SLEEP)
        sum += BUTTON_SLEEP
    }

    if (wheel != 0) {
        op("wheel", wheel, WHEEL_SLEEP)
    }
    sum += WHEEL_SLEEP

    ; 点击传送锚点
    op("click", [x, y], 0)

    if (wait != 0) {
        Sleep wait
        sum += wait
    } else if (selectX != 0 && selectY != 0) {
        Sleep SELECT_TWO_WAIT_SLEEP
        sum += SELECT_TWO_WAIT_SLEEP
    } else {
        Sleep BUTTON_SLEEP
        sum += BUTTON_SLEEP
    }

    if (selectX != 0 && selectY != 0) {
        op("click", [selectX, selectY], SELECT_TWO_CLICK_SLEEP)
        sum += SELECT_TWO_CLICK_SLEEP
    }

    ; 额外等点击确认
    if (HasProp(step, "waitConfirm")) {
        Sleep step.waitConfirm
        sum += step.waitConfirm
    }

    ; 为了qm，补足整个延迟时间
    if (waitQmSum && qmTp && sum < 1200) {
        qmSleep := 1200 - sum
        Sleep qmSleep
    }
    op("click", confirmPos, BUTTON_SLEEP)

    ; 如果出现地脉挡住的情况
    if (HasProp(step, "try")) {
        op("click", [x, y], SELECT_TWO_WAIT_SLEEP)
        op("click", selection[1], SELECT_TWO_CLICK_SLEEP)
        op("click", confirmPos, BUTTON_SLEEP)
    }

    ; 开始快捡
    quickPickPause := false
}

; 快速捡东西，按后退键开始咔咔乱捡，再次按后退键停止捡
quickPick() {
    static keepF := false
    if (keepF) {
        keepF := false
        tip("停止快捡", 2000)
        return
    }
    keepF := true
    tip("开始快捡", 2000)
    autoPick := true
    while autoPick
    {
        if (!quickPickPause) {
            Send "{Blind}f"
            Send "{WheelDown}"
            Loop QUICK_PICK_SLEEP {
                Sleep 1
                if (GetKeyState("Shift", "P") || GetKeyState("Enter", "P") || GetKeyState("Esc", "P") || GetKeyState("Alt", "P")) {
                    autoPick := false
                    break
                }
            }
        }
        if (!keepF) {
            break
        }
    }
    keepF := false
}

; 快速传送，按前进键直接传送
quickTp() {
    Send "{Click}"
    pos := logicalPos()
    Sleep DIRECT_TP_SLEEP
    op("click", confirmPos, DIRECT_TP_BAG_SLEEP)
    op("move", pos, 0)
}

global debugMode := true

global timingIsStart := true

FileEncoding "UTF-8"

global gamingStartTime := A_Now

; 计时
startTiming() {
    global timingIsStart, gamingStartTime
    curTime := A_Now
    curTimeStr := FormatTime(curTime, "yyyy-MM-dd HH:mm:ss")
    if (timingIsStart) {
        gamingStartTime := A_Now

        ; 文件是否存在
        AttributeString := FileExist(timingFile)
        if (AttributeString != 'A') {
            tip("计时文件不存在", 1000)
            return
        }

        FileAppend "锄地开始时间：" . curTimeStr . "`n", timingFile
        tip("开始计时!", 2000)
    } else {
        ; 文件是否存在
        AttributeString := FileExist(timingFile)
        if (AttributeString != 'A') {
            tip("计时文件不存在", 1000)
            return
        }

        FileAppend "锄地结束时间：" . curTimeStr . "`n", timingFile
        seconds := DateDiff(curTime, gamingStartTime, "Seconds")
        minutes := Floor(seconds / 60)
        leftSeconds := Mod(seconds, 60)
        FileAppend "时长：" . minutes . "分钟" . leftSeconds . "秒" . "`n", timingFile
        tip("结束计时!", 2000)
    }

    timingIsStart := !timingIsStart
}

; 显示当前坐标
showCoord(showTip) {
    if (!showTip && debugMode) {
        pos := logicalPos()
        posText := "" . pos[1] . ", " . pos[2]
        tip(posText, 5000)
        A_Clipboard := posText
    } else {
        global routeIndex, routes
        if (routeIndex = 0) {
            tip("路线未开始。", 5000)
        } else if (routeIndex >= routes.Length) {
            tip("路线已结束！", 5000)
        } else {
            route := routes[routeIndex]
            if (HasProp(route, "name")) {
                tip("当前是第" . routeIndex . "个点位：" . route.name . "。", 5000)
            } else {
                tip("当前是第" . routeIndex . "个点位。", 5000)
            }
        }
    }
}

global routeIndex := 0

global foodList := []

global bagOpen := false

global timingFile := "D:/codeRepo/game_helper/timing/-6.txt" ; 计时文件的绝对路径

; 快速吃药
eatFood() {
    global foodList
    global confirmPos
    global bagOpen
    ; 开背包
    sendInput "{Blind}b"
    if (!bagOpen) {
        bagOpen := true
        Sleep 600
        ; 点击食物
        op("click", foodPos, 200)
    } else {
        Sleep 500
    }

    for (food in foodList) {
        op("click", food, 50)
        op("click", confirmPos, 50)
    }
    ; 关闭背包
    sendInput "{Blind}b"
}

; 速射
aarr() {
    static keepAttack := false
    if (keepAttack) {
        keepAttack := false
        return
    }
    keepAttack := true
;    Loop 6 {
;        Click
;        Sleep 60
;    }

    Loop 40 {
        Send "{Blind}w"
        Sleep 60
        Click
        Sleep 200
        Click
        Sleep 240
        Send "{Blind}r"
        Sleep 80
        Send "{Blind}r"
        Sleep 100
        if (!keepAttack) {
            break
        }
    }
}

resurrection() {
    global routeIndex
    while true {
        tpNext(false)
        routeIndex--

        Sleep (4 * 1000)
        Click "Right"
        Sleep 60
        Click "Right"
        Sleep 60
        Click "Right"
        Sleep (6 * 1000)

        SendInput "1"
        Sleep 20
        SendInput "2"
        Sleep 20
        SendInput "3"
        Sleep 20
        SendInput "4"
        Sleep 500

        op("click", [40617, 48912], 200)
        op("click", [47941, 15120], 200)

        Sleep (100 * 1000)
        tip("开始跳崖！！！", 5000)
        Sleep (9 * 1000)
    }
}
