#MaxThreadsPerHotKey 3
XButton2::click()
space::click()

click() {
    static keepClicking := false
    if (keepClicking) {
        keepClicking := false
        return
    }
    keepClicking := true
    while keepClicking {
        Send "{Right}"
        Sleep 6000
    }
}