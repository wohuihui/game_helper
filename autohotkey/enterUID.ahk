#Include "./func/base.ahk" ; 引入函数

XButton1::pastUID()

global activatePos := [35405, 1669] ; 原神窗口
global pastePos := [50786, 7164] ; 粘贴按钮
global searchPos := [57307, 7255] ; 搜索按钮
global applyEnterPos := [55497, 14570] ; 申请加入按钮

; 输入别人发车的UID
pastUID() {
    ; 复制
    Send "{Click}"
    Send "{Click}"
    Sleep 50

    Send "^c"
    Sleep 200  ; 等待剪贴板中出现文本.
    posText := A_Clipboard

    op("click", activatePos, 50)

    ; 粘贴
    op("click", pastePos, 10)
    op("click", searchPos, 220)
    op("click", applyEnterPos, 200)
    op("click", pastePos, 0)
}



